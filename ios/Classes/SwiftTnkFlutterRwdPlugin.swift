import Flutter
import UIKit
import TnkRwdSdk2


public class SwiftTnkFlutterRwdPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tnk_flutter_rwd", binaryMessenger: registrar.messenger())
        let instance = SwiftTnkFlutterRwdPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // 오퍼월 화면 시스템 화면 모드에 따라 다크/라이트 모드 설정
        TnkColor.enableDarkMode = true
        
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        
        switch call.method {
        case "setCOPPA":
            if let args = call.arguments as? Dictionary<String, Any>,
               let coppa = args["coppa"] as? Bool {
                TnkSession.sharedInstance()?.setCOPPA(coppa)
            } else{
                TnkSession.sharedInstance()?.setCOPPA(false)
            }
            result("success")
            
            
        case "showAdList":
                    
            if let args = call.arguments as? Dictionary<String, Any>,
               let title = args["title"] as? String {
                showOfferwall(viewController: viewController!, pTitle: title)
                
            } else{
                showOfferwall(viewController: viewController!, pTitle: "무료충전소")
            }
            result("success")
            
            
        case "setUserName":
            if let args = call.arguments as? Dictionary<String, Any>{
                if let userName = args["user_name"] as? String {
                    TnkSession.sharedInstance()?.setUserName(userName)
                    result("success")
                } else {
                    result("fail")
                }
            }else{
                result("fail")
            }
            
            
        case "platformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break;

        case "showATTPopup" :
            TnkAlerts.showATTPopup(
                viewController!,
                agreeAction: {// 사용자 동의함
                    result("IOS -> ATT Agree " + UIDevice.current.systemVersion)
                },
                denyAction:{ // 동의하지 않음
                    result("IOS -> ATT Deny " + UIDevice.current.systemVersion)
                })
            
            result("success")
            break;
            
        case "getEarnPoint" :
            TnkSession.sharedInstance()?.queryAdvertiseCount() {
                (count, point) in
                print("### queryAdvertiseCount \(count) \(point)")
                result( point )
            }
            
            break;
        
        case "setNoUseUsePointIcon" :
            setNoUsePoinIcon()
            print("##### set no use point icon" )
            result("setNoUsePointIcon")
            break;
            
        case "setNoUsePrivacyAlert" :
            TnkSession.sharedInstance()?.setAgreePrivacyPolicy(true)
            print("##### agree privacy true" )
            result("setNoUsePrivacyAlert")
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
    
    func showOfferwall(viewController:UIViewController, pTitle:String) {
        let vc = AdOfferwallViewController()
        vc.title = pTitle
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        viewController.present(navController, animated: true)
    }
    
    func setNoUsePoinIcon() {
            
        // 캠페인 리스트 point 아이콘 미노출
        TnkStyles.shared.adListItem.pointIconImage.imageNormal = nil
        // 캠페인 상세페이지 버튼 point 아이콘 미노출
        TnkStyles.shared.adListItem.pointIconImage.imageHighlighted = nil
        // 재화 단위 노출
        let detailViewLayout = TnkLayout.shared.detailViewLayout
        detailViewLayout.buttonFrameLayout.pointUnitVisible = true
        
    }
}
