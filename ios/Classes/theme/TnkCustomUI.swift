//
//  TnkCustomUI.swift
//  Pods
//
//  Created by jameson on 2/27/24.
//

import Foundation
import TnkRwdSdk2

public class TnkCustomUI {
    
    
    func setCustomUIDefault(param:Dictionary<String,String>) {
        let mainColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["app_main_color"]!))

        let cateSelectedColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["category_select_font"]!))
        let filterSelectedBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_select_background"]!))
        let filterSelectedFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_select_font"]!))
        let filterNotSelectedBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_not_select_background"]!))
        let filterNotSelectedFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["filter_not_select_font"]!))

        let adInfoTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_title_font"]!))
        let adInfoDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_desc_font"]!))
        let adInfoPointUnitFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_point_unit_font"]!))
        let adInfoPointAmtFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_point_amount_font"]!))
        let adInfoButtonBgColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_background"]!))
        let adInfoButtonDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_desc_font"]!))
        let adInfoButtonTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adinfo_button_title_font"]!))
        let adInfoButtonFramLayoutGradientOption = param["adinfo_button_gradient_option"]
        let pointIconDefault = param["point_icon_name"]!
        let pointIconSub = param["point_icon_name_sub"]!
        let option = param["option"]!
        

        TnkColor.PRIMARY_COLOR = mainColor


        // 카테고리 레이아웃
        let categoryMenuLayout = AdListMenuViewLayout()
        // 선택된 메뉴의 폰트 색상
        categoryMenuLayout.itemButton.colorSelected = cateSelectedColor
        categoryMenuLayout.messageShowSeconds = 0        
        TnkLayout.shared.registerMenuViewLayout( type: .menu,
                                                 viewClass: DefaultAdListMenuView.self,
                                                 viewLayout: categoryMenuLayout)


        // 필터 레이아웃
        let filterMenuLayout = AdListFilterViewLayout()
        // 선택된 필터메뉴
        filterMenuLayout.itemButton.colorSelected = filterSelectedFontColor
        filterMenuLayout.itemButton.backgroundSelected = filterSelectedBgColor

        // 선택안된 필터메뉴
        filterMenuLayout.itemButton.colorNormal = filterNotSelectedFontColor
        filterMenuLayout.itemButton.backgroundNormal = filterNotSelectedBgColor

        TnkLayout.shared.registerMenuViewLayout( type: .filter,
                                                 viewClass: ScrollAdListMenuView.self,
                                                 viewLayout: filterMenuLayout)





        // 일반광고 viewLayout
        let adListItemLayout = AdListItemViewLayout()
        customBodyUI(param:param, type:.normal, viewClass:DefaultAdListItemView.self, viewLayout:adListItemLayout)

        let feedAdItemPageViewLayout = FeedAdItemPageViewLayout()
        customBodyUI(param:param, type:.promotion, viewClass:FeedAdListItemView.self, viewLayout:feedAdItemPageViewLayout)

        let roundAdItemPageViewLayout = RoundAdItemPageViewLayout()
        customBodyUI(param:param, type:.newapps, viewClass:RightIconAdListItemView.self, viewLayout:roundAdItemPageViewLayout)

        let feedAdItemScrollViewLayout = FeedAdItemScrollViewLayout()
        customBodyUI(param:param, type:.suggest, viewClass:FeedAdListItemView.self, viewLayout:feedAdItemScrollViewLayout)

//        let iconOnlyAdItemScrollViewLayout = IconOnlyAdItemScrollViewLayout()
//        customBodyUI(param:param, type:.multi, viewClass:IconOnlyAdListItemView.self, viewLayout:iconOnlyAdItemScrollViewLayout)


        // 구매형 viewLayout
        let cpsBoxItemViewLayout = CpsBoxItemViewLayout()
        customBodyUI(param:param, type:.cpslist, viewClass:CpsBoxItemView.self, viewLayout:cpsBoxItemViewLayout)

        let cpsBoxItemScrollViewLayout = CpsBoxItemScrollViewLayout()
        customBodyUI(param:param, type:.favorite, viewClass:CpsBoxItemView.self, viewLayout:cpsBoxItemScrollViewLayout)
        customBodyUI(param:param, type:.recommend, viewClass:CpsBoxItemView.self, viewLayout:cpsBoxItemScrollViewLayout)


        let cpsListItemPageViewLayout = CpsListItemPageViewLayout()
        customBodyUI(param:param, type:.popular, viewClass:CpsListItemView.self, viewLayout:cpsListItemPageViewLayout)
        customBodyUI(param:param, type:.reward, viewClass:CpsListItemView.self, viewLayout:cpsListItemPageViewLayout)

        let cpsBoxItemPageGrayLayout = CpsBoxItemPageGrayLayout()
        customBodyUI(param:param, type:.newitem, viewClass:CpsBoxItemView.self, viewLayout:cpsBoxItemPageGrayLayout)
       
        // cps 상품 없을 경우
        let noCpsItemViewLayout = NoCpsItemViewLayout()
        customBodyUI(param:param, type:.nocps, viewClass:CpsBoxItemView.self, viewLayout:noCpsItemViewLayout)




        // 광고 상세 화면
        let detailViewLayout = DefaultAdDetailViewLayout()
        detailViewLayout.titleTitleLabel.color = adInfoTitleFontColor // 타이틀
        detailViewLayout.titleDescLabel.color = adInfoDescFontColor // 액션
        detailViewLayout.titlePointAmountLabel.color = adInfoPointAmtFontColor // 포인트 금액
        detailViewLayout.titlePointUnitLabel.color = adInfoPointUnitFontColor // 포인트 단위
        detailViewLayout.titlePointIconImage.imageNormal = UIImage(named:pointIconDefault)



        detailViewLayout.buttonFrameLayout.frameBackgroundColor = adInfoButtonBgColor // 버튼 색상
        detailViewLayout.buttonFrameLayout.descLabel.color = adInfoButtonDescFontColor // 버튼 액션 폰트 색상
        detailViewLayout.buttonFrameLayout.titleLabel.color = adInfoButtonTitleFontColor // 버튼 포인트금액, 포인트단위 폰트 색상
        detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = UIImage(named: pointIconSub)
        
        
        detailViewLayout.actionItemLayout.itemPointAmountLabel.color = adInfoPointAmtFontColor






        switch option {

            // 재화 이이콘, 단위 둘다 표시
        case "1" :

            detailViewLayout.titlePointIconImage.imageNormal = UIImage(named: pointIconDefault)
            detailViewLayout.pointAmountFormat = "{point}{unit}"
            detailViewLayout.titlePointUnitVisible = false
            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = UIImage(named: pointIconSub)
            detailViewLayout.buttonFrameLayout.pointAmountFormat = "{point}{unit}"
            detailViewLayout.buttonFrameLayout.pointUnitVisible = false



            // 재화 아이콘만 표시
        case "2" :

            detailViewLayout.titlePointIconImage.imageNormal = UIImage(named: pointIconDefault)
            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = UIImage(named: pointIconSub)
            detailViewLayout.titlePointUnitVisible = false
            detailViewLayout.buttonFrameLayout.pointUnitVisible = false


            // 재화 단위만 표시
        case "3" :

            detailViewLayout.titlePointIconImage.imageNormal = nil
            detailViewLayout.pointAmountFormat = "{point}{unit}"
            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil
            detailViewLayout.buttonFrameLayout.pointAmountFormat = "{point}{unit}"
            detailViewLayout.titlePointUnitVisible = false
            detailViewLayout.buttonFrameLayout.pointUnitVisible = false


            // 둘다 표시 안함
        case "4" :

            detailViewLayout.titlePointIconImage.imageNormal = nil
            detailViewLayout.buttonFrameLayout.pointIconImage.imageNormal = nil
            detailViewLayout.titlePointUnitVisible = false
            detailViewLayout.buttonFrameLayout.pointUnitVisible = false



        default:

            break
        }


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
    
    private func customBodyUI(param:Dictionary<String,String>, type: LayoutType, viewClass: AnyClass, viewLayout:AdListItemViewLayout) {
        
        
        let adListTitleFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_title_font"]!))
        let adListDescFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_desc_font"]!))
        let adListPointUnitFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_unit_font"]!))
        let adListPointAmtFontColor = TnkColor.argb(hexaStringToInt(_hexaStr: param["adlist_point_amount_font"]!))
        let pointIconDefault = param["point_icon_name"]!
        let option = param["option"]!
        
        // cps 상품 검색 view layout
        let searchViewLayout = TnkLayout.shared.searchViewLayout.listItemViewLayout
        // 참여중 내역 캠페인 제안 layout
        let noAdItemViewLayout = TnkLayout.shared.mymenuViewLayout.noAdItemViewLayout
        
//        let infoViewLayout = TnkLayout.shared.mymenuViewLayout.infoItemViewLayout
        
        let myMenuListItemLayout = TnkLayout.shared.mymenuViewLayout.listItemViewLayout

        
            switch option {
               
                // 재화 이이콘, 단위 둘다 표시
            case "1" :
                viewLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
                viewLayout.pointAmountFormat = "{point}{unit}"
                viewLayout.pointUnitVisible = false
                
                
                searchViewLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
                searchViewLayout.pointAmountFormat = "{point}{unit}"
                searchViewLayout.pointUnitVisible = false
                
                noAdItemViewLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
                noAdItemViewLayout.pointAmountFormat = "{point}{unit}"
                noAdItemViewLayout.pointUnitVisible = false
                
                myMenuListItemLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
                myMenuListItemLayout.pointAmountFormat = "{point}{unit}"
                myMenuListItemLayout.pointUnitVisible = false

                // 재화 아이콘만 표시
            case "2" :
                viewLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
                viewLayout.pointUnitVisible = false
                
                searchViewLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
                searchViewLayout.pointUnitVisible = false
                
                noAdItemViewLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
                noAdItemViewLayout.pointUnitVisible = false
                
                myMenuListItemLayout.pointIconImage.imageNormal = UIImage(named: pointIconDefault)
                myMenuListItemLayout.pointUnitVisible = false
                

                // 재화 단위만 표시
            case "3" :
                viewLayout.pointIconImage.imageNormal = nil
                viewLayout.pointAmountFormat = "{point}{unit}"
                viewLayout.pointUnitVisible = false
                
                searchViewLayout.pointIconImage.imageNormal = nil
                searchViewLayout.pointAmountFormat = "{point}{unit}"
                searchViewLayout.pointUnitVisible = false
                
                noAdItemViewLayout.pointIconImage.imageNormal = nil
                noAdItemViewLayout.pointAmountFormat = "{point}{unit}"
                noAdItemViewLayout.pointUnitVisible = false
                
                myMenuListItemLayout.pointIconImage.imageNormal = nil
                myMenuListItemLayout.pointAmountFormat = "{point}{unit}"
                myMenuListItemLayout.pointUnitVisible = false
                
                
                // 둘다 표시 안함
            case "4" :
                viewLayout.pointIconImage.imageNormal = nil
                viewLayout.pointUnitVisible = false
                
                searchViewLayout.pointIconImage.imageNormal = nil
                searchViewLayout.pointUnitVisible = false
                
                noAdItemViewLayout.pointIconImage.imageNormal = nil
                noAdItemViewLayout.pointUnitVisible = false
                
                myMenuListItemLayout.pointIconImage.imageNormal = nil
                myMenuListItemLayout.pointUnitVisible = false
                
       
            default:
                
                break
            }
        
        
        
        
        viewLayout.titleLabel.color = adListTitleFontColor
        viewLayout.descLabel.color = adListDescFontColor
        viewLayout.pointAmountLabel.color = adListPointAmtFontColor
        viewLayout.pointUnitLabel.color = adListPointUnitFontColor
        viewLayout.discountRateLabel.color = adListPointAmtFontColor
        
        
        searchViewLayout.titleLabel.color = adListTitleFontColor
        searchViewLayout.descLabel.color = adListDescFontColor
        searchViewLayout.pointAmountLabel.color = adListPointAmtFontColor
        searchViewLayout.pointUnitLabel.color = adListPointUnitFontColor
        searchViewLayout.discountRateLabel.color = adListPointAmtFontColor
        
        
        noAdItemViewLayout.titleLabel.color = adListTitleFontColor
        noAdItemViewLayout.descLabel.color = adListDescFontColor
        noAdItemViewLayout.pointAmountLabel.color = adListPointAmtFontColor
        noAdItemViewLayout.pointUnitLabel.color = adListPointUnitFontColor
        noAdItemViewLayout.discountRateLabel.color = adListPointAmtFontColor
        
        myMenuListItemLayout.titleLabel.color = adListTitleFontColor
        myMenuListItemLayout.descLabel.color = adListDescFontColor
        myMenuListItemLayout.pointAmountLabel.color = adListPointAmtFontColor
        myMenuListItemLayout.pointUnitLabel.color = adListPointUnitFontColor
        myMenuListItemLayout.discountRateLabel.color = adListPointAmtFontColor
        

            
    
        
        TnkLayout.shared.registerItemViewLayout(type: type, viewClass: viewClass, viewLayout: viewLayout)
        
    }
    
}
