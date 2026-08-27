/// The verbs, the paths and the multipart field names `EvidenceRepository`
/// actually puts on the wire.
///
/// Employer verification evidence goes through the **generic** `/files`, not
/// through `/candidates/me/attachments`, and the two differ in more than the
/// path: `/files` takes the purpose as a form field named `purpose` and reads
/// the bytes from a part named `file`, and a mismatch in either is a 400 that
/// says nothing about which of the two was wrong.
///
/// Faking the repository would test everything above this and nothing about the
/// wire, which is how §9.2's two mark-read routes shipped as `POST` against
/// `@Put` and 404'd for two releases with nothing red (MT-020). So this drives
/// the real repository through a recording adapter, and the last case reads the
/// backend's own decorators.
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/employer/data/evidence_repository.dart';

/// A distinctive stand-in, so a concrete path can be turned back into the
/// template the backend declares.
const _id = 'a0000000-0000-4000-8000-000000000000';

const _purpose = 'company_registration';

/// Answers the way the real routes do: `POST` returns the stored file, `GET`
/// returns `{files: […]}`, `DELETE` is 204 with no body.
class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    if (options.method == 'DELETE') return ResponseBody.fromString('', 204);

    final body = options.method == 'GET'
        ? '{"files":[{"id":"$_id","purposeId":"$_id",'
              '"purposeCode":"$_purpose","fileName":"reg.pdf",'
              '"mimeType":"application/pdf","sizeBytes":3,'
              '"createdAt":"2026-08-28T10:00:00+05:00",'
              '"downloadPath":"/files/$_id/content"}]}'
        : '{"id":"$_id","purposeId":"$_id","purposeCode":"$_purpose",'
              '"fileName":"reg.pdf","mimeType":"application/pdf",'
              '"sizeBytes":3,"createdAt":"2026-08-28T10:00:00+05:00",'
              '"downloadPath":"/files/$_id/content"}';

    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Drives every method on the repository once, in a fixed order.
///
/// One helper rather than a request per test, so the route table and the
/// backend comparison come from the same run: a method that stops being
/// exercised disappears from both at once rather than leaving one of them
/// quietly asserting nothing.
Future<List<RequestOptions>> _exerciseEveryRoute(File scan) async {
  final adapter = _Adapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
  final repository = EvidenceRepository(dio);

  await repository.list();
  await repository.list(purposeCode: _purpose);
  await repository.upload(
    purposeCode: _purpose,
    filePath: scan.path,
    fileName: 'reg.pdf',
  );
  await repository.remove(_id);

  return adapter.requests;
}

String _route(RequestOptions request) =>
    '${request.method} ${request.path.replaceAll('/$_id', '/:id')}';

/// Every `@Get`/`@Post`/`@Put`/`@Patch`/`@Delete` in a Nest controller, as
/// `VERB /full/path`.
Set<String> _declaredRoutes(String source) {
  final base = RegExp(r"@Controller\('([^']*)'\)").firstMatch(source);
  expect(base, isNotNull, reason: 'no @Controller() in the backend source');

  return RegExp(
        r"^\s*@(Get|Post|Put|Patch|Delete)\((?:'([^']*)')?\)",
        multiLine: true,
      )
      .allMatches(source)
      .map((match) {
        final verb = match.group(1)!.toUpperCase();
        final path = match.group(2) ?? '';
        return '$verb /${base!.group(1)}${path.isEmpty ? '' : '/$path'}';
      })
      .toSet();
}

void main() {
  late Directory temp;
  late File scan;

  setUpAll(() {
    temp = Directory.systemTemp.createTempSync('evidence_test');
    scan = File('${temp.path}/reg.pdf')..writeAsBytesSync([37, 80, 68]);
  });

  tearDownAll(() {
    // `MultipartFile.fromFile` streams lazily and Windows refuses to unlink a
    // file with an open handle, so this throws there and only there. The temp
    // directory is the OS's to clean up; failing the suite over it would make
    // the tests pass on one platform and not the other for no useful reason.
    try {
      temp.deleteSync(recursive: true);
    } on FileSystemException {
      // Left for the OS.
    }
  });

  group('the wire contract', () {
    test('every route uses the verb and path the server declares', () async {
      final requests = await _exerciseEveryRoute(scan);

      // Written out rather than derived: this list *is* the claim, and deriving
      // it from the repository would only make it agree with itself.
      expect(requests.map(_route), [
        'GET /files',
        'GET /files',
        'POST /files',
        'DELETE /files/:id',
      ]);
    });

    test('a purpose filter is a query parameter, not a path segment', () async {
      final requests = await _exerciseEveryRoute(scan);

      // `ListFilesQueryDto.purpose` — and the unfiltered call must send no
      // `purpose` at all rather than an empty one, which would filter on the
      // empty code and return nothing.
      expect(requests[0].queryParameters, isEmpty);
      expect(requests[1].queryParameters, {'purpose': _purpose});
    });

    test('the upload names the parts the server reads', () async {
      final requests = await _exerciseEveryRoute(scan);
      final upload = requests.singleWhere((r) => r.method == 'POST');

      final form = upload.data as FormData;

      // `purpose` is the **code**, matching what `requiredEvidence` names and
      // what `FilesService.store` resolves. Sending the dictionary id here
      // compiles, uploads, and is refused as `file.purpose_invalid`.
      //
      // Compared as strings because `MapEntry` has no `==`: two identical
      // entries are never equal, so a direct comparison fails while printing
      // two lines that read the same.
      expect(form.fields.map((f) => '${f.key}=${f.value}'), [
        'purpose=$_purpose',
      ]);
      // `FileInterceptor('file')` reads exactly this part name.
      expect(form.files.map((f) => f.key), ['file']);
      expect(form.files.single.value.filename, 'reg.pdf');
    });

    test('a list response is read from `files`, not the root', () async {
      final adapter = _Adapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter;

      final files = await EvidenceRepository(dio).list();

      // `FileListResponseDto` wraps them. Reading the root would silently
      // return nothing, and an employer would be told to upload a document
      // they had already uploaded.
      expect(files, hasLength(1));
      expect(files.single.purposeCode, _purpose);
      expect(files.single.id, _id);
    });
  });

  // The backend is a sibling checkout, reachable from a session rooted here
  // through permissions.additionalDirectories. It is **not** on CI, so this is
  // skipped there rather than failing a runner that has one repo.
  final controller = File(
    '../headhunter-backend/src/modules/files/files.controller.ts',
  );
  final absent = !controller.existsSync()
      ? 'headhunter-backend is not checked out beside this repo, so the '
            'controller cannot be read. See CLAUDE.md for the layout.'
      : null;

  group('against the backend controller', () {
    test('the client calls nothing the controller does not declare', () async {
      final declared = _declaredRoutes(controller.readAsStringSync());
      final called = (await _exerciseEveryRoute(scan)).map(_route).toSet();

      final table = (declared.toList()..sort()).join('\n  ');

      expect(
        called.difference(declared),
        isEmpty,
        reason: 'the controller declares:\n  $table',
      );
    });

    test('the response carries the purpose as a code, not only an id', () {
      final source = controller.readAsStringSync();

      // The whole reason the evidence card can match a file to a slot. `/files`
      // returned `purposeId` alone until 2026-08-28, so a client had to resolve
      // the dictionary before it could tell which document it just uploaded —
      // the id/code confusion CLAUDE.md warns about, one layer down.
      expect(source, contains('purposeCode: file.purposeCode'));
    });
  }, skip: absent);
}
