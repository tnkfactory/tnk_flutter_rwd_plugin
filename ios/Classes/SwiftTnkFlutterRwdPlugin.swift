import Flutter
import UIKit
import TnkRwdSdk2



public class SwiftTnkFlutterRwdPlugin: NSObject, FlutterPlugin {
    
    static var channel:FlutterMethodChannel? = nil
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "tnk_flutter_rwd", binaryMessenger: registrar.messenger())
        let instance = SwiftTnkFlutterRwdPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //오퍼월 화면 시스템 화면 모드에 따라 다크/라이트 모드 설정
        TnkColor.enableDarkMode = false
        
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
                showOfferwall(viewController: viewController!, pTitle: title, listener:self)
                
            } else{
                showOfferwall(viewController: viewController!, pTitle: "무료충전소", listener:self)
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
                
                //                setCustomUI(param: map)
                //setKidsningOfferwall()
                setKidsningCustomUI(param:map)
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
    
    func showOfferwall(viewController:UIViewController, pTitle:String, listener:OfferwallEventListener) {
        let vc = AdOfferwallViewController()
        vc.title = pTitle
        vc.offerwallListener = listener
        
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


    // 키즈닝 매체 커스텀
    private func setKidsningCustomUI(param:Dictionary<String,String>) {
        // Darkmode 를 지원하지 않으므로 앱의 info.plist 파일에 Appearance 항목을 light 로 설정한다.
        
        TnkLayout.shared.leftBarButtonItem = .close
        TnkLayout.shared.rightBarButtonItem = .help
        
     
        TnkLayout.shared.closeBarButtonImage = reSizeImage(iamgeName: "ic_close", width: 24, height: 24)
        TnkLayout.shared.helpBarButtonNormalImage = reSizeImage(iamgeName: "ic_help", width: 24, height: 24)
        
    
        let cateSelectedColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["category_select_font"]!))
        let filterSelectedBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_select_background"]!))
        let filterSelectedFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_select_font"]!))
        let filterNotSelectedBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_not_select_background"]!))
        let filterNotSelectedFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_not_select_font"]!))
//        let adListTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_title_font"]!))
//        let adListDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_desc_font"]!))
//        let adListPointUnitFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_unit_font"]!))
//        let adListPointAmtFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_amount_font"]!))
        let adInfoTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_title_font"]!))
        let adInfoDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_desc_font"]!))
        let adInfoPointUnitFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_point_unit_font"]!))
        let adInfoPointAmtFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_point_amount_font"]!))
        let adInfoButtonBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_background"]!))
//        let pointIconImgName = param["point_icon_name"]!
//        let pointIconUseYn = param["point_icon_use_yn"]!
        let adInfoButtonDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_desc_font"]!))
        let adInfoButtonTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_title_font"]!))
        let adInfoButtonFramLayoutGradientOption = param["adinfo_button_gradient_option"]
        
        
        
        
        TnkLayout.shared.registerItemViewLayout(type: .normal,
                                                viewClass: KidsningAdListItemView.self,
                                                viewLayout:  KidsningAdListItemViewLayout())
        
        
        // 카테고리 레이아웃
        let categoryMenuLayout = AdListMenuViewLayout() // 카테고리 설정
        categoryMenuLayout.helpButtonLayoutPosition = 0 // 카테고리 메뉴에 헬프버튼은 배치하지 않는다.
        
        categoryMenuLayout.menuInset = UIEdgeInsets(top: 8, left: 20, bottom: 0, right: 20)
        categoryMenuLayout.itemSpace = 8
        categoryMenuLayout.itemButton.height = 28
        categoryMenuLayout.itemButton.font = UIFont.boldSystemFont(ofSize: 14)
        
        categoryMenuLayout.itemButton.colorNormal = cateSelectedColor
        categoryMenuLayout.itemButton.backgroundNormal = UIColor.white
        categoryMenuLayout.itemButton.strokeColor = cateSelectedColor
        categoryMenuLayout.itemButton.strokeWidth = 1
        categoryMenuLayout.itemButton.cornerRadius = 14
        
        categoryMenuLayout.itemButton.colorSelected = UIColor.white // 선택된 메뉴의 폰트 색상
        categoryMenuLayout.itemButton.backgroundSelected = cateSelectedColor
        
        TnkLayout.shared.registerMenuViewLayout( type: .menu,
                                                 viewClass: DefaultAdListMenuView.self,
                                                 viewLayout: categoryMenuLayout)
        
        
        // 획득가능한 포인트 레이아웃
        let offerwallMenuLayout = OfferWallMenuViewHeaderLayout()
        TnkLayout.shared.registerMenuViewLayout( type: .sub1,
                                                 viewClass: OfferWallMenuViewHeader.self,
                                                 viewLayout: offerwallMenuLayout)
        
        
        
        TnkLayout.shared.menuMenuTypes = [.menu, .sub1]
        TnkLayout.shared.menuPinToVisibleBounds = .menu // 카테고리 메뉴 고정
        TnkLayout.shared.menuFilterHidden = true    // 필터메뉴는 숨긴다.
        
        
        
        // 필터메뉴는 사용되지 않는다.
        let filterMenuLayout = AdListFilterViewLayout() // 필터 설정
        // 선택된 필터메뉴
        filterMenuLayout.itemButton.colorSelected = filterSelectedFontColor
        filterMenuLayout.itemButton.backgroundSelected = filterSelectedBgColor
        
        // 선택안된 필터메뉴
        filterMenuLayout.itemButton.colorNormal = filterNotSelectedFontColor
        filterMenuLayout.itemButton.backgroundNormal = filterNotSelectedBgColor
        
        TnkLayout.shared.registerMenuViewLayout(type: .filter, viewClass: ScrollAdListMenuView.self, viewLayout: filterMenuLayout)
        
        
        
        
        // 광고 상세 화면
        let detailViewLayout = DefaultAdDetailViewLayout()
        // left 20 -> 0, right 20 -> 0 으로 변경. 20은 각각의 layout 에서 추가한다.
        detailViewLayout.detailViewInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        detailViewLayout.pointAmountFormat = "키즈닝 포인트 {point}P"
        
        detailViewLayout.titleViewInset = UIEdgeInsets(top: 15, left: 20, bottom: 26, right: 20)
        detailViewLayout.titlePointUnitVisible = false  // 포인트 단위는 pointAmountFormat 에 포함되어 있으므로 별도 표시하지 않는다.
        detailViewLayout.titleTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        detailViewLayout.titleTitleLabel.color = adInfoTitleFontColor // 타이틀
        detailViewLayout.titleDescLabel.color = adInfoDescFontColor // 액션
        detailViewLayout.titlePointAmountLabel.color = adInfoPointAmtFontColor // 포인트 금액
        detailViewLayout.titlePointUnitLabel.color = adInfoPointUnitFontColor // 포인트 단위
        detailViewLayout.titlePointIconImage.imageNormal = nil // 타이틀 포인트 아이콘 제거
        detailViewLayout.titleViewDividerLeadingSpace = 20
        detailViewLayout.titleViewDividerTrailingSpace = 20
        
        detailViewLayout.actionItemLayout.inset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        detailViewLayout.imageFrameLayout.inset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        detailViewLayout.videoFrameLayout.inset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        detailViewLayout.descFrameLayout.inset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        detailViewLayout.descFrameLayout.frameBackgroundColor = .clear
        detailViewLayout.descFrameLayout.descLabel.font = UIFont.boldSystemFont(ofSize: 16)
        detailViewLayout.descFrameLayout.descInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        detailViewLayout.actionInfoLayout.inset = UIEdgeInsets(top: 16, left: 20, bottom: 10, right: 20)
        detailViewLayout.actionInfoLayout.titleLabel.font = UIFont.systemFont(ofSize: 16)
        detailViewLayout.actionInfoLayout.iconImage.imageNormal = nil // 참여방식 아이콘 삭제
        detailViewLayout.actionInfoLayout.backgroundColor = TnkColor.argb(0xfff1f3f5)
        
        detailViewLayout.joinInfoLayout.inset = UIEdgeInsets(top: 16, left: 20, bottom: 10, right: 20)
        detailViewLayout.joinInfoLayout.titleLabel.font = UIFont.systemFont(ofSize: 16)
        detailViewLayout.joinInfoLayout.iconImage.imageNormal = nil // 유의사항 아이콘 삭제
        detailViewLayout.joinInfoLayout.backgroundColor = TnkColor.argb(0xfff1f3f5)
        
        detailViewLayout.buttonFrameLayout.frameBackgroundColor = adInfoButtonBgColor // 버튼 색상
        detailViewLayout.buttonFrameLayout.descLabel.color = adInfoButtonDescFontColor // 버튼 액션 폰트 색상
        detailViewLayout.buttonFrameLayout.titleLabel.color = adInfoButtonTitleFontColor // 버튼 포인트금액, 포인트단위 폰트 색상
        
        // 멀티액션 체크이미지, 포인트폰트
        detailViewLayout.actionItemLayout.itemCheckImage.imageNormal = UIImage(named: "ic_choice")
        detailViewLayout.actionItemLayout.itemCheckImage.imageDisabled = UIImage(named: "ic_unchoice")
        detailViewLayout.actionItemLayout.itemPointAmountLabel.color = TnkColor.argb(0xff5F0D80)
        
        
        detailViewLayout.buttonFrameLayout.pointAmountFormat = "{point}P 받기"
        detailViewLayout.buttonFrameLayout.pointUnitVisible = false
        detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil // 버튼 포인트아이콘 제거
        detailViewLayout.buttonFrameLayout.descLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        // 버튼 프레임아웃 gradient 백그라운드 설정
        let gradient = CAGradientLayer()
        // default
        var startColor = TnkColor.semantic(UIColor.white.withAlphaComponent(1), UIColor.white.withAlphaComponent(1))
        var endColor = TnkColor.semantic(UIColor.white.withAlphaComponent(0), UIColor.white.withAlphaComponent(0))
        // dark mode
        if( adInfoButtonFramLayoutGradientOption == "D" ) {
            
            startColor = TnkColor.semantic(UIColor.black.withAlphaComponent(1), UIColor.black.withAlphaComponent(1))
            endColor = TnkColor.semantic(UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0))
        }
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.locations = [0.85 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        detailViewLayout.buttonFrameLayout.backgroundGradient = gradient
                
        TnkLayout.shared.detailViewLayout = detailViewLayout
        
    }
    
    
    
    
    func setCustomUI(param:Dictionary<String,String>) {
        
        // Darkmode 를 지원하지 않으므로 앱의 info.plist 파일에 Appearance 항목을 light 로 설정한다.
        
        
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
        let adInfoButtonDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_desc_font"]!))
        let adInfoButtonTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_title_font"]!))
        let adInfoButtonFramLayoutGradientOption = param["adinfo_button_gradient_option"]
        
        
        // 광고 리스트
        let adListItemLayout = AdListItemViewLayout()
        adListItemLayout.titleLabel.color = adListTitleFontColor
        adListItemLayout.descLabel.color = adListDescFontColor
        adListItemLayout.pointAmountLabel.color = adListPointAmtFontColor
        adListItemLayout.pointUnitLabel.color = adListPointUnitFontColor
        
        if( pointIconImgName != "" ) {
            adListItemLayout.pointIconImage.imageNormal = UIImage(named: pointIconImgName)
        }
        if( pointIconUseYn == "Y" ) {
            adListItemLayout.pointUnitVisible = false
        } else {
            adListItemLayout.pointIconImage.imageNormal = nil // 아이콘 표시하지 않는다
        }
        TnkLayout.shared.registerItemViewLayout(type: .normal,
                                                viewClass: DefaultAdListItemView.self,
                                                viewLayout: adListItemLayout)
        
        
        
        // 카테고리 레이아웃
        let categoryMenuLayout = AdListMenuViewLayout() // 카테고리 설정
        categoryMenuLayout.itemButton.colorSelected = cateSelectedColor // 선택된 메뉴의 폰트 색상
        TnkLayout.shared.registerMenuViewLayout( type: .menu,
                                                 viewClass: DefaultAdListMenuView.self,
                                                 viewLayout: categoryMenuLayout)
        
        
        // 획득가능한 포인트 레이아웃
        let offerwallMenuLayout = OfferWallMenuViewHeaderLayout()
        TnkLayout.shared.registerMenuViewLayout( type: .sub1,
                                                 viewClass: OfferWallMenuViewHeader.self,
                                                 viewLayout: offerwallMenuLayout)
        
        
        
        TnkLayout.shared.menuMenuTypes = [.menu, .sub1]
        TnkLayout.shared.menuPinToVisibleBounds = .menu // 카테고리 메뉴 고정
        TnkLayout.shared.menuFilterHidden = true    // 필터메뉴는 숨긴다.
        
        
        
        
        let filterMenuLayout = AdListFilterViewLayout() // 필터 설정
        // 선택된 필터메뉴
        filterMenuLayout.itemButton.colorSelected = filterSelectedFontColor
        filterMenuLayout.itemButton.backgroundSelected = filterSelectedBgColor
        
        // 선택안된 필터메뉴
        filterMenuLayout.itemButton.colorNormal = filterNotSelectedFontColor
        filterMenuLayout.itemButton.backgroundNormal = filterNotSelectedBgColor
        
        TnkLayout.shared.registerMenuViewLayout(type: .filter, viewClass: ScrollAdListMenuView.self, viewLayout: filterMenuLayout)
        
        
        
        
        // 광고 상세 화면
        let detailViewLayout = DefaultAdDetailViewLayout()
        detailViewLayout.titleTitleLabel.color = adInfoTitleFontColor // 타이틀
        detailViewLayout.titleDescLabel.color = adInfoDescFontColor // 액션
        detailViewLayout.titlePointAmountLabel.color = adInfoPointAmtFontColor // 포인트 금액
        detailViewLayout.titlePointUnitLabel.color = adInfoPointUnitFontColor // 포인트 단위
        detailViewLayout.buttonFrameLayout.frameBackgroundColor = adInfoButtonBgColor // 버튼 색상
        detailViewLayout.buttonFrameLayout.descLabel.color = adInfoButtonDescFontColor // 버튼 액션 폰트 색상
        detailViewLayout.buttonFrameLayout.titleLabel.color = adInfoButtonTitleFontColor // 버튼 포인트금액, 포인트단위 폰트 색상
        
        
        
        // 버튼 프레임아웃 gradient 백그라운드 설정
        let gradient = CAGradientLayer()
        // default
        var startColor = TnkColor.semantic(UIColor.white.withAlphaComponent(1), UIColor.white.withAlphaComponent(1))
        var endColor = TnkColor.semantic(UIColor.white.withAlphaComponent(0), UIColor.white.withAlphaComponent(0))
        // dark mode
        if( adInfoButtonFramLayoutGradientOption == "D" ) {
            
            startColor = TnkColor.semantic(UIColor.black.withAlphaComponent(1), UIColor.black.withAlphaComponent(1))
            endColor = TnkColor.semantic(UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0))
        }
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.locations = [0.85 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        detailViewLayout.buttonFrameLayout.backgroundGradient = gradient
        
        detailViewLayout.actionInfoLayout.iconImage.imageNormal = nil // 참여방식 아이콘 삭제
        detailViewLayout.joinInfoLayout.iconImage.imageNormal = nil // 유의사항 아이콘 삭제
        
        // 포인트아이콘 사용시
        if( pointIconUseYn == "Y" ) {
            detailViewLayout.titlePointUnitVisible = false
            detailViewLayout.buttonFrameLayout.pointUnitVisible = false
            if( pointIconImgName != "" ) {
                detailViewLayout.titlePointIconImage.imageNormal = UIImage(named: pointIconImgName)// 상단 타이틀 point icon
                detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = UIImage(named: pointIconImgName)// 하단 버튼 point icon
            }
        } else {
            // 포인트아이콘 미사용시
            detailViewLayout.titlePointIconImage.imageNormal = nil // 타이틀 포인트 아이콘 제거
            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil // 버튼 포인트아이콘 제거
            detailViewLayout.buttonFrameLayout.pointUnitVisible = true // 버튼 포인트단위 활성
        }
        
        TnkLayout.shared.detailViewLayout = detailViewLayout
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    private func testCustomize(adDetailView:DefaultAdDetailViewLayout, adListMenuView:AdListMenuViewLayout) {
//        // 포인금액 뒤쪽으로 이미지표시 하도록 설정
//        TnkStyles.shared.adListItem.pointAmountTrailImage.width = 16
//        TnkStyles.shared.adListItem.pointAmountTrailImage.height = 16
//        TnkStyles.shared.adListItem.pointAmountTrailImage.imageNormal = UIImage(named:"dndn_check_on")
//
//        // 상단 닫기 버튼을 이미지로 교체
//        TnkLayout.shared.closeBarButtonImage = UIImage(named:"close_btn")
//
//        // 광고상세화면
//        adDetailView.actionInfoLayout.iconImage.imageNormal = nil // 참여방식 아이콘삭제
//        adDetailView.joinInfoLayout.iconImage.imageNormal = nil // 유의사항 아이콘삭제
//
//
//        // 개잉정보 수집 동의 alert 창
//        let alertViewLayout = AlertViewLayout()
//
//        alertViewLayout.titleLabel.font = TnkFonts.shared.fontManager.getFont(ofSize: 14)   // 2023.07.21
//
//        alertViewLayout.confirmButton.backgroundNormal = TnkColor.argb(0xff5F0D80)
//        alertViewLayout.confirmButton.strokeWidth = 0
//        alertViewLayout.confirmButton.cornerRadius = 6
//
//        alertViewLayout.rejectButton.colorNormal = TnkColor.argb(0xff000000)
//        alertViewLayout.rejectButton.colorHighlighted = TnkColor.argb(0xff000000)
//        alertViewLayout.rejectButton.backgroundNormal = TnkColor.argb(0xffffffff)
//        alertViewLayout.rejectButton.backgroundHighlighted = TnkColor.argb(0xffffffff)
//
//        alertViewLayout.rejectButton.strokeColor = TnkColor.argb(0xff000000)
//        alertViewLayout.rejectButton.strokeWidth = 1
//        alertViewLayout.rejectButton.cornerRadius = 6
//
//        TnkLayout.shared.alertViewLayout = alertViewLayout
//
//
//    }
    
    
    // Color hexString -> Int
    private func hexaStringToInt( _hexaStr: String ) -> Int {
        if( _hexaStr.hasPrefix("#") ) {
            let tmp = _hexaStr.trimmingCharacters(in: ["#"])
            let result = "ff" + tmp
            return Int(result, radix:16)!
        } else {
            return 0
        }
        
    }
    
    // Color hexString -> UIColor
    private func hexaStringToColor( _hexaStr: String ) -> UIColor {
        if( _hexaStr.hasPrefix("#") ) {
            let tmp = _hexaStr.trimmingCharacters(in: ["#"])
            let result = "ff" + tmp
            return TnkColor.argb(Int(result, radix:16)!)
        } else {
            return TnkColor.argb(0xffffff)
            
        }
    }
    
    private func reSizeImage( iamgeName:String, width:Int, height:Int )->UIImage {
        
        let customImage = UIImage(named: iamgeName)
        
        let newImageRect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        customImage?.draw(in: newImageRect)
        let newImage = (UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal))!
        UIGraphicsEndImageContext()
        
        
        return newImage
    }
    
    
}
