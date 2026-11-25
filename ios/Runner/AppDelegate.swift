import Flutter
import QuickLook
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "JobBridgeChannels") {
      JobBridgeChannels.register(with: registrar)
    }
  }
}

/// The app's own native code on iOS: the same three channels `MainActivity.kt`
/// carries on Android, with the same names, methods and error codes, because the
/// Dart side is one implementation for both.
///
/// *Why not plugins.* On Android the reason was the Kotlin Gradle Plugin; here
/// there is no such list, but the Dart classes behind these channels already
/// exist and are tested, and `url_launcher`, `open_filex` and
/// `package_info_plus` would each replace one of them with a second
/// implementation to keep in step.
///
/// The error codes are the contract: `AttachmentOpener` turns `no_viewer` into
/// its own exception and `LinkOpener` does the same with `no_browser`. Anything
/// else is rethrown as a bug.
final class JobBridgeChannels: NSObject, QLPreviewControllerDataSource {
  /// Must match `AttachmentOpener.channelName`.
  static let attachmentsChannel = "com.jobbridge.app/attachments"

  /// Must match `PushPlatform.channelName`.
  static let pushChannel = "com.jobbridge.app/push"

  /// Must match `LinkOpener.channelName`.
  static let linksChannel = "com.jobbridge.app/links"

  /// The one subdirectory `AttachmentOpener` writes into.
  static let attachmentsDirectory = "attachments"

  /// What Quick Look is currently showing. Its data source is weak, so the
  /// channels object - which the handlers below keep alive - holds the item.
  private var previewItem: URL?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channels = JobBridgeChannels()
    let messenger = registrar.messenger()

    FlutterMethodChannel(name: attachmentsChannel, binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        switch call.method {
        case "open": channels.openAttachment(call, result: result)
        default: result(FlutterMethodNotImplemented)
        }
      }

    FlutterMethodChannel(name: pushChannel, binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        switch call.method {
        // A notification channel is an Android concept: iOS has one place per
        // app in Settings, with no name for the app to give it. Success is the
        // honest answer - the caller asked for notifications to be deliverable
        // and on iOS they already are.
        case "configureChannel": result(nil)
        case "appVersion": result(JobBridgeChannels.appVersion())
        default: result(FlutterMethodNotImplemented)
        }
      }

    FlutterMethodChannel(name: linksChannel, binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        switch call.method {
        case "open": channels.openLink(call, result: result)
        default: result(FlutterMethodNotImplemented)
        }
      }
  }

  // MARK: - /links

  /// Hands a web page to the browser - the privacy policy the sign-in consent
  /// names (§4.1 step 2).
  ///
  /// **https and nothing else**, as on Android: `UIApplication.open` would
  /// start whatever a URL names - `tel:`, another app's scheme - and every link
  /// this app shows is a web page.
  private func openLink(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let raw = (call.arguments as? [String: Any])?["url"] as? String,
      let url = URL(string: raw),
      url.scheme == "https",
      let host = url.host, !host.isEmpty
    else {
      result(FlutterError(code: "bad_argument", message: "an https URL is required", details: nil))
      return
    }

    UIApplication.shared.open(url, options: [:]) { opened in
      if opened {
        result(nil)
      } else {
        result(FlutterError(
          code: "no_browser", message: "No installed app can open this link.", details: nil))
      }
    }
  }

  // MARK: - /push

  /// `CFBundleShortVersionString (CFBundleVersion)` - the same shape Android
  /// reports, for `POST /notifications/devices`. Both come from `pubspec.yaml`
  /// through Flutter's build settings, so this cannot drift from a release.
  ///
  /// Trimmed to the DTO's 40 characters, and null when the bundle cannot say:
  /// the field is optional, and a device that cannot name itself must still
  /// register.
  private static func appVersion() -> String? {
    guard let name = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
      return nil
    }
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    let version = build.map { "\(name) (\($0))" } ?? name
    return String(version.prefix(40))
  }

  // MARK: - /attachments

  /// Shows a downloaded attachment in Quick Look - PDF, images and Word files
  /// all preview natively - and offers the share sheet for anything Quick Look
  /// cannot read, so the file can still be saved or handed to another app.
  private func openAttachment(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let path = (call.arguments as? [String: Any])?["path"] as? String else {
      result(FlutterError(code: "bad_argument", message: "path is required", details: nil))
      return
    }

    let file = URL(fileURLWithPath: path)

    // Defence in depth, as on Android: the directory these files live in sits
    // beside the app's other private data, and a channel that could be talked
    // into presenting an arbitrary path would be the one way this app hands out
    // a file nobody was entitled to.
    guard JobBridgeChannels.isInAttachmentCache(file) else {
      result(FlutterError(
        code: "bad_argument", message: "path is outside the attachment cache", details: nil))
      return
    }

    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: file.path, isDirectory: &isDirectory),
      !isDirectory.boolValue
    else {
      result(FlutterError(code: "bad_argument", message: "no such file", details: nil))
      return
    }

    guard let presenter = JobBridgeChannels.topViewController() else {
      result(FlutterError(
        code: "no_viewer", message: "Nothing is on screen to show the file over.", details: nil))
      return
    }

    if QLPreviewController.canPreview(file as NSURL) {
      previewItem = file
      let preview = QLPreviewController()
      preview.dataSource = self
      presenter.present(preview, animated: true)
    } else {
      let share = UIActivityViewController(activityItems: [file], applicationActivities: nil)
      share.popoverPresentationController?.sourceView = presenter.view
      presenter.present(share, animated: true)
    }
    result(nil)
  }

  /// Whether [file] is inside an `attachments` directory the Dart side writes.
  ///
  /// Both the temporary and the caches directory are accepted because
  /// `path_provider`'s `getTemporaryDirectory()` is documented as
  /// `NSCachesDirectory` on iOS, and accepting only the one this code expects
  /// would turn a plugin's choice into a CV that never opens. Symlinks are
  /// resolved on both sides: iOS reports the same container as `/var/…` and
  /// `/private/var/…`.
  private static func isInAttachmentCache(_ file: URL) -> Bool {
    let target = file.resolvingSymlinksInPath().standardizedFileURL.path
    let manager = FileManager.default

    var roots = [manager.temporaryDirectory]
    roots.append(contentsOf: manager.urls(for: .cachesDirectory, in: .userDomainMask))

    return roots.contains { root in
      let directory = root.appendingPathComponent(attachmentsDirectory, isDirectory: true)
        .resolvingSymlinksInPath().standardizedFileURL.path
      return target.hasPrefix(directory + "/")
    }
  }

  /// The view controller on top of the key window, to present over.
  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let windows = scenes.flatMap { $0.windows }
    var top = (windows.first(where: { $0.isKeyWindow }) ?? windows.first)?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  // MARK: - QLPreviewControllerDataSource

  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    return previewItem == nil ? 0 : 1
  }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int)
    -> QLPreviewItem
  {
    return (previewItem ?? URL(fileURLWithPath: "/")) as NSURL
  }
}
