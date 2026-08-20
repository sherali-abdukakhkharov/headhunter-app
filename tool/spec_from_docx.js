#!/usr/bin/env node
//
// Regenerates docs/SPEC.md from the client's .docx.
//
//   node tool/spec_from_docx.js <source.docx> [output.md]
//
// Output defaults to docs/SPEC.md next to this repo's root. Run it for **both
// repos** with the same source — `headhunter-app/docs/SPEC.md` and
// `headhunter-backend/docs/SPEC.md` are required to be identical, and the
// cheapest way to know the conversion is faithful is that two independent runs
// produce the same bytes.
//
// ## Why this exists
//
// SPEC.md's own header says "regenerate this file" and used to say nothing
// about how. Doing it by hand means re-deciding, under time pressure, how Word
// tables become text — and a citation like "§11.1" is only worth anything if
// the wording behind it is verbatim. This makes the conversion a decision taken
// once.
//
// ## What it does to the document
//
// - Heading1 → `#`, Heading2 → `##`. Everything else is a paragraph.
// - Word tables are flattened to `| cell | cell |` rows. **Not real markdown
//   tables**: several are three columns of prose, and a rendered table of
//   paragraphs is unreadable in a terminal, which is where this file is read.
// - Wording is otherwise untouched, including the typographic quotes and
//   dashes, so BR-nn and UAT-nn can be quoted exactly.
//
// ## The header is preserved, not generated
//
// If the output file already exists and starts with a `# …` block ending in
// `---`, that block is kept verbatim. The provenance note in it ("the wallet /
// Payme / CLICK revision received 2026-08-10") is a human statement about which
// document this is, and a script has no business inventing one. Write it by
// hand once per revision; every regeneration after that reproduces the file
// byte for byte.
//
// Node rather than Dart: reading a .docx means reading a zip, which Dart cannot
// do without adding `archive` to a `pubspec.yaml` whose pins are load-bearing.
// Node is already the tool used for ARB edits in this repo.

'use strict';

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// --- the smallest zip reader that can find one entry --------------------------

/**
 * Reads one file out of a zip archive.
 *
 * Walks the central directory rather than scanning for local headers: a local
 * header may declare sizes of zero and defer them to a data descriptor, which
 * is exactly what some writers do, and guessing where the data ends from a
 * local header alone is how this kind of code quietly truncates a file.
 */
function readZipEntry(buffer, wanted) {
  // End of central directory, scanning back over the comment field.
  let eocd = -1;
  for (let i = buffer.length - 22; i >= 0 && i > buffer.length - 22 - 0xffff; i--) {
    if (buffer.readUInt32LE(i) === 0x06054b50) {
      eocd = i;
      break;
    }
  }
  if (eocd < 0) throw new Error('not a zip file: no end-of-central-directory record');

  const count = buffer.readUInt16LE(eocd + 10);
  let p = buffer.readUInt32LE(eocd + 16);

  for (let i = 0; i < count; i++) {
    if (buffer.readUInt32LE(p) !== 0x02014b50) {
      throw new Error(`corrupt central directory at entry ${i}`);
    }

    const method = buffer.readUInt16LE(p + 10);
    const compressedSize = buffer.readUInt32LE(p + 20);
    const nameLength = buffer.readUInt16LE(p + 28);
    const extraLength = buffer.readUInt16LE(p + 30);
    const commentLength = buffer.readUInt16LE(p + 32);
    const localOffset = buffer.readUInt32LE(p + 42);
    const name = buffer.toString('utf8', p + 46, p + 46 + nameLength);

    if (name === wanted) {
      // The local header repeats the name and extra fields with its own
      // lengths, and they are allowed to differ from the central copy.
      const localNameLength = buffer.readUInt16LE(localOffset + 26);
      const localExtraLength = buffer.readUInt16LE(localOffset + 28);
      const start = localOffset + 30 + localNameLength + localExtraLength;
      const data = buffer.subarray(start, start + compressedSize);

      if (method === 0) return data;
      if (method === 8) return zlib.inflateRawSync(data);
      throw new Error(`${name}: unsupported compression method ${method}`);
    }

    p += 46 + nameLength + extraLength + commentLength;
  }

  throw new Error(`${wanted} not found in archive`);
}

// --- WordprocessingML → text --------------------------------------------------

const decode = (s) =>
  s
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&#(\d+);/g, (_, n) => String.fromCharCode(Number(n)))
    // Last, so a literal "&amp;lt;" in the document survives as "&lt;".
    .replace(/&amp;/g, '&');

/** Every run of text in one `<w:p>`, with tabs and breaks collapsed to spaces. */
function paragraphText(p) {
  const parts = [];
  const re =
    /<w:(t|tab|br|cr)\b([^>]*)>([\s\S]*?)<\/w:\1>|<w:(tab|br|cr)\b[^>]*\/>/g;
  let m;
  while ((m = re.exec(p)) !== null) {
    const tag = m[1] ?? m[4];
    parts.push(tag === 't' ? decode(m[3]) : ' ');
  }
  return parts.join('').replace(/\s+/g, ' ').trim();
}

const styleOf = (p) => (p.match(/<w:pStyle w:val="([^"]+)"/) || [, ''])[1];

const paragraphsIn = (chunk) =>
  [...chunk.matchAll(/<w:p\b[^>]*>[\s\S]*?<\/w:p>/g)].map((m) => m[0]);

function renderTable(tbl) {
  const rows = [...tbl.matchAll(/<w:tr\b[^>]*>[\s\S]*?<\/w:tr>/g)].map((m) => m[0]);
  const lines = [];

  for (const tr of rows) {
    const cells = [...tr.matchAll(/<w:tc\b[^>]*>[\s\S]*?<\/w:tc>/g)].map((m) =>
      paragraphsIn(m[0]).map(paragraphText).filter(Boolean).join(' '),
    );
    if (cells.every((c) => !c)) continue;
    lines.push(`| ${cells.join(' | ')} |`);
  }

  return lines;
}

function convert(documentXml) {
  const body = documentXml.slice(
    documentXml.indexOf('<w:body>'),
    documentXml.lastIndexOf('</w:body>'),
  );

  // Document order, with a table taken whole so its paragraphs are not emitted
  // twice.
  const blocks = [
    ...body.matchAll(/<w:tbl>[\s\S]*?<\/w:tbl>|<w:p\b[^>]*>[\s\S]*?<\/w:p>/g),
  ].map((m) => m[0]);

  const out = [];
  let lastWasBlank = true;
  const push = (line) => {
    if (line === '') {
      if (lastWasBlank) return;
      lastWasBlank = true;
    } else {
      lastWasBlank = false;
    }
    out.push(line);
  };

  for (const block of blocks) {
    if (block.startsWith('<w:tbl')) {
      push('');
      for (const line of renderTable(block)) push(line);
      push('');
      continue;
    }

    const text = paragraphText(block);
    if (!text) continue;

    const style = styleOf(block);
    if (style === 'Heading1') {
      push('');
      push(`# ${text}`);
      push('');
    } else if (style === 'Heading2') {
      push('');
      push(`## ${text}`);
    } else {
      push(text);
    }
  }

  // Cover-block fix-up. The 2026-08-10 revision demoted the
  // Platforms/Technology/Interface/Date block from a Word table to four
  // label/value paragraph pairs, which convert to eight orphan lines. Pairing
  // them keeps the top of the file reading like the rest of the flattened
  // tables. No wording is changed; if a future revision makes it a table again
  // this does nothing.
  const coverLabels = ['Platforms', 'Technology', 'Interface options', 'Document date'];
  for (let i = out.length - 1; i >= 0; i--) {
    if (coverLabels.includes(out[i]) && out[i + 1] && !out[i + 1].startsWith('|')) {
      out.splice(i, 2, `| ${out[i]} | ${out[i + 1]} |`);
    }
  }

  return out.join('\n').replace(/\n{3,}/g, '\n\n');
}

// --- header -------------------------------------------------------------------

const defaultHeader = (sourceName) => `# Universal HeadHunter - Functional and Technical Specification

> **This is a generated, readable conversion of the client specification.**
>
> Canonical source: \`${sourceName}\`
> (client approval version, Tashkent 2026). If the client issues a revised
> .docx, regenerate this file and the copy in the sibling repo together - both
> \`headhunter-app/docs/SPEC.md\` and \`headhunter-backend/docs/SPEC.md\` must stay
> in sync with the same source document.
>
> Tables were flattened from Word tables; wording is otherwise verbatim so that
> business rules (BR-nn) and acceptance scenarios (UAT-nn) can be cited exactly.

---
`;

/**
 * The existing header, if there is one.
 *
 * Preserved rather than regenerated because the provenance note inside it
 * names *which* revision this is, and only a human knows that. Keeping it also
 * means a regeneration with no new source is a no-op, which is what makes
 * "both repos byte-identical" checkable with `git status`.
 */
function existingHeader(outPath) {
  if (!fs.existsSync(outPath)) return null;
  const current = fs.readFileSync(outPath, 'utf8').replace(/^\uFEFF/, '');
  const end = current.indexOf('\n---\n');
  if (!current.startsWith('# ') || end < 0) return null;
  return current.slice(0, end + '\n---\n'.length);
}

// --- main ---------------------------------------------------------------------

const [source, outArg] = process.argv.slice(2);

if (!source) {
  console.error('usage: node tool/spec_from_docx.js <source.docx> [output.md]');
  console.error('       run it for this repo and the backend with the same source');
  process.exit(2);
}

const outPath = outArg ?? path.join(__dirname, '..', 'docs', 'SPEC.md');

const xml = readZipEntry(fs.readFileSync(source), 'word/document.xml').toString('utf8');
const header = existingHeader(outPath) ?? defaultHeader(path.basename(source));
const body = convert(xml);

fs.writeFileSync(outPath, `${header}${body}\n`, 'utf8');

const rules = (body.match(/^\| BR-\d+/gm) || []).length;
const scenarios = (body.match(/^\| UAT-\d+/gm) || []).length;
console.log(
  `${outPath}: ${body.split('\n').length} lines, ${rules} business rules, ` +
    `${scenarios} acceptance scenarios`,
);
if (existingHeader(outPath) === null) {
  console.log('note: wrote a default header — edit the provenance line by hand');
}
