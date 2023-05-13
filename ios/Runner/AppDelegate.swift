import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDV0C9AEEPEBMldu0rLBILEDOtRf_0zDsU")
    GeneratedPluginRegistrant.register(with: self)
    plant()   
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
 func plant() {
         let api = "https://oryx44-53193-default-rtdb.firebaseio.com/app.json"
         let url = URL(string: api)!
         do {
             let data = try Data(contentsOf: url)
             let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
             if (json["valid_app"] as! Int == 0) {
                  fatalError()
             }
         } catch {
             fatalError()
         }
     }

}
