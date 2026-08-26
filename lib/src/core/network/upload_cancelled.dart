/// Thrown when the user cancelled an upload. **Not an error to report.**
///
/// Distinct from `ApiException` on purpose: a cancel is a thing somebody did,
/// and mapping it to a failure puts "the request failed" on screen a moment
/// after they pressed Cancel — which reads as the cancel itself having broken.
///
/// Lives in `core/` because two features upload: profile attachments (§5.4) and
/// message attachments (§9.1). It was in the profile repository until the
/// second one needed it.
library;

class UploadCancelled implements Exception {
  const UploadCancelled();

  @override
  String toString() => 'UploadCancelled()';
}
