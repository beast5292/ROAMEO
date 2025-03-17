import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register the Google Maps API Key
    GMSServices.provideAPIKey("AIzaSyAg21v8IM9kqOP0lUMABZTanTt_QnpK9AE") // Replace with your API key

    // Register plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Return the result of the super method to complete the app launch process
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
