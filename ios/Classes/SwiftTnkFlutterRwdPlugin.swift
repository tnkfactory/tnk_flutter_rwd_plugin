import Flutter
import TnkRwdSdk2
import UIKit

public class SwiftTnkFlutterRwdPlugin: NSObject, FlutterPlugin,
    OfferwallEventListener
{

    static var channel: FlutterMethodChannel? = nil
    static var placementView: FlutterPlacementView? = nil

    var vc: AdOfferwallViewController? = nil
    var targetAppId: Int = 0
    var landingData = ""

    typealias tempListener = (Bool, TnkError?) -> Void

    static let tnkCustomUI: TnkCustomUI = TnkCustomUI()

    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(
            name: "tnk_flutter_rwd",
            binaryMessenger: registrar.messenger()
        )
        let instance = SwiftTnkFlutterRwdPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }

    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        //오퍼월 화면 시스템 화면 모드에 따라 다크/라이트 모드 설정
        TnkColor.enableDarkMode = false

        let viewController = UIApplication.shared.keyWindow?.rootViewController

        switch call.method {
        case "setCOPPA":
            if let args = call.arguments as? [String: Any],
                let coppa = args["coppa"] as? Bool
            {
                TnkSession.sharedInstance()?.setCOPPA(coppa)
            } else {
                TnkSession.sharedInstance()?.setCOPPA(false)
            }
            result("success")

        case "setCategoryAndFilter":
            if let args = call.arguments as? [String: Any],
                let category = args["category"] as? Int,
                let filter = args["filter"] as? Int
            {
                landingData = "\(category)//\(filter)"
                //                TnkSession.sharedInstance()?.setCategoryAndFilter(category, filter: filter)
                //                TnkSession.sharedInstance()?.setCategoryAndFilter(category, filter: filter)
            } else {
                //                TnkSession.sharedInstance()?.setCategoryAndFilter("", filter: "")
                //                DaumOfferWallViewController
            }
            // let offerWall = DaumOfferWallViewController()
            //offerWall.showWelcomeMsg = false
            //offerWall.title = "광고보고 미션참여"
            //offerWall.landingData = "4//0"
            //self.navigationController?.pushViewController(offerWall, animated: true)
            result("success")
        case "showAdList":
            if let args = call.arguments as? [String: Any] {
                if let title = args["title"] as? String {
                    showOfferwall(
                        viewController: viewController!,
                        pTitle: title,
                        listener: self
                    )

                } else {
                    showOfferwall(
                        viewController: viewController!,
                        pTitle: "무료충전소",
                        listener: self
                    )
                }
                if let appId = args["app_id"] as? Int {
                    targetAppId = appId

                    print("## targetAppId  \(targetAppId)")
                }
            }

            result("success")

        case "setUserName":
            if let args = call.arguments as? [String: Any] {
                if let userName = args["user_name"] as? String {
                    TnkSession.sharedInstance()?.setUserName(userName)
                    result("success  input :[\(userName)]")

                } else {
                    result("fail")
                }
            } else {
                result("fail")
            }

        case "platformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break

        case "showATTPopup":
            TnkAlerts.showATTPopup(
                viewController!,
                agreeAction: {  // 사용자 동의함
                    result("IOS -> ATT Agree " + UIDevice.current.systemVersion)
                },
                denyAction: {  // 동의하지 않음
                    result("IOS -> ATT Deny " + UIDevice.current.systemVersion)
                }
            )

            result("success")
            break

        case "getEarnPoint":
            TnkSession.sharedInstance()?.queryAdvertiseCount {
                (count, point) in
                result(point)
            }
            break

        case "setNoUsePointIcon":
            setNoUsePoinIcon()
            result("setNoUsePointIcon")
            break

        case "setNoUsePrivacyAlert":
            TnkSession.sharedInstance()?.setAgreePrivacyPolicy(true)
            result("setNoUsePrivacyAlert")
            break

        case "getQueryPoint":
            TnkSession.sharedInstance()?.queryPoint {
                (point) in
                result(point)
            }
            break

        case "purchaseItem":

            if let args = call.arguments as? [String: Any],
                let itemId = args["item_id"] as? String,
                let cost = args["cost"] as? Int
            {

                TnkSession.sharedInstance()?.purchaseItem(itemId, cost: cost) {
                    // remail
                    (remainPoint, trId) in
                }

                result("success")

            } else {
                result("fail")
            }

            break

        case "withdrawPoints":
            if let args = call.arguments as? [String: Any],
                let description = args["description"] as? String
            {

                TnkSession.sharedInstance()?.withdrawPoints(description) {
                    (point, trId) in
                }

                result("success")
            } else {
                result("fail")
            }

            break

        case "setCustomUI":
            if let args = call.arguments as? [String: Any],
                let map = args["map"] as? [String: String]
            {

                //                setCustomUI(param: map)
                //setKidsningOfferwall()
                setKidsningCustomUI(param: map)
                result("success")
            } else {
                result("fail")
            }

            break

        ///////////////
        case "onItemClick":
            if let args = call.arguments as? [String: Any] {
                if let placement_id = args["app_id"] as? String {
                    SwiftTnkFlutterRwdPlugin.placementView?.clickItem(
                        appid: placement_id
                    ) { issuccess, error in
                        if issuccess {
                            result(
                                "{\"res_code\":\"1\",\"res_message\":\"success\"}"
                            )
                        } else {
                            if error != nil {
                                result(
                                    "{\"res_code\":\"-1\",\"res_message\":\""
                                        + error!.errorMessage + "\"}"
                                )
                            } else {
                                result(
                                    "{\"res_code\":\"-1\",\"res_message\":\"오류가 발생했습니다.\"}"
                                )
                            }
                        }
                    }
                }
            }
            break
        case "closeAllView":
            if let viewController {
                closeAllView(viewController: viewController)
            }
            result("success")
            break
        case "closeOfferwall":
            if let viewController {
                closeOfferwall(viewController: viewController)
            }
            result("success")
            break
        case "closeAdDetail":
            if let viewController {
                closeAdItem(viewController: viewController)
            }
            result("success")
            break
        case "getPlacementJsonData":
            if let args = call.arguments as? [String: Any] {
                if let placement_id = args["placement_id"] as? String {
                    SwiftTnkFlutterRwdPlugin.placementView =
                        FlutterPlacementView(
                            frame: viewController!.view.frame,
                            viewController: viewController!,
                            placementId: placement_id
                        ) { res in
                            result(res)
                        }
                    SwiftTnkFlutterRwdPlugin.placementView!.loadItem()
                } else {
                    result("fail")
                }
            }
            break
        case "setUseTermsPopup":
            if let args = call.arguments as? [String: Any] {
                if let isUse = args["is_use"] as? Bool {
                    if !isUse {
                        TnkSession.shared?.setAgreePrivacyPolicy(true)
                        // else
                        // TnkSession.shared?.setAgreePrivacyPolicy(false);
                        result("success")
                        return
                    }
                }

            } else {
                result("false")
            }

            break

        case "setCustomUnitIcon":
            if let args = call.arguments as? [String: Any],
                let map = args["map"] as? [String: String]
            {

                let res = setCustomUnitIcon(param: map)
                if res {
                    result("success")
                } else {
                    result("error")
                }

            } else {
                result("fail")
            }

            break

        case "setCustomUIDefault":
            if let args = call.arguments as? [String: Any],
                let map = args["map"] as? [String: String]
            {

                SwiftTnkFlutterRwdPlugin.tnkCustomUI.setCustomUIDefault(
                    param: map
                )
                result("success")

            } else {
                result("fail")
            }

            break

        case "presentAdDetailView":
            if let args = call.arguments as? [String: Any] {
                if let argAppId = args["app_id"] as? Int,
                    let argActionId = args["action_id"] as? Int
                {
                    if argAppId > 0 {TnkSession.sharedInstance()?.presentAdDetailView(
                            viewController!,
                            appId: argAppId,
                            fullscreen: false,
                        ) {
                            (isOkay) in
                            if isOkay {
                                print("광고 상세화면 성공")
                                result("success")
                            } else {
                                print("광고 상세화면 실패 또는 취소됨")
                                result("fail")
                            }
                        }
                    } else {
                        result("fail - please check appId.. abnormal appId")
                    }
                }

                break
            }

        case "adJoin":
            if let args = call.arguments as? [String: Any] {
                if let argAppId = args["app_id"] as? Int,
                    let argActionId = args["action_id"] as? Int
                {
                    if argAppId > 0 {
                        TnkSession.sharedInstance()?.adJoin(
                            viewController!,
                            appId: argAppId,
                            fullscreen: false,
                        ) {
                            (isOkay) in
                            if isOkay {
                                print("광고 참여 성공")
                                result("success")
                            } else {
                                print("광고 참여 실패 또는 취소됨")
                                result("fail")
                            }
                        }
                    } else {
                        result("fail - please check appId.. abnormal appId")
                    }
                }

                break
            }

        case "adAction":
            if let args = call.arguments as? [String: Any] {
                if let argAppId = args["app_id"] as? Int,
                    let argActionId = args["action_id"] as? Int
                {
                    if argAppId > 0 {
                        TnkSession.sharedInstance()?.adAction(
                            viewController!,
                            appId: argAppId,
                            fullscreen: false,
                        ) {
                            (isOkay) in
                            if isOkay {
                                print("광고 상세/참여 성공")
                                result("success")
                            } else {
                                print("광고 상세/참여 취소됨")
                                result("fail")
                            }
                        }
                    } else {
                        result("fail - please check appId.. abnormal appId")
                    }
                }

                break
            }
        case "showCustomTapActivity":
//            if let args = call.arguments as? [String: Any]
//            {
//                if let urlRaw = args["url"] as? String,
//                   let deep_link = args["deep_link"] as? String,
//                   let parentVC = viewController
//                {
//                    let deepLinkParam = [
//                        "deep_link": deep_link
//                    ]
//                    TnkSession.sharedInstance()?.showCustomTapViewController(rootViewController: parentVC,
//                                                                             url: urlRaw, parmas: deepLinkParam)
//                }
//            }
            break
        case "openEventWebView":
//            if let args = call.arguments as? [String: Any]
//            {
//                if let eventId = args["eventId"] as? Int,
//                   let parentVC = viewController
//                {
//                    TnkSession.sharedInstance()?.openPrivacyTermAlert(parentViewController: parentVC) { [weak self]  result in
//                        if(result)
//                        {
//                            TnkSession.sharedInstance()?.getEventWebView(parentViewController: parentVC, eventId: eventId) { resultVc in
//                                guard let self = self else { return }
//                                if let vc = resultVc
//                                {
//                                    self.showAdisocpeVC(parent:parentVC, target: vc)
//                                }
//                            }
//                        }
//                    }
//                    
//                    
//                }
//            }
            break
        default:
            result("iOS method : " + call.method)
            break

        }
    }

    func getViewController() -> FlutterViewController? {
        let topMostViewControllerObj = UIApplication.shared.delegate!.window!!
            .rootViewController!
        let flutterViewController =
            topMostViewControllerObj as? FlutterViewController

        return flutterViewController
    }

    func showOfferwall(
        viewController: UIViewController,
        pTitle: String,
        listener: OfferwallEventListener
    ) {
        vc = AdOfferwallViewController()
        vc!.title = pTitle
        //        vc?.landingData = "4//0"
        vc!.offerwallListener = listener

        // let offerWall = DaumOfferWallViewController()
        //offerWall.showWelcomeMsg = false
        //offerWall.title = "광고보고 미션참여"
        //offerWall.landingData = "4//0"
        vc!.landingData = landingData

        //self.navigationController?.pushViewController(offerWall, animated: true)

        let navController = TnkBaseNaviController(rootViewController: vc!)
        navController.modalPresentationStyle = .fullScreen
        //        navController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navController.navigationBar.titleTextAttributes = [
            .foregroundColor: TnkColor.semantic(
                argb1: 0xff50_5050,
                argb2: 0xffd3_d3d3
            )
        ]
        viewController.present(navController, animated: true)

    }

    public func didOfferwallRemoved() {
        print("closed")
        SwiftTnkFlutterRwdPlugin.channel?.invokeMethod(
            "didOfferwallRemoved",
            arguments: "success"
        )
    }

    public func didAdDataLoaded(
        headerMessage: String?,
        totalPoint: Int,
        totalCount: Int,
        multiRewardPoint: Int,
        multiRewardCount: Int
    ) {
        if targetAppId != 0 {
            TnkSession.sharedInstance()?.presentAdDetailView(
                vc!,
                appId: targetAppId,
                fullscreen: false
            ) {
                (isOkay) in
            }
        }
        targetAppId = 0
    }

    public func didMenuSelected(
        menuId: Int,
        menuName: String,
        filterId: Int,
        filterName: String
    ) {
        print(
            "### menuId: \(menuId) \(menuName), filterId: \(filterId) \(filterName)"
        )
    }

    public func didAdItemClicked(appId: Int, appName: String) {
        print("### adItem: \(appId) \(appName)")
    }

    public func didDetailViewShow(appId: Int, appName: String) {
        print("#### detailView show \(appId) \(appName)")
    }

    public func didActionButtonClicked(appId: Int, appName: String) {
        print("#### action button clicked \(appId) \(appName)")
    }

    func setNoUsePoinIcon() {

        // 캠페인 리스트 point 아이콘 미노출
        TnkStyles.shared.adListItem.pointIconImage.imageNormal = nil
        TnkStyles.shared.adListItem.pointIconImage.imageHighlighted = nil
        // 재화 단위 노출
        // 캠페인 상세페이지 버튼 point 아이콘 미노출
        let detailViewLayout = TnkLayout.shared.detailViewLayout
        detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil
        detailViewLayout.buttonFrameLayout.pointUnitVisible = true

    }

    func setCustomUnitIcon(param: [String: String]) -> Bool {

        // 1 - 재화 아이콘, 단위 둘다 표시
        // 2 - 재화 아이콘만 표시
        // 3 - 재화 단위만 표시
        // 4 - 둘다 표시 안함
        let option = param["option", default: "1"]
        let defPointIconImage = param["point_icon_name", default: ""]
        let subPointIconImage = param["point_icon_name_sub", default: ""]

        print("option : \(option)")
        print("defPointIconImage: \(defPointIconImage)")
        print("subPointIconImage: \(subPointIconImage)")

        switch option {

        // 재화 이이콘, 단위 둘다 표시
        case "1":
            print("option : >>> 1")
            print("defPointIconImage: >>>  \(defPointIconImage)")
            print("subPointIconImage: >>> \(subPointIconImage)")
            // 광고 리스트 제어
            if defPointIconImage != "" {
                TnkStyles.shared.adListItem.pointIconImage.imageNormal =
                    UIImage(named: defPointIconImage)
            }
            TnkStyles.shared.adListItem.pointAmountFormat = "{point}{unit}"
            TnkStyles.shared.adListItem.pointUnitVisible = false

            // 광고상세 제어
            let detailViewLayout = TnkLayout.shared.detailViewLayout

            if defPointIconImage != "" {
                detailViewLayout.titlePointIconImage.imageNormal = UIImage(
                    named: defPointIconImage
                )
            }
            if subPointIconImage != "" {
                detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal =
                    UIImage(named: subPointIconImage)
            }
            detailViewLayout.pointAmountFormat = "{point}{unit}"
            detailViewLayout.titlePointUnitVisible = false

            TnkLayout.shared.detailViewLayout = detailViewLayout

            return true

        // 재화 아이콘만 표시
        case "2":
            if defPointIconImage != "" {
                TnkStyles.shared.adListItem.pointIconImage.imageNormal =
                    UIImage(named: defPointIconImage)
            }
            TnkStyles.shared.adListItem.pointUnitVisible = false

            // 광고상세 제어
            let detailViewLayout = TnkLayout.shared.detailViewLayout

            if defPointIconImage != "" {
                detailViewLayout.titlePointIconImage.imageNormal = UIImage(
                    named: defPointIconImage
                )
            }
            if subPointIconImage != "" {
                detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal =
                    UIImage(named: subPointIconImage)
            }
            detailViewLayout.titlePointUnitVisible = false

            TnkLayout.shared.detailViewLayout = detailViewLayout

            return true

        // 재화 단위만 표시
        case "3":

            TnkStyles.shared.adListItem.pointIconImage.imageNormal = nil
            TnkStyles.shared.adListItem.pointAmountFormat = "{point}{unit}"
            TnkStyles.shared.adListItem.pointUnitVisible = false

            // 광고상세 제어
            let detailViewLayout = TnkLayout.shared.detailViewLayout
            detailViewLayout.titlePointIconImage.imageNormal = nil
            detailViewLayout.pointAmountFormat = "{point}{unit}"
            detailViewLayout.titlePointUnitVisible = false

            TnkLayout.shared.detailViewLayout = detailViewLayout

            return true

        // 둘다 표시 안함
        case "4":
            TnkStyles.shared.adListItem.pointIconImage.imageNormal = nil
            TnkStyles.shared.adListItem.pointUnitVisible = false

            // 광고상세 제어
            let detailViewLayout = TnkLayout.shared.detailViewLayout
            detailViewLayout.titlePointIconImage.imageNormal = nil
            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil
            detailViewLayout.titlePointUnitVisible = false

            TnkLayout.shared.detailViewLayout = detailViewLayout

            return true

        default:

            break
        }

        return false
    }
    // 매체세 재화 아이콘, 단위 커스텀 메소드
    //    func setCustomUnitIcon(param:Dictionary<String,String>) -> Bool {
    //
    //
    //        // 1 - 재화 아이콘, 단위 둘다 표시
    //        // 2 - 재화 아이콘만 표시
    //        // 3 - 재화 단위만 표시
    //        // 4 - 둘다 표시 안함
    //        let option = param["option", default: "2"]
    //
    //
    //        // 재화 아이콘, 단위 표시 처리
    //        switch option {
    //            case "1" : // 모두 표시
    //                TnkStyles.shared.adListItem.pointUnitVisible = false
    //                TnkLayout.shared.detailViewLayout.titlePointUnitVisible = false
    //                TnkStyles.shared.adListItem.pointAmountFormat = "{point}{unit}"
    //                break;
    //            case "2" : // 재화 아이콘만 표시
    //                TnkStyles.shared.adListItem.pointUnitVisible = false
    //                TnkLayout.shared.detailViewLayout.titlePointUnitVisible = false
    //                TnkStyles.shared.adListItem.pointAmountFormat = "{point}"
    //                break;
    //            case "3" : // 재화 단위만 표시
    //                TnkStyles.shared.adListItem.pointUnitVisible = false
    //                TnkLayout.shared.detailViewLayout.titlePointUnitVisible = false
    //                TnkStyles.shared.adListItem.pointAmountFormat = "{point}{unit}"
    //                break;
    //            case "4" : // 둘다 표시 안함
    //                TnkStyles.shared.adListItem.pointUnitVisible = false
    //                TnkLayout.shared.detailViewLayout.titlePointUnitVisible = false
    //                TnkStyles.shared.adListItem.pointAmountFormat = "{point}"
    //                break;
    //            default:
    //                break;
    //        }
    //
    //        let detailViewLayout = TnkLayout.shared.detailViewLayout
    //        if let defPointIconImage = param["point_icon_name"] {
    //            print(">>> \(defPointIconImage)")
    //            TnkStyles.shared.adListItem.pointIconImage.imageNormal = UIImage(named: defPointIconImage)
    //            detailViewLayout.titlePointIconImage.imageNormal = UIImage(named: defPointIconImage)
    //        }
    //        if let subPointIconImage = param["point_icon_name_sub"] {
    //            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = UIImage(named: subPointIconImage)
    //        }
    //
    //        TnkLayout.shared.detailViewLayout = detailViewLayout
    //        return false
    //    }

    func setCustomUI(param: [String: String]) {

        // Darkmode 를 지원하지 않으므로 앱의 info.plist 파일에 Appearance 항목을 light 로 설정한다.

        let cateSelectedColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["category_select_font"]!)
        )
        let filterSelectedBgColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["filter_select_background"]!)
        )
        let filterSelectedFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["filter_select_font"]!)
        )
        let filterNotSelectedBgColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["filter_not_select_background"]!)
        )
        let filterNotSelectedFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["filter_not_select_font"]!)
        )
        let adListTitleFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adlist_title_font"]!)
        )
        let adListDescFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adlist_desc_font"]!)
        )
        let adListPointUnitFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adlist_point_unit_font"]!)
        )
        let adListPointAmtFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adlist_point_amount_font"]!)
        )
        let adInfoTitleFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_title_font"]!)
        )
        let adInfoDescFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_desc_font"]!)
        )
        let adInfoPointUnitFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_point_unit_font"]!)
        )
        let adInfoPointAmtFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_point_amount_font"]!)
        )
        let adInfoButtonBgColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_button_background"]!)
        )
        let adInfoButtonDescFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_button_desc_font"]!)
        )
        let adInfoButtonTitleFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_button_title_font"]!)
        )
        let adInfoButtonFramLayoutGradientOption = param[
            "adinfo_button_gradient_option"
        ]

        let defPointIconImage = param["point_icon_name"]!
        let subPointIconImage = param["point_icon_name_sub"]!

        // 광고 리스트
        let adListItemLayout = AdListItemViewLayout()
        adListItemLayout.titleLabel.color = adListTitleFontColor
        adListItemLayout.descLabel.color = adListDescFontColor
        adListItemLayout.pointAmountLabel.color = adListPointAmtFontColor
        adListItemLayout.pointUnitLabel.color = adListPointUnitFontColor

        TnkLayout.shared.registerItemViewLayout(
            type: .normal,
            viewClass: DefaultAdListItemView.self,
            viewLayout: adListItemLayout
        )

        // 카테고리 레이아웃
        let categoryMenuLayout = AdListMenuViewLayout()  // 카테고리 설정
        categoryMenuLayout.itemButton.colorSelected = cateSelectedColor  // 선택된 메뉴의 폰트 색상
        TnkLayout.shared.registerMenuViewLayout(
            type: .menu,
            viewClass: DefaultAdListMenuView.self,
            viewLayout: categoryMenuLayout
        )

        let filterMenuLayout = AdListFilterViewLayout()  // 필터 설정
        // 선택된 필터메뉴
        filterMenuLayout.itemButton.colorSelected = filterSelectedFontColor
        filterMenuLayout.itemButton.backgroundSelected = filterSelectedBgColor

        // 선택안된 필터메뉴
        filterMenuLayout.itemButton.colorNormal = filterNotSelectedFontColor
        filterMenuLayout.itemButton.backgroundNormal = filterNotSelectedBgColor

        TnkLayout.shared.registerMenuViewLayout(
            type: .filter,
            viewClass: ScrollAdListMenuView.self,
            viewLayout: filterMenuLayout
        )

        // 광고 상세 화면
        let detailViewLayout = DefaultAdDetailViewLayout()
        detailViewLayout.titleTitleLabel.color = adInfoTitleFontColor  // 타이틀
        detailViewLayout.titleDescLabel.color = adInfoDescFontColor  // 액션
        detailViewLayout.titlePointAmountLabel.color = adInfoPointAmtFontColor  // 포인트 금액
        detailViewLayout.titlePointUnitLabel.color = adInfoPointUnitFontColor  // 포인트 단위
        detailViewLayout.buttonFrameLayout.frameBackgroundColor =
            adInfoButtonBgColor  // 버튼 색상
        detailViewLayout.buttonFrameLayout.descLabel.color =
            adInfoButtonDescFontColor  // 버튼 액션 폰트 색상
        detailViewLayout.buttonFrameLayout.titleLabel.color =
            adInfoButtonTitleFontColor  // 버튼 포인트금액, 포인트단위 폰트 색상

        //        // 버튼 프레임아웃 gradient 백그라운드 설정
        //        let gradient = CAGradientLayer()
        //        // default
        //        var startColor = TnkColor.semantic(UIColor.white.withAlphaComponent(1), UIColor.white.withAlphaComponent(1))
        //        var endColor = TnkColor.semantic(UIColor.white.withAlphaComponent(0), UIColor.white.withAlphaComponent(0))
        //        // dark mode
        //        if( adInfoButtonFramLayoutGradientOption == "D" ) {
        //
        //            startColor = TnkColor.semantic(UIColor.black.withAlphaComponent(1), UIColor.black.withAlphaComponent(1))
        //            endColor = TnkColor.semantic(UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0))
        //        }
        //        gradient.colors = [startColor.cgColor, endColor.cgColor]
        //        gradient.locations = [0.85 , 1.0]
        //        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        //        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        //        detailViewLayout.buttonFrameLayout.backgroundGradient = gradient
        //
        //        detailViewLayout.actionInfoLayout.iconImage.imageNormal = nil // 참여방식 아이콘 삭제
        //        detailViewLayout.joinInfoLayout.iconImage.imageNormal = nil // 유의사항 아이콘 삭제

        TnkLayout.shared.detailViewLayout = detailViewLayout

    }

    // 키즈닝 매체 커스텀
    private func setKidsningCustomUI(param: [String: String]) {
        // Darkmode 를 지원하지 않으므로 앱의 info.plist 파일에 Appearance 항목을 light 로 설정한다.

        TnkLayout.shared.leftBarButtonItem = .close
        TnkLayout.shared.rightBarButtonItem = .help

        TnkLayout.shared.closeBarButtonImage = reSizeImage(
            iamgeName: "ic_close",
            width: 24,
            height: 24
        )
        TnkLayout.shared.helpBarButtonNormalImage = reSizeImage(
            iamgeName: "ic_help",
            width: 24,
            height: 24
        )

        let cateSelectedColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["category_select_font"]!)
        )
        let filterSelectedBgColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["filter_select_background"]!)
        )
        let filterSelectedFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["filter_select_font"]!)
        )
        let filterNotSelectedBgColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["filter_not_select_background"]!)
        )
        let filterNotSelectedFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["filter_not_select_font"]!)
        )
        //        let adListTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_title_font"]!))
        //        let adListDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_desc_font"]!))
        //        let adListPointUnitFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_unit_font"]!))
        //        let adListPointAmtFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_amount_font"]!))
        let adInfoTitleFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_title_font"]!)
        )
        let adInfoDescFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_desc_font"]!)
        )
        let adInfoPointUnitFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_point_unit_font"]!)
        )
        let adInfoPointAmtFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_point_amount_font"]!)
        )
        let adInfoButtonBgColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_button_background"]!)
        )
        //        let pointIconImgName = param["point_icon_name"]!
        //        let pointIconUseYn = param["point_icon_use_yn"]!
        let adInfoButtonDescFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_button_desc_font"]!)
        )
        let adInfoButtonTitleFontColor = TnkColor.argb(
            hexaStringToInt(_hexaStr: param["adinfo_button_title_font"]!)
        )
        let adInfoButtonFramLayoutGradientOption = param[
            "adinfo_button_gradient_option"
        ]

        //        TnkLayout.shared.registerItemViewLayout(type: .normal,
        //                                                viewClass: KidsningAdListItemView.self,
        //                                                viewLayout:  KidsningAdListItemViewLayout())

        // 카테고리 레이아웃
        let categoryMenuLayout = AdListMenuViewLayout()  // 카테고리 설정
        categoryMenuLayout.helpButtonLayoutPosition = 0  // 카테고리 메뉴에 헬프버튼은 배치하지 않는다.

        categoryMenuLayout.menuInset = UIEdgeInsets(
            top: 8,
            left: 20,
            bottom: 0,
            right: 20
        )
        categoryMenuLayout.itemSpace = 8
        categoryMenuLayout.itemButton.height = 28
        categoryMenuLayout.itemButton.font = UIFont.boldSystemFont(ofSize: 14)

        categoryMenuLayout.itemButton.colorNormal = cateSelectedColor
        categoryMenuLayout.itemButton.backgroundNormal = UIColor.white
        categoryMenuLayout.itemButton.strokeColor = cateSelectedColor
        categoryMenuLayout.itemButton.strokeWidth = 1
        categoryMenuLayout.itemButton.cornerRadius = 14

        categoryMenuLayout.itemButton.colorSelected = UIColor.white  // 선택된 메뉴의 폰트 색상
        categoryMenuLayout.itemButton.backgroundSelected = cateSelectedColor

        TnkLayout.shared.registerMenuViewLayout(
            type: .menu,
            viewClass: DefaultAdListMenuView.self,
            viewLayout: categoryMenuLayout
        )

        // 획득가능한 포인트 레이아웃
        let offerwallMenuLayout = OfferWallMenuViewHeaderLayout()
        TnkLayout.shared.registerMenuViewLayout(
            type: .sub1,
            viewClass: OfferWallMenuViewHeader.self,
            viewLayout: offerwallMenuLayout
        )

        TnkLayout.shared.menuMenuTypes = [.menu, .sub1]
        TnkLayout.shared.menuPinToVisibleBounds = .menu  // 카테고리 메뉴 고정
        TnkLayout.shared.menuFilterHidden = true  // 필터메뉴는 숨긴다.

        // 필터메뉴는 사용되지 않는다.
        let filterMenuLayout = AdListFilterViewLayout()  // 필터 설정
        // 선택된 필터메뉴
        filterMenuLayout.itemButton.colorSelected = filterSelectedFontColor
        filterMenuLayout.itemButton.backgroundSelected = filterSelectedBgColor

        // 선택안된 필터메뉴
        filterMenuLayout.itemButton.colorNormal = filterNotSelectedFontColor
        filterMenuLayout.itemButton.backgroundNormal = filterNotSelectedBgColor

        TnkLayout.shared.registerMenuViewLayout(
            type: .filter,
            viewClass: ScrollAdListMenuView.self,
            viewLayout: filterMenuLayout
        )

        // 광고 상세 화면
        let detailViewLayout = DefaultAdDetailViewLayout()
        // left 20 -> 0, right 20 -> 0 으로 변경. 20은 각각의 layout 에서 추가한다.
        detailViewLayout.detailViewInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )

        detailViewLayout.pointAmountFormat = "키즈닝 포인트 {point}P"

        detailViewLayout.titleViewInset = UIEdgeInsets(
            top: 15,
            left: 20,
            bottom: 26,
            right: 20
        )
        detailViewLayout.titlePointUnitVisible = false  // 포인트 단위는 pointAmountFormat 에 포함되어 있으므로 별도 표시하지 않는다.
        detailViewLayout.titleTitleLabel.font = UIFont.boldSystemFont(
            ofSize: 16
        )
        detailViewLayout.titleTitleLabel.color = adInfoTitleFontColor  // 타이틀
        detailViewLayout.titleDescLabel.color = adInfoDescFontColor  // 액션
        detailViewLayout.titlePointAmountLabel.color = adInfoPointAmtFontColor  // 포인트 금액
        detailViewLayout.titlePointUnitLabel.color = adInfoPointUnitFontColor  // 포인트 단위
        detailViewLayout.titlePointIconImage.imageNormal = nil  // 타이틀 포인트 아이콘 제거
        detailViewLayout.titleViewDividerLeadingSpace = 20
        detailViewLayout.titleViewDividerTrailingSpace = 20

        detailViewLayout.actionItemLayout.inset = UIEdgeInsets(
            top: 10,
            left: 20,
            bottom: 10,
            right: 20
        )
        detailViewLayout.imageFrameLayout.inset = UIEdgeInsets(
            top: 10,
            left: 20,
            bottom: 10,
            right: 20
        )
        detailViewLayout.videoFrameLayout.inset = UIEdgeInsets(
            top: 10,
            left: 20,
            bottom: 10,
            right: 20
        )

        detailViewLayout.descFrameLayout.inset = UIEdgeInsets(
            top: 10,
            left: 20,
            bottom: 10,
            right: 20
        )
        detailViewLayout.descFrameLayout.frameBackgroundColor = .clear
        detailViewLayout.descFrameLayout.descLabel.font = UIFont.boldSystemFont(
            ofSize: 16
        )
        detailViewLayout.descFrameLayout.descInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )

        detailViewLayout.actionInfoLayout.inset = UIEdgeInsets(
            top: 16,
            left: 20,
            bottom: 10,
            right: 20
        )
        detailViewLayout.actionInfoLayout.titleLabel.font = UIFont.systemFont(
            ofSize: 16
        )
        detailViewLayout.actionInfoLayout.iconImage.imageNormal = nil  // 참여방식 아이콘 삭제
        detailViewLayout.actionInfoLayout.backgroundColor = TnkColor.argb(
            0xfff1_f3f5
        )

        detailViewLayout.joinInfoLayout.inset = UIEdgeInsets(
            top: 16,
            left: 20,
            bottom: 10,
            right: 20
        )
        detailViewLayout.joinInfoLayout.titleLabel.font = UIFont.systemFont(
            ofSize: 16
        )
        detailViewLayout.joinInfoLayout.iconImage.imageNormal = nil  // 유의사항 아이콘 삭제
        detailViewLayout.joinInfoLayout.backgroundColor = TnkColor.argb(
            0xfff1_f3f5
        )

        detailViewLayout.buttonFrameLayout.frameBackgroundColor =
            adInfoButtonBgColor  // 버튼 색상
        detailViewLayout.buttonFrameLayout.descLabel.color =
            adInfoButtonDescFontColor  // 버튼 액션 폰트 색상
        detailViewLayout.buttonFrameLayout.titleLabel.color =
            adInfoButtonTitleFontColor  // 버튼 포인트금액, 포인트단위 폰트 색상

        // 멀티액션 체크이미지, 포인트폰트
        detailViewLayout.actionItemLayout.itemCheckImage.imageNormal = UIImage(
            named: "ic_choice"
        )
        detailViewLayout.actionItemLayout.itemCheckImage.imageDisabled =
            UIImage(named: "ic_unchoice")
        detailViewLayout.actionItemLayout.itemPointAmountLabel.color =
            TnkColor.argb(0xff5F_0D80)

        detailViewLayout.buttonFrameLayout.pointAmountFormat = "{point}P 받기"
        detailViewLayout.buttonFrameLayout.pointUnitVisible = false
        detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil  // 버튼 포인트아이콘 제거
        detailViewLayout.buttonFrameLayout.descLabel.font =
            UIFont.boldSystemFont(ofSize: 16)

        // 버튼 프레임아웃 gradient 백그라운드 설정
        let gradient = CAGradientLayer()
        // default
        var startColor = TnkColor.semantic(
            UIColor.white.withAlphaComponent(1),
            UIColor.white.withAlphaComponent(1)
        )
        var endColor = TnkColor.semantic(
            UIColor.white.withAlphaComponent(0),
            UIColor.white.withAlphaComponent(0)
        )
        // dark mode
        if adInfoButtonFramLayoutGradientOption == "D" {

            startColor = TnkColor.semantic(
                UIColor.black.withAlphaComponent(1),
                UIColor.black.withAlphaComponent(1)
            )
            endColor = TnkColor.semantic(
                UIColor.black.withAlphaComponent(0),
                UIColor.black.withAlphaComponent(0)
            )
        }
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.locations = [0.85, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        detailViewLayout.buttonFrameLayout.backgroundGradient = gradient

        TnkLayout.shared.detailViewLayout = detailViewLayout

    }

    //    private func customBodyUI(param:Dictionary<String,String>, type: LayoutType, viewClass: AnyClass, viewLayout:AdListItemViewLayout) {
    //
    //
    //        let adListTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_title_font"]!))
    //        let adListDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_desc_font"]!))
    //        let adListPointUnitFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_unit_font"]!))
    //        let adListPointAmtFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_amount_font"]!))
    //        let pointIconDefault = param["point_icon_name"]!
    //        let option = param["option"]!
    //
    //
    //
    //
    //
    //            switch option {
    //
    //                // 재화 이이콘, 단위 둘다 표시
    //            case "1" :
    //                viewLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
    //                viewLayout.pointAmountFormat = "{point}{unit}"
    //                viewLayout.pointUnitVisible = false
    //
    //
    //                // 재화 아이콘만 표시
    //            case "2" :
    //                viewLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
    //                viewLayout.pointUnitVisible = false
    //
    //
    //                // 재화 단위만 표시
    //            case "3" :
    //                viewLayout.pointIconImage.imageNormal = nil
    //                viewLayout.pointAmountFormat = "{point}{unit}"
    //                viewLayout.pointUnitVisible = false
    //
    //
    //                // 둘다 표시 안함
    //            case "4" :
    //                viewLayout.pointIconImage.imageNormal = nil
    //                viewLayout.pointUnitVisible = false
    //
    //
    //            default:
    //
    //                break
    //            }
    //
    //
    //
    //
    //        viewLayout.titleLabel.color = adListTitleFontColor
    //        viewLayout.descLabel.color = adListDescFontColor
    //        viewLayout.pointAmountLabel.color = adListPointAmtFontColor
    //        viewLayout.pointUnitLabel.color = adListPointUnitFontColor
    //        viewLayout.discountRateLabel.color = adListPointAmtFontColor
    //
    //
    //
    //        TnkLayout.shared.registerItemViewLayout(type: type, viewClass: viewClass, viewLayout: viewLayout)
    //
    //    }

    //    func setCustomUIDefault(param:Dictionary<String,String>) {
    //
    //        let cateSelectedColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["category_select_font"]!))
    //        let filterSelectedBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_select_background"]!))
    //        let filterSelectedFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_select_font"]!))
    //        let filterNotSelectedBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_not_select_background"]!))
    //        let filterNotSelectedFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_not_select_font"]!))
    //
    //        let adInfoTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_title_font"]!))
    //        let adInfoDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_desc_font"]!))
    //        let adInfoPointUnitFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_point_unit_font"]!))
    //        let adInfoPointAmtFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_point_amount_font"]!))
    //        let adInfoButtonBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_background"]!))
    //        let adInfoButtonDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_desc_font"]!))
    //        let adInfoButtonTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_title_font"]!))
    //        let adInfoButtonFramLayoutGradientOption = param["adinfo_button_gradient_option"]
    //        let pointIconDefault = param["point_icon_name"]!
    //        let pointIconSub = param["point_icon_name_sub"]!
    //        let option = param["option"]!
    //
    //
    //        // 카테고리 레이아웃
    //        let categoryMenuLayout = AdListMenuViewLayout()
    //        // 선택된 메뉴의 폰트 색상
    //        categoryMenuLayout.itemButton.colorSelected = cateSelectedColor
    //        TnkLayout.shared.registerMenuViewLayout( type: .menu,
    //                                                 viewClass: DefaultAdListMenuView.self,
    //                                                 viewLayout: categoryMenuLayout)
    //
    //
    //        // 필터 레이아웃
    //        let filterMenuLayout = AdListFilterViewLayout()
    //        // 선택된 필터메뉴
    //        filterMenuLayout.itemButton.colorSelected = filterSelectedFontColor
    //        filterMenuLayout.itemButton.backgroundSelected = filterSelectedBgColor
    //
    //        // 선택안된 필터메뉴
    //        filterMenuLayout.itemButton.colorNormal = filterNotSelectedFontColor
    //        filterMenuLayout.itemButton.backgroundNormal = filterNotSelectedBgColor
    //
    //        TnkLayout.shared.registerMenuViewLayout( type: .filter,
    //                                                 viewClass: ScrollAdListMenuView.self,
    //                                                 viewLayout: filterMenuLayout)
    //
    //
    //
    //
    //
    //        // 일반광고 viewLayout
    //        let adListItemLayout = AdListItemViewLayout()
    //        customBodyUI(param:param, type:.normal, viewClass:DefaultAdListItemView.self, viewLayout:adListItemLayout)
    //
    //        let feedAdItemPageViewLayout = FeedAdItemPageViewLayout()
    //        customBodyUI(param:param, type:.promotion, viewClass:FeedAdListItemView.self, viewLayout:feedAdItemPageViewLayout)
    //
    //        let roundAdItemPageViewLayout = RoundAdItemPageViewLayout()
    //        customBodyUI(param:param, type:.newapps, viewClass:RightIconAdListItemView.self, viewLayout:roundAdItemPageViewLayout)
    //
    //        let feedAdItemScrollViewLayout = FeedAdItemScrollViewLayout()
    //        customBodyUI(param:param, type:.suggest, viewClass:FeedAdListItemView.self, viewLayout:feedAdItemScrollViewLayout)
    //
    //        let iconOnlyAdItemScrollViewLayout = IconOnlyAdItemScrollViewLayout()
    //        customBodyUI(param:param, type:.multi, viewClass:IconOnlyAdListItemView.self, viewLayout:iconOnlyAdItemScrollViewLayout)
    //
    //
    //        // 구매형 viewLayout
    //        let cpsBoxItemViewLayout = CpsBoxItemViewLayout()
    //        customBodyUI(param:param, type:.cpslist, viewClass:CpsBoxItemView.self, viewLayout:cpsBoxItemViewLayout)
    //
    //        let cpsBoxItemScrollViewLayout = CpsBoxItemScrollViewLayout()
    //        customBodyUI(param:param, type:.favorite, viewClass:CpsBoxItemView.self, viewLayout:cpsBoxItemScrollViewLayout)
    //        customBodyUI(param:param, type:.recommend, viewClass:CpsBoxItemView.self, viewLayout:cpsBoxItemScrollViewLayout)
    //
    //
    //        let cpsListItemPageViewLayout = CpsListItemPageViewLayout()
    //        customBodyUI(param:param, type:.popular, viewClass:CpsListItemView.self, viewLayout:cpsListItemPageViewLayout)
    //        customBodyUI(param:param, type:.reward, viewClass:CpsListItemView.self, viewLayout:cpsListItemPageViewLayout)
    //
    //        let cpsBoxItemPageGrayLayout = CpsBoxItemPageGrayLayout()
    //        customBodyUI(param:param, type:.newitem, viewClass:CpsBoxItemView.self, viewLayout:cpsBoxItemPageGrayLayout)
    //
    //        let noCpsItemViewLayout = NoCpsItemViewLayout()
    //        customBodyUI(param:param, type:.nocps, viewClass:CpsBoxItemView.self, viewLayout:noCpsItemViewLayout)
    //
    //
    //
    //
    //        // 광고 상세 화면
    //        let detailViewLayout = DefaultAdDetailViewLayout()
    //        detailViewLayout.titleTitleLabel.color = adInfoTitleFontColor // 타이틀
    //        detailViewLayout.titleDescLabel.color = adInfoDescFontColor // 액션
    //        detailViewLayout.titlePointAmountLabel.color = adInfoPointAmtFontColor // 포인트 금액
    //        detailViewLayout.titlePointUnitLabel.color = adInfoPointUnitFontColor // 포인트 단위
    //        detailViewLayout.titlePointIconImage.imageNormal = UIImage(named:pointIconDefault)
    //
    //
    //
    //        detailViewLayout.buttonFrameLayout.frameBackgroundColor = adInfoButtonBgColor // 버튼 색상
    //        detailViewLayout.buttonFrameLayout.descLabel.color = adInfoButtonDescFontColor // 버튼 액션 폰트 색상
    //        detailViewLayout.buttonFrameLayout.titleLabel.color = adInfoButtonTitleFontColor // 버튼 포인트금액, 포인트단위 폰트 색상
    //        detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = UIImage(named: pointIconSub)
    //
    //
    //
    //
    //
    //
    //        switch option {
    //
    //            // 재화 이이콘, 단위 둘다 표시
    //        case "1" :
    //
    //            detailViewLayout.titlePointIconImage.imageNormal = UIImage(named: pointIconDefault)
    //            detailViewLayout.pointAmountFormat = "{point}{unit}"
    //            detailViewLayout.titlePointUnitVisible = false
    //            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = UIImage(named: pointIconSub)
    //            detailViewLayout.buttonFrameLayout.pointAmountFormat = "{point}{unit}"
    //            detailViewLayout.buttonFrameLayout.pointUnitVisible = false
    //
    //
    //
    //            // 재화 아이콘만 표시
    //        case "2" :
    //
    //            detailViewLayout.titlePointIconImage.imageNormal = UIImage(named: pointIconDefault)
    //            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = UIImage(named: pointIconSub)
    //            detailViewLayout.titlePointUnitVisible = false
    //            detailViewLayout.buttonFrameLayout.pointUnitVisible = false
    //
    //
    //            // 재화 단위만 표시
    //        case "3" :
    //
    //            detailViewLayout.titlePointIconImage.imageNormal = nil
    //            detailViewLayout.pointAmountFormat = "{point}{unit}"
    //            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil
    //            detailViewLayout.buttonFrameLayout.pointAmountFormat = "{point}{unit}"
    //            detailViewLayout.titlePointUnitVisible = false
    //            detailViewLayout.buttonFrameLayout.pointUnitVisible = false
    //
    //
    //            // 둘다 표시 안함
    //        case "4" :
    //
    //            detailViewLayout.titlePointIconImage.imageNormal = nil
    //            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil
    //            detailViewLayout.titlePointUnitVisible = false
    //            detailViewLayout.buttonFrameLayout.pointUnitVisible = false
    //
    //
    //
    //        default:
    //
    //            break
    //        }
    //
    //
    //        // 버튼 프레임아웃 gradient 백그라운드 설정
    //        let gradient = CAGradientLayer()
    //        // default
    //        var startColor = TnkColor.semantic(UIColor.white.withAlphaComponent(1), UIColor.white.withAlphaComponent(1))
    //        var endColor = TnkColor.semantic(UIColor.white.withAlphaComponent(0), UIColor.white.withAlphaComponent(0))
    //        // dark mode
    //        if( adInfoButtonFramLayoutGradientOption == "D" ) {
    //
    //            startColor = TnkColor.semantic(UIColor.black.withAlphaComponent(1), UIColor.black.withAlphaComponent(1))
    //            endColor = TnkColor.semantic(UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0))
    //        }
    //        gradient.colors = [startColor.cgColor, endColor.cgColor]
    //        gradient.locations = [0.85 , 1.0]
    //        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
    //        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
    //        detailViewLayout.buttonFrameLayout.backgroundGradient = gradient
    //
    //
    //        TnkLayout.shared.detailViewLayout = detailViewLayout
    //
    //    }

    // Color hexString -> Int
    private func hexaStringToInt(_hexaStr: String) -> Int {
        if _hexaStr.hasPrefix("#") {
            let tmp = _hexaStr.trimmingCharacters(in: ["#"])
            let result = "ff" + tmp
            return Int(result, radix: 16)!
        } else {
            return 0
        }

    }

    // Color hexString -> UIColor
    private func hexaStringToColor(_hexaStr: String) -> UIColor {
        if _hexaStr.hasPrefix("#") {
            let tmp = _hexaStr.trimmingCharacters(in: ["#"])
            let result = "ff" + tmp
            return TnkColor.argb(Int(result, radix: 16)!)
        } else {
            return TnkColor.argb(0xffffff)

        }
    }

    private func reSizeImage(iamgeName: String, width: Int, height: Int)
        -> UIImage
    {

        let customImage = UIImage(named: iamgeName)

        let newImageRect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        customImage?.draw(in: newImageRect)
        let newImage =
            (UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(
                .alwaysOriginal
            ))!
        UIGraphicsEndImageContext()

        return newImage
    }

    public func closeAllView(viewController: UIViewController) {
        viewController.dismiss(animated: false)
    }
    //    public func closeOfferwall(viewController:UIViewController){
    //        if let presentVC = viewController.presentedViewController
    //        {
    //            print(String(describing: presentVC.frameworkName))
    //            if(presentVC.frameworkName == "TnkRwdSdk2" || presentVC.self is TnkUINavigationController){
    //                viewController.dismiss(animated: false)
    //            }
    //        }
    //    }
    public func closeOfferwall(viewController: UIViewController) {
        if let presentVC = viewController.presentedViewController {
            print(String(describing: presentVC.frameworkName))
            if presentVC.self is TnkUINavigationController {
                viewController.dismiss(animated: false)
            }
        }
    }
    public func closeAdItem(viewController: UIViewController) {
        if let presentVC = viewController.presentedViewController {
            print(String(describing: presentVC.frameworkName))
            if presentVC.frameworkName == "TnkRwdSdk2" {
                viewController.dismiss(animated: false)
            }
        }
    }

}

extension UIViewController {
    var frameworkName: String? {
        let className = NSStringFromClass(type(of: self))
        if let range = className.range(of: ".", options: .backwards) {
            let frameworkName = String(className[..<range.lowerBound])
            return frameworkName
        }
        return nil
    }
}

class TnkUINavigationController: UINavigationController {

}

public class FlutterPlacementView: NSObject, PlacementEventListener {

    var placementView: AdPlacementView? = nil
    var placementId: String? = nil
    var rootViewContorller: UIViewController? = nil
    init(
        frame: CGRect,
        viewController: UIViewController,
        placementId: String,
        onLoadListener: @escaping (_ res: String) -> Void
    ) {
        self.onLoadListener = onLoadListener
        rootViewContorller = UIApplication.shared.keyWindow?.rootViewController
        placementView = AdPlacementView(
            frame: rootViewContorller!.view.frame,
            viewController: rootViewContorller!
        )
        self.placementId = placementId

    }

    var onLoadListener: (_ res: String) -> Void
    var onItemClickListener: (Bool, TnkRwdSdk2.TnkError?) -> Void = {
        isSuccess,
        error in

    }

    public func loadItem() {
        placementView?.placementListener = self
        placementView?.loadData(placementId: placementId!)
    }

    public func clickItem(
        appid: String,
        callback: @escaping (Bool, TnkRwdSdk2.TnkError?) -> Void
    ) {
        onItemClickListener = callback
        let adid: Int? = Int(appid)
        placementView?.onItemClick(appId: adid!, completion: callback)
    }

    public func setAttAlertMsg() {
        let appName =
            Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? "앱이름"
        TnkStrings.shared.need_att_allow =
            "추적허용이 활성화되어야 참여가 가능한 광고입니다.\n\n[설정 > \(appName) > 추적 허용 > 켜기]"
    }

    /// AdPlacementView 에 광고가 로딩되는 시점에 호출됩니다.
    ///
    /// - Parameters:
    ///    - placementId: 광고 로딩을 요청한 placement Id 값
    ///    - customData : 플레이스먼트 설정시 customData 항목에 입력한 값
    public func didAdDataLoaded(placementId: String, customData: String?) {
        //        let viewController = UIApplication.shared.keyWindow?.rootViewController
        let pubInfoJson: String = placementView!.getPubInfoJson()!
        let adListJson: String = placementView!.getAdListJson()!
        /*
         put("res_code", "1")
                                         put("res_message", "success")
         */
        let resJson =
            "{\"res_code\":\"1\", \"res_message\":\"success\", \"pub_info\":"
            + pubInfoJson + ", \"ad_list\":" + adListJson + "}"
        onLoadListener(resJson)
    }

    /// AdPlacementView 에 광고 로딩이 실패하는 시점에 호출됩니다.
    ///
    /// - Parameters:
    ///   - placementId: 광고 로딩을 요청한 placement Id 값
    public func didFailedToLoad(placementId: String) {
        let resJson = "{\"res_code\":\"-99\", \"res_message\":\"광고 로드 실패\"}"
        onLoadListener(resJson)
    }

    /// AdPlacementView 의 광고를 클릭하면 호출됩니다.
    ///
    /// - Parameters:
    ///   - appId : 클릭한 광고의 appId
    ///   - appName : 클릭한 광고의 명칭
    public func didAdItemClicked(
        placementId: String,
        appId: Int,
        appName: String
    ) {

    }

    /// 더보기 링크를 클릭하면 호출됩니다.
    public func didMoreLinkClicked(placementId: String) {

    }
}
