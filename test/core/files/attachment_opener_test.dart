/// The two pure helpers, and the one Android file that must agree with them.
///
/// The download itself is not exercised here: it is dio plus a platform
/// channel, and a fake of both would only assert that the fake was called.
/// What *can* go wrong silently is the naming — a filename is content a
/// candidate typed (§2.4), and it decides where a file lands and which app
/// opens it.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/core/files/attachment_opener.dart';

/// A file's contents with its comments removed.
///
/// **Every assertion that a token is *absent* has to go through this.** Saying
/// in a comment why something is deliberately not there puts the token in the
/// file, and the test then fails on its own documentation. That happened three
/// times in one day — on `<monochrome`, on `external` and on
/// `FLAG_GRANT_WRITE_URI_PERMISSION` — which is why it is a named helper rather
/// than an inline `replaceAll`.
String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll(RegExp(r'<!--[\s\S]*?-->'), '')
    .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
    .replaceAll(RegExp('//.*'), '');

void main() {
  group('the local name is built from the id, never from the filename', () {
    test('an ordinary extension is carried over, lowercased', () {
      expect(AttachmentOpener.extensionOf('rezyume.PDF'), '.pdf');
      expect(AttachmentOpener.extensionOf('photo.jpeg'), '.jpeg');
    });

    test('a traversal attempt yields nothing', () {
      // The base name is always the server's file id, so the extension is the
      // only part of a candidate-supplied string that reaches the path. These
      // are the shapes that would matter if it did not.
      for (final hostile in [
        '../../shared_prefs/x.xml',
        'cv.pdf/../../../etc/passwd',
        r'cv..\..\secrets',
        'cv.',
        'cv',
        '.hidden',
        'cv.p df',
        'cv.тест',
      ]) {
        final extension = AttachmentOpener.extensionOf(hostile);
        expect(
          extension,
          anyOf(isEmpty, matches(r'^\.[a-z0-9]{1,8}$')),
          reason: hostile,
        );
        expect(extension.contains('/'), isFalse, reason: hostile);
        expect(extension.contains(r'\'), isFalse, reason: hostile);
        expect(extension.contains('..'), isFalse, reason: hostile);
      }
    });

    test('an absurdly long extension is refused rather than truncated', () {
      // Truncating would invent an extension the file does not have, and the OS
      // would pick a viewer on it.
      expect(AttachmentOpener.extensionOf('cv.superlongextension'), '');
    });
  });

  group('the MIME type', () {
    test('names the types a candidate actually attaches', () {
      expect(AttachmentOpener.mimeTypeOf('cv.pdf'), 'application/pdf');
      expect(AttachmentOpener.mimeTypeOf('photo.png'), 'image/png');
      expect(AttachmentOpener.mimeTypeOf('sertifikat.jpg'), 'image/jpeg');
    });

    test('falls back to a wildcard rather than to null', () {
      // Some viewers register for one concrete type and nothing else, so a
      // wildcard at least lets the system offer a chooser instead of failing.
      expect(AttachmentOpener.mimeTypeOf('cv.zip'), '*/*');
      expect(AttachmentOpener.mimeTypeOf('cv'), '*/*');
    });
  });

  group('the Android side agrees with the Dart side', () {
    test('the FileProvider is scoped to the directory the opener writes', () {
      // Two files, one directory name. If they drift, `getUriForFile` throws at
      // the moment an employer taps a CV — and nothing in the Dart toolchain
      // would notice, because `flutter analyze` does not read Android XML.
      final paths = _code('android/app/src/main/res/xml/file_paths.xml');

      expect(paths.contains('<cache-path'), isTrue);
      expect(paths.contains('path="attachments/"'), isTrue);
      // Never external storage: a candidate's CV there is readable by other
      // apps and survives an uninstall, the opposite of what §11.1 asks.
      expect(paths.contains('external'), isFalse);
    });

    test('the channel name matches the one MainActivity registers', () {
      final kotlin = File(
        'android/app/src/main/kotlin/com/jobbridge/app/MainActivity.kt',
      ).readAsStringSync();

      expect(
        kotlin.contains('"${AttachmentOpener.channelName}"'),
        isTrue,
        reason: 'a renamed channel fails only at runtime, on a tap',
      );
    });

    test('the provider authority follows the flavor, not a literal', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      // Three flavors, three application ids. Two installed apps cannot declare
      // the same provider authority, so a hard-coded one would make the
      // side-by-side installs of §12.1 fail at install time.
      expect(
        manifest.contains(
          r'android:authorities="${applicationId}.fileprovider"',
        ),
        isTrue,
      );
      expect(manifest.contains('android:exported="false"'), isTrue);
      expect(manifest.contains('android:grantUriPermissions="true"'), isTrue);
    });

    test('the intent grants read and never write', () {
      final kotlin = _code(
        'android/app/src/main/kotlin/com/jobbridge/app/MainActivity.kt',
      );

      expect(kotlin.contains('FLAG_GRANT_READ_URI_PERMISSION'), isTrue);
      expect(
        kotlin.contains('FLAG_GRANT_WRITE_URI_PERMISSION'),
        isFalse,
        reason: 'a viewer has no business editing a candidate’s CV',
      );
    });

    test('the channel refuses a path outside the attachment cache', () {
      final kotlin = File(
        'android/app/src/main/kotlin/com/jobbridge/app/MainActivity.kt',
      ).readAsStringSync();

      // Defence in depth: FileProvider already refuses a path outside its
      // declared roots, and the app-private directory next door holds the
      // secure token store. A channel that could be talked into naming an
      // arbitrary file would be the one way this app hands out something nobody
      // was entitled to.
      expect(kotlin.contains('canonicalPath'), isTrue);
    });
  });
}
