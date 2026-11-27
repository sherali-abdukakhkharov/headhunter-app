// A stand-in for the Telegram Bot API, for the throwaway backend that
// .github/workflows/ios-screenshots.yml runs.
//
// headhunter-backend keeps every uploaded file in a Telegram chat
// (src/infra/files/telegram-file.client.ts), and the demo seed uploads CVs,
// certificates and photos. Pointing TELEGRAM_API_BASE_URL here keeps those
// bytes in this process's memory instead of sending generated documents to a
// real bot from a CI runner. It answers the four methods that client calls,
// in the `{ok, result}` envelope it checks, and serves downloads the way
// api.telegram.org does: `getFile` names a path, `/file/bot<token>/<path>`
// returns the bytes.
//
//   node tool/fake_telegram.mjs            listens on 127.0.0.1:8081
//   FAKE_TELEGRAM_PORT=9000 node tool/fake_telegram.mjs
import { createServer } from 'node:http';

const port = Number(process.env.FAKE_TELEGRAM_PORT ?? 8081);

/** file_id -> {bytes, type}. Lives as long as the job does. */
const files = new Map();
let next = 1;

function reply(res, status, body) {
  res.writeHead(status, { 'content-type': 'application/json' });
  res.end(JSON.stringify(body));
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  return Buffer.concat(chunks);
}

createServer(async (req, res) => {
  try {
    const url = new URL(req.url, 'http://127.0.0.1');
    const body = await readBody(req);

    const download = url.pathname.match(/^\/file\/bot[^/]+\/(.+)$/);
    if (download) {
      const file = files.get(download[1]);
      if (!file) {
        res.writeHead(404);
        res.end();
        return;
      }
      res.writeHead(200, { 'content-type': file.type });
      res.end(file.bytes);
      return;
    }

    const method = url.pathname.split('/').pop();
    switch (method) {
      case 'sendDocument': {
        // Node's fetch parses multipart; the client sends a FormData.
        const form = await new Request('http://127.0.0.1', {
          method: 'POST',
          headers: { 'content-type': req.headers['content-type'] ?? '' },
          body,
        }).formData();
        const document = form.get('document');
        if (!document || typeof document === 'string') {
          reply(res, 400, { ok: false, description: 'Bad Request: no document' });
          return;
        }
        const bytes = Buffer.from(await document.arrayBuffer());
        const messageId = next++;
        const fileId = `file${messageId}`;
        files.set(fileId, { bytes, type: document.type || 'application/octet-stream' });
        reply(res, 200, {
          ok: true,
          result: {
            message_id: messageId,
            date: Math.floor(Date.now() / 1000),
            document: {
              file_id: fileId,
              file_unique_id: `unique-${fileId}`,
              file_name: document.name,
              mime_type: document.type,
              file_size: bytes.length,
            },
          },
        });
        return;
      }

      case 'getFile': {
        const fileId = url.searchParams.get('file_id');
        const file = files.get(fileId);
        if (!file) {
          reply(res, 400, { ok: false, description: 'Bad Request: invalid file_id' });
          return;
        }
        reply(res, 200, {
          ok: true,
          result: {
            file_id: fileId,
            file_unique_id: `unique-${fileId}`,
            file_size: file.bytes.length,
            file_path: fileId,
          },
        });
        return;
      }

      case 'getMe':
        reply(res, 200, {
          ok: true,
          result: { id: 1, is_bot: true, first_name: 'Screenshots', username: 'screenshots_bot' },
        });
        return;

      case 'deleteMessage':
        reply(res, 200, { ok: true, result: true });
        return;

      default:
        reply(res, 404, { ok: false, description: `Not Found: ${method}` });
    }
  } catch (error) {
    console.error(error);
    reply(res, 500, { ok: false, description: String(error) });
  }
}).listen(port, '127.0.0.1', () => {
  console.log(`Fake Telegram Bot API on http://127.0.0.1:${port}`);
});
