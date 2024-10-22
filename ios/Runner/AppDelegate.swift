import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyC4H_uA8IR-AQxYhxt2RyEzT5megas7SVY")
        GeneratedPluginRegistrant.register(with: self)
        return true
    }
}
