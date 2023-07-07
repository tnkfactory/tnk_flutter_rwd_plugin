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
            
        case "setCustomUI" :
            if let args = call.arguments as? Dictionary<String, Any>,
               let map = args["map"] as? Dictionary<String,String> {
                
                setCustomUI(param: map)
                print("#### setCustomUI")
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
        detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil
        detailViewLayout.buttonFrameLayout.pointUnitVisible = true
        
        
    }
    
    func setCustomUI(param:Dictionary<String,String>) {
        
        // Darkmode 를 지원하지 않으므로 앱의 info.plist 파일에 Appearance 항목을 light 로 설정한다.
        
        //print(param)
        
        let cateSelectedColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["category_select_font"]!))
        let filterSelectedBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_select_background"]!))
        let filterSelectedFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_select_font"]!))
        let filterNotSelectedBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_not_select_background"]!))
        let filterNotSelectedFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_not_select_font"]!))
        let adListTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_title_font"]!))
        let adListDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_desc_font"]!))
        let adListPointUnitFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_unit_font"]!))
        let adListPointAmtFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_amount_font"]!))
        let adInfoTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_title_font"]!))
        let adInfoDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_desc_font"]!))
        let adInfoPointUnitFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_point_unit_font"]!))
        let adInfoPointAmtFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_point_amount_font"]!))
        let adInfoButtonBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_background"]!))
        let pointIconImgName = param["point_icon_name"]!
        let pointIconUseYn = param["point_icon_use_yn"]!
        
        
        // 광고 리스트
        TnkStyles.shared.adListItem.titleLabel.color = adListTitleFontColor
        TnkStyles.shared.adListItem.descLabel.color = adListDescFontColor
        TnkStyles.shared.adListItem.pointAmountLabel.color = adListPointAmtFontColor
        TnkStyles.shared.adListItem.pointUnitLabel.color = adListPointUnitFontColor
        
        
        if( pointIconImgName != "" ) {
            TnkStyles.shared.adListItem.pointIconImage.imageNormal = UIImage(named: pointIconImgName)
        }
        if( pointIconUseYn == "Y" ) {
            TnkStyles.shared.adListItem.pointUnitVisible = false
            
        } else {
            TnkStyles.shared.adListItem.pointIconImage.imageNormal = nil // 아이콘 표시하지 않는다
        }
        
        
        
    
        // 카테고리 레이아웃
        let categoryMenuLayout = AdListMenuViewLayout() // 카테고리 설정
        categoryMenuLayout.itemButton.colorSelected = cateSelectedColor // 선택된 메뉴의 폰트 색상
        TnkLayout.shared.registerMenuViewLayout( type: .menu,
                                                 viewClass: DefaultAdListMenuView.self,
                                                 viewLayout: categoryMenuLayout)
        
        // 획득가능한 포인트 레이아웃
        let kidsningMenuLayout = KidsningMenuViewHeaderLayout()
        TnkLayout.shared.registerMenuViewLayout( type: .sub1,
                                                 viewClass: KidsningMenuViewHeader.self,
                                                 viewLayout: kidsningMenuLayout)
        

        
        TnkLayout.shared.menuMenuTypes = [.menu, .sub1]
        TnkLayout.shared.menuPinToVisibleBounds = .menu // 카테고리 메뉴 고정
        TnkLayout.shared.menuFilterHidden = true    // 필터메뉴는 숨긴다.
        
        
        
        
        // 키즈닝 경우 필터 메뉴 사용안함
        let filterMenuLayout = AdListFilterViewLayout() // 필터 설정
        // 선택된 메뉴
        filterMenuLayout.itemButton.colorSelected = filterSelectedFontColor
        filterMenuLayout.itemButton.backgroundSelected = filterSelectedBgColor

        // 선택안된 메뉴
        filterMenuLayout.itemButton.colorNormal = filterNotSelectedFontColor
        filterMenuLayout.itemButton.backgroundNormal = filterNotSelectedBgColor

        TnkLayout.shared.registerMenuViewLayout(type: .filter, viewClass: ScrollAdListMenuView.self, viewLayout: filterMenuLayout)
        
        
        
        
        // 광고 상세 화면
        let detailViewLayout = DefaultAdDetailViewLayout()
        detailViewLayout.titleTitleLabel.color = adInfoTitleFontColor
        detailViewLayout.titleDescLabel.color = adInfoDescFontColor
        detailViewLayout.titlePointAmountLabel.color = adInfoPointAmtFontColor
        detailViewLayout.titlePointUnitLabel.color = adInfoPointUnitFontColor
        //detailViewLayout.titlePointIconImage.imageNormal = nil
        //detailViewLayout.titlePointUnitVisible = false // 포인트 단위 숨기기
        
        if( pointIconUseYn == "Y" ) {
            detailViewLayout.titlePointUnitVisible = false
            detailViewLayout.buttonFrameLayout.pointUnitVisible = false
            if( pointIconImgName != "" ) {
                // 상단 타이틀 point icon
                detailViewLayout.titlePointIconImage.imageNormal = UIImage(named: pointIconImgName)
                // 하단 버튼 point icon
                detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = UIImage(named: pointIconImgName)
            }
        } else {
            detailViewLayout.titlePointIconImage.imageNormal = nil
            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil
        }
        
        detailViewLayout.buttonFrameLayout.frameBackgroundColor = adInfoButtonBgColor
        TnkLayout.shared.detailViewLayout = detailViewLayout
        
        
        
    }
    
    
    
    private func hexaStringToInt( _hexaStr: String ) -> Int {
        if( _hexaStr.hasPrefix("#") ) {
            let tmp = _hexaStr.trimmingCharacters(in: ["#"])
            let result = "ff" + tmp
            return Int(result, radix:16)!
        } else {
            return 0
        }
 
    }
    

    
    
}
