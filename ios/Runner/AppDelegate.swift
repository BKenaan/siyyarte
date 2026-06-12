import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// Secure-field capture shield (the HSBC-style technique): when the app's
  /// window layer is hosted inside a `UITextField` with `isSecureTextEntry`,
  /// iOS omits it from screenshots and screen recordings — they come out
  /// black. Toggled from Dart over the same channel as Android's FLAG_SECURE.
  private let secureField = UITextField()
  private var secureInstalled = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "siyyarte/secure_screen",
        binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "setSecure" else {
          result(FlutterMethodNotImplemented)
          return
        }
        let secure = (call.arguments as? Bool) ?? false
        DispatchQueue.main.async { self?.setSecure(secure) }
        result(nil)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setSecure(_ secure: Bool) {
    guard let window = self.window else { return }
    if secure && !secureInstalled {
      secureField.isSecureTextEntry = true
      secureField.isUserInteractionEnabled = false
      window.addSubview(secureField)
      // Host the window's layer inside the secure field's canvas layer so the
      // capture pipeline drops the whole window.
      window.layer.superlayer?.addSublayer(secureField.layer)
      secureField.layer.sublayers?.last?.addSublayer(window.layer)
      secureInstalled = true
    } else if !secure && secureInstalled {
      secureField.isSecureTextEntry = false
      secureInstalled = false
    } else {
      secureField.isSecureTextEntry = secure
    }
  }
}
