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
        //오퍼월 화면 시스템 화면 모드에 따라 다크/라이트 모드 설정
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
        
        case "setNoUsePointIcon" :
            setNoUsePoinIcon()
            print("##### set no use point icon" )
            result("setNoUsePointIcon")
            break;
            
        case "setNoUsePrivacyAlert" :
            TnkSession.sharedInstance()?.setAgreePrivacyPolicy(true)
            print("##### agree privacy true" )
            result("setNoUsePrivacyAlert")
            break;
            
        case "getQueryPoint" :
            TnkSession.sharedInstance()?.queryPoint() {
                (point) in
                print("#### queryPoint \(point)")
                result( point )
            }
            break;
            
        case "purchaseItem" :
            
            if let args = call.arguments as? Dictionary<String, Any>,
               let itemId = args["item_id"] as? String,
               let cost = args["cost"] as? Int {
                print ("####### itemId : \(itemId) // cost : \(cost)")
                
                TnkSession.sharedInstance()?.purchaseItem(itemId, cost:cost) {
                    // remail
                    (remainPoint, trId) in
                    print("#### purchaseItem \(remainPoint) \(trId)")
                }
                
                result("success")
    
            } else{
                result("fail")
            }

            break;
            
        case "withdrawPoints" :
            if let args = call.arguments as? Dictionary<String, Any>,
               let description = args["description"] as? String {
                
                TnkSession.sharedInstance()?.withdrawPoints(description) {
                    (point, trId) in
                    print("#### withdrawPoints \(point) \(trId)")
                }
                
                result("success")
            } else {
                result("fail")
            }
            
            break;
                    
        default:
            result("iOS method : " + call.method)
            break;
            
        }
    }
    
    func getViewController() -> FlutterViewController? {
        let topMostViewControllerObj = UIApplication.shared.delegate!.window!!.rootViewController!;
        let flutterViewController = topMostViewControllerObj as? FlutterViewController
        
        return flutterViewController;
    }
    
    func showOfferwall(viewController:UIViewController, pTitle:String) {
        let vc = AdOfferwallViewController()
        vc.title = pTitle
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
//        navController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navController.navigationBar.titleTextAttributes = [.foregroundColor: TnkColor.semantic(argb1: 0xff505050, argb2: 0xffd3d3d3)]
        
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
    
    
//    func showOfferwall() {
//            let vc = AdOfferwallViewController()
//            vc.title = "무료 충전소"
//            vc.offerwallListener = self
//
//            let navController = UINavigationController(rootViewController: vc)
//            navController.modalPresentationStyle = .fullScreen
//            //navController.navigationBar.barTintColor = .systemRed
//    //        navController.navigationBar.backgroundColor = .white
//    //       navController.navigationBar.isTranslucent = false
//            navController.navigationBar.titleTextAttributes = [.foregroundColor: TnkColor.semantic(argb1: 0xff505050, argb2: 0xffd3d3d3)]
//            //navController.hidesBarsOnSwipe = true  // 스크롤할때 네비게이션바도 같이 올라가도록 설정하기, status bar 가 투명이라 뒤로 다보임. 별로 안이쁨. 하지 말자.
//            //navController.navigationBar.isHidden = true
//            //navController.navigationBar.prefersLargeTitles = true
//            //navController.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
//            self.present(navController, animated: true)
//        }
    
}
