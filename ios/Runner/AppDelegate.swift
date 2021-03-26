import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
		override func application(
				_ application: UIApplication,
				didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
		) -> Bool {

				GeneratedPluginRegistrant.register(with: self)
		  	FlutterShowViewPlugin.register(with: registrar(forPlugin: "FlutterShowPlugin")!)
			  FlutterCollectViewPlugin.register(with: registrar(forPlugin: "FlutterCollectPlugin")!)
				return super.application(application, didFinishLaunchingWithOptions: launchOptions)
		}
}

public class FlutterShowViewPlugin {
 class func register(with registrar: FlutterPluginRegistrar) {
	 let viewFactory = FlutterShowViewFactory(messenger: registrar.messenger())
	 registrar.register(viewFactory, withId: "card-show-form-view")
 }
}

public class FlutterCollectViewPlugin {
 class func register(with registrar: FlutterPluginRegistrar) {
	 let viewFactory = FlutterCollectViewFactory(messenger: registrar.messenger())
	 registrar.register(viewFactory, withId: "card-collect-form-view")
 }
}
