import Flutter
import UIKit
import Foundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let icloudChannel = FlutterMethodChannel(name: "VaultDeck/icloud",
                                              binaryMessenger: controller.binaryMessenger)
    icloudChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "saveToICloud" {
        guard let args = call.arguments as? [String: Any],
              let fileName = args["fileName"] as? String,
              let content = args["content"] as? String else {
          result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
          return
        }
        self.saveToICloud(fileName: fileName, content: content, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func saveToICloud(fileName: String, content: String, result: @escaping FlutterResult) {
    let fileManager = FileManager.default
    if let icloudUrl = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
      let fileUrl = icloudUrl.appendingPathComponent(fileName)
      do {
        try fileManager.createDirectory(at: icloudUrl, withIntermediateDirectories: true, attributes: nil)
        try content.write(to: fileUrl, atomically: true, encoding: .utf8)
        result("File saved to iCloud Drive: \(fileUrl.path)")
      } catch {
        result(FlutterError(code: "SAVE_FAILED", message: "Failed to save file", details: error.localizedDescription))
      }
    } else {
      result(FlutterError(code: "NO_ICLOUD", message: "iCloud Drive not available", details: nil))
    }
  }
}
