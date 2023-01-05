import Flutter
import UIKit
import TnkRwdSdk

public class SwiftTnkFlutterRwdPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tnk_flutter_rwd", binaryMessenger: registrar.messenger())
    let instance = SwiftTnkFlutterRwdPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let viewController = UIApplication.shared.keyWindow?.rootViewController
      switch call.method {
        case "setCOPPA":
        if let args = call.arguments as? Dictionary<String, Any>,
           let coppa = args["coppa"] as? Bool {
            TnkSession.sharedInstance().setCOPPA(coppa)
        } else{
            TnkSession.sharedInstance().setCOPPA(false)
        }
        result("success")
        break;
        case "showAdList":
        if let args = call.arguments as? Dictionary<String, Any>,
           let title = args["title"] as? String {
            TnkSession.sharedInstance().showAdList(asModal:viewController, title: title)
        } else{
            TnkSession.sharedInstance().showAdList(asModal:viewController, title: "충전소")
        }
        result("success")
        break;
        case "setUserName":
            if let args = call.arguments as? Dictionary<String, Any>{
                if let userName = args["user_name"] as? String {
                    TnkSession.sharedInstance().setUserName(userName)
                    result("success")
                } else {
                    result("fail")
                }
            }else{
                result("fail")
            }
            break;
        case "platformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break;
        default:
            result("iOS method : " + call.method)
            break;
        }
  }
    
    func getViewController() -> FlutterViewController? {
        var topMostViewControllerObj = UIApplication.shared.delegate!.window!!.rootViewController!;
        var flutterViewController = topMostViewControllerObj as? FlutterViewController
            
            return flutterViewController;
    }
}
