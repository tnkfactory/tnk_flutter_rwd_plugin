//
//  OfferWallMenuViewHeader.swift
//  tnk_flutter_rwd
//
//  Created by jameson on 2023/07/06.
//

import Foundation
import UIKit
import TnkRwdSdk2

class OfferWallMenuViewHeader : AdListMenuView {
    var containerView = UIView()
    var messageLabel = UILabel()  // 최대 xxxx 포인트 모을 수 있어요.
    
    override init(frame: CGRect, viewLayout:AdListMenuViewLayout) {
        super.init(frame: frame, viewLayout: viewLayout)
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20), // 16 -> 20
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20), // -16 -> -20
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),    // 4 -> 8
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0), // 4 -> -8 -> -16
            containerView.heightAnchor.constraint(equalToConstant: 33), // 40 -> 33
            messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            messageLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16)
        ])
        
        containerView.backgroundColor = TnkColor.argb(0xfff1f3f5)
        containerView.layer.cornerRadius = 4
        
        messageLabel.font = TnkFonts.shared.fontManager.getBoldFont(ofSize: 12)
        messageLabel.textColor = TnkColor.argb(0xff666666)
        messageLabel.text = ""
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func setTotalPoint(totalAdsPoint:Int, totalAdsCount:Int, totalCpsPoint:Int, totalCpsCount:Int) {
        print("### setTotalPoint \(totalAdsPoint), \(totalCpsPoint)")
        
        let totalPoint = totalAdsPoint + totalCpsPoint
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSize = 3
        let formattedPoint = numberFormatter.string(from: NSNumber(value:totalPoint)) ?? "\(totalPoint)"
        
        let pointColor = TnkColor.argb(0xff5f0d80)
        let attrPoint = NSAttributedString(string: formattedPoint,
                                           attributes: [.foregroundColor : pointColor,
                                                        .font : TnkFonts.shared.fontManager.getBoldFont(ofSize: 12)])
        
        let attrMessage = NSMutableAttributedString(string: "최대 ")
       
        
        attrMessage.append(attrPoint)
        
        let trailMessage = NSAttributedString(string: " 포인트를 모을 수 있어요.")
        attrMessage.append(trailMessage)
        
        messageLabel.attributedText = attrMessage
    }
}

class OfferWallMenuViewHeaderLayout : AdListMenuViewLayout {
 
    @objc
    override public init() {
        super.init()
    }
    
    override public func viewHeight(_ parentSize:CGSize) -> CGFloat {
        return 57  // 높이 33 -> 49 -> 57
    }
    
    override public func menuView(_ frame:CGRect) -> AdListMenuView {
//        return OfferWallMenuViewHeader(frame: frame, viewLayout: self)
        return OfferWallMenuViewHeader(frame: frame, viewLayout: self)
    }
}


