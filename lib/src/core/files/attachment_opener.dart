import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attachment_opener.g.dart';

/// No installed application can display the file that was downloaded.
///
/// Its own type rather than an [ApiException]: nothing failed on the server,
/// the bytes arrived, and the remedy is on the device. Rendering it as a
/// request failure would send an employer looking for a network problem.
class NoViewerException implements Exception {
  const NoViewerException();
}

/// Fetches an attachment the server has authorised and hands it to the OS.
///
/// ## The path comes from the server and is never built here
///
/// A file's `downloadPath` is scoped to whatever entitled this employer to it —
/// `/applications/…` for one holding an application, `/invitations/…` for one
/// whose invitation was accepted, `/unlocks/…` for one who paid. Three routes
/// for the same CV, so constructing any of them would work for a third of the
/// cases. This class takes the path as data and appends nothing.
///
/// ## Every open re-downloads, deliberately
///
/// BR-09 is re-evaluated on **every** download, which is the whole reason the
/// path is server-built: holding a path is not holding permission. So a cached
/// copy is never served — a candidate who withdraws must stop being readable
/// mid-session, and reusing bytes already on disk would defeat exactly the
/// check the server performs. The file is written to the same name each time,
/// so repeated opens overwrite rather than accumulate.
///
/// ## Why there is no plugin behind this
///
/// Opening a file needs native code, and every pub package that does it is
/// written in Kotlin and therefore **applies the Kotlin Gradle Plugin** — a
/// build warning this project deliberately emptied on 2026-08-19 by removing
/// `telegram_login`, and one future Flutter versions will refuse outright. The
/// app's *own* Kotlin is not a plugin and does not appear on that list, so the
/// hand-off is thirty lines in `MainActivity.kt` behind this channel.
class AttachmentOpener {
  const AttachmentOpener(this._dio, {MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  final Dio _dio;
  final MethodChannel _channel;

  /// Must match the name `MainActivity.kt` registers.
  static const channelName = 'com.jobbridge.app/attachments';

  /// The cache subdirectory the FileProvider is declared over.
  ///
  /// `res/xml/file_paths.xml` exposes exactly this one directory and nothing
  /// else, so a bug here cannot turn into a way to read the token store.
  static const _subdirectory = 'attachments';

  /// Downloads [downloadPath] and asks the OS to display it.
  ///
  /// Throws [ApiException] if the server refuses or the request fails, and
  /// [NoViewerException] if the download succeeded but nothing on the device
  /// can open it.
  Future<void> open({
    required String downloadPath,
    required String fileId,
    required String fileName,
  }) async {
    final Uint8List bytes;
    try {
      final response = await _dio.get<List<int>>(
        downloadPath,
        options: Options(responseType: ResponseType.bytes),
      );

      final body = response.data;
      if (body == null || body.isEmpty) {
        throw const ApiException('The server returned an empty file.');
      }
      bytes = Uint8List.fromList(body);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }

    final directory = Directory(
      '${(await getTemporaryDirectory()).path}/$_subdirectory',
    );
    await directory.create(recursive: true);

    // Named from the **server's file id**, never from `fileName`. The filename
    // is content the candidate typed (§2.4), so using it as a path segment
    // would let a name like `../../shared_prefs/x` write outside the directory
    // the FileProvider is scoped to. Only a validated extension is carried
    // over, because that is all the OS needs to pick a viewer.
    final file = File('${directory.path}/$fileId${extensionOf(fileName)}');
    await file.writeAsBytes(bytes, flush: true);

    try {
      await _channel.invokeMethod<void>('open', {
        'path': file.path,
        'mimeType': mimeTypeOf(fileName),
      });
    } on PlatformException catch (e) {
      if (e.code == 'no_viewer') throw const NoViewerException();
      // Anything else is a bug in the channel rather than a condition to
      // render, so it keeps its stack rather than becoming a friendly message.
      rethrow;
    }
  }

  /// The dotted extension of [fileName], or empty when there is nothing safe.
  ///
  /// Deliberately strict: letters and digits only, at most eight of them. A
  /// filename with no extension, a suspicious one, or path separators in it
  /// yields nothing and the OS falls back to the MIME type.
  static String extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';

    final candidate = fileName.substring(dot + 1);
    if (!RegExp(r'^[A-Za-z0-9]{1,8}$').hasMatch(candidate)) return '';

    return '.${candidate.toLowerCase()}';
  }

  /// A MIME type for the viewer to match on.
  ///
  /// `*/*` rather than null for anything unrecognised: some viewers register for
  /// a concrete type and nothing else, and a wildcard at least lets the system
  /// offer a chooser instead of failing outright.
  static String mimeTypeOf(String fileName) => switch (extensionOf(fileName)) {
    '.pdf' => 'application/pdf',
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.png' => 'image/png',
    '.webp' => 'image/webp',
    '.heic' => 'image/heic',
    '.doc' => 'application/msword',
    '.docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    _ => '*/*',
  };
}

@riverpod
AttachmentOpener attachmentOpener(Ref ref) =>
    AttachmentOpener(ref.watch(dioProvider));
