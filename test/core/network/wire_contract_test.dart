/// Every path this app puts on the wire, checked against the routes the API
/// declares.
///
/// ## Why a sweep rather than a table per repository
///
/// §9.2's two mark-read routes shipped as `POST` against a `@Put` and 404'd for
/// two whole releases with nothing red (MT-020). The reason nothing caught it
/// is that every test faked the repository at its own boundary, so the one
/// property that was wrong — the verb — was the one property nothing asserted.
///
/// Five repositories now drive a recording adapter, which is the right shape
/// for checking a *request*: its query parameters, its multipart field names,
/// its body. But writing fifteen more of those would take a week and would
/// still cover only what somebody remembered to exercise, and a repository
/// added next month would start uncovered again.
///
/// So this reads the source instead. Every `_dio.get`/`post`/`put`/`patch`/
/// `delete` in the repository layer, against every `@Get`/`@Post`/`@Put`/
/// `@Patch`/`@Delete` in the backend's controllers. It cannot see a wrong body
/// or a missing query parameter — the driven tests are still worth writing for
/// the routes that matter most — but it catches a wrong verb and a wrong path
/// **for every repository, including ones that do not exist yet**, which is
/// exactly the class of bug that shipped twice.
///
/// ## It is a developer-machine check
///
/// The backend is a sibling checkout reachable through
/// `permissions.additionalDirectories`; CI has one repo, so this skips there
/// rather than failing a runner that cannot see the other side.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A path with its interpolations reduced to the server's placeholder shape.
///
/// `'/admin/wallets/$userId'` and `@Get(':userId')` are the same route written
/// two ways, and every id in this product is a uuid — there is no route where
/// one segment is a literal and another is an id of the same name, so
/// collapsing both sides to `:param` cannot merge two different routes.
String _normalize(String path) => path
    .replaceAll(RegExp(r'\$\{[^}]*\}'), ':param')
    .replaceAll(RegExp(r'\$[a-zA-Z_][a-zA-Z0-9_]*'), ':param')
    .replaceAll(RegExp(':[a-zA-Z_][a-zA-Z0-9_]*'), ':param');

/// `VERB /path` for every dio call in a repository source file.
///
/// The path is dio's first positional argument, which is a string literal in
/// every repository here — the layer exists precisely so that a path is written
/// once, in one place, next to the type it parses.
Set<String> _clientRoutes(String source) => RegExp(
  // The type argument is optional and **nests**: `<Map<String, dynamic>>` is
  // the common one, and a pattern that stopped at the first `>` silently saw
  // only the `<void>` calls — a sweep that misses most of what it claims to
  // cover is worse than none, because the green tells you it looked.
  r"""_dio\s*\.\s*(get|post|put|patch|delete)\s*(?:<[^()\n]*>)?\s*\(\s*'([^']*)'""",
  multiLine: true,
).allMatches(source).map((match) {
  final verb = match.group(1)!.toUpperCase();
  return '$verb ${_normalize(match.group(2)!)}';
}).toSet();

/// `VERB /full/path` for every route a Nest controller declares.
Set<String> _serverRoutes(String source) {
  // `@Controller()` with **no argument** is legitimate and used: the
  // applications module declares full paths on each method because its routes
  // hang off two different nouns. A pattern that required a quoted base
  // skipped that whole controller, and every route in it then looked like a
  // client calling something that does not exist.
  final controller = RegExp(
    r"@Controller\(\s*(?:'([^']*)')?\s*\)",
  ).firstMatch(source);
  if (controller == null) return const {};

  final base = controller.group(1) ?? '';

  return RegExp(
        r"^\s*@(Get|Post|Put|Patch|Delete)\(\s*(?:'([^']*)')?\s*\)",
        multiLine: true,
      )
      .allMatches(source)
      .map((match) {
        final verb = match.group(1)!.toUpperCase();
        final path = match.group(2) ?? '';
        final full = [
          base,
          path,
        ].where((part) => part.isNotEmpty).join('/');
        return '$verb ${_normalize('/$full')}';
      })
      .toSet();
}

/// A file's path with forward slashes, whatever the platform.
///
/// `File.uri` rather than a separator swap, because writing a backslash as a
/// literal here is a fight between `use_raw_strings` and
/// `unnecessary_raw_strings` that neither side wins.
String _posix(File file) => file.uri.path;

/// Whether a normalized route can be compared with a declared one at all.
///
/// Two shapes cannot: a path whose **first** segment is interpolated
/// (`'$path/$id'` — the base is the caller's argument), and one where an
/// interpolation is glued to a literal rather than being a whole segment
/// (`'/auth/otp$suffix'`). Both are legitimate; neither resolves to one route.
///
/// They are listed by name below rather than skipped silently: a new one has to
/// be acknowledged, because a sweep that quietly drops what it cannot read is
/// how a hole stays green.
bool _checkable(String route) {
  final path = route.split(' ').last;
  if (!path.startsWith('/')) return false;

  return path
      .split('/')
      .every((segment) => !segment.contains(':') || segment == ':param');
}

Iterable<File> _dartFiles(Directory root, String suffix) => root
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => _posix(file).endsWith(suffix));

void main() {
  final backend = Directory('../headhunter-backend/src/modules');
  final absent = !backend.existsSync()
      ? 'headhunter-backend is not checked out beside this repo, so its '
            'controllers cannot be read. See CLAUDE.md for the layout.'
      : null;

  final repositories = _dartFiles(
    Directory('lib/src/features'),
    'repository.dart',
  ).toList();

  test('the repository layer is where paths are written', () {
    // If this ever fails, the sweep below has stopped covering the app rather
    // than the app having stopped putting paths on the wire — a `_dio` call
    // outside a `*repository.dart` is invisible to it.
    final strays = _dartFiles(Directory('lib/src'), '.dart')
        .where((file) => !_posix(file).endsWith('repository.dart'))
        .where((file) => _clientRoutes(file.readAsStringSync()).isNotEmpty)
        .map(_posix)
        .toList();

    expect(
      strays,
      isEmpty,
      reason: 'these files call dio directly instead of through a repository',
    );
  });

  test('every repository has at least one route the sweep can see', () {
    // A repository whose paths this cannot extract would pass the check below
    // by contributing nothing, which is the failure mode a source-reading test
    // has and a driven one does not.
    final silent = repositories
        .where((file) => _clientRoutes(file.readAsStringSync()).isEmpty)
        .map(_posix)
        .toList();

    expect(
      silent,
      isEmpty,
      reason: 'no dio call could be extracted from these — the sweep is blind '
          'to them, so either they are not repositories or the pattern in '
          '_clientRoutes needs widening',
    );
  });

  test('every path this cannot resolve is one somebody chose', () {
    final unresolvable = <String>{};
    for (final file in repositories) {
      unresolvable.addAll(
        _clientRoutes(file.readAsStringSync()).where((r) => !_checkable(r)),
      );
    }

    // Written out, so adding a path the sweep cannot read is a deliberate act.
    // Both of these resolve to routes the server declares:
    //   /auth/otp/send, /auth/otp/resend  — `suffix` is one of two literals
    //   /candidates/me/{experience,education}/:id — `path` is the caller's
    expect((unresolvable.toList()..sort()).join('\n'), '''
DELETE :param/:param
POST /auth/otp:param
PUT :param/:param''');
  });

  group('against the backend controllers', () {
    test('the client calls nothing the server does not declare', () {
      final declared = <String>{};
      for (final file in _dartFiles(backend, '.controller.ts')) {
        declared.addAll(_serverRoutes(file.readAsStringSync()));
      }

      expect(
        declared,
        isNotEmpty,
        reason: 'no controller routes were found — the backend layout moved',
      );

      final undeclared = <String, List<String>>{};
      for (final file in repositories) {
        final called = _clientRoutes(
          file.readAsStringSync(),
        ).where(_checkable).toSet();
        final missing = called.difference(declared).toList()..sort();
        if (missing.isNotEmpty) {
          undeclared[_posix(file)] = missing;
        }
      }

      final table = (declared.toList()..sort()).join('\n  ');

      expect(
        undeclared,
        isEmpty,
        reason:
            'each of these is a call the API would answer 404 or 405 — the '
            'shape of MT-020. The server declares:\n  $table',
      );
    });
  }, skip: absent);
}
