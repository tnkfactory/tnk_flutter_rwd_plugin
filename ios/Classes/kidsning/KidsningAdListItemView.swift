//
//  KidsningAdListItemView.swift
//  newOfferwall2
//
//  Created by  김동혁 on 2023/09/01.
//

import UIKit
import TnkRwdSdk2

class KidsningAdListItemView : AdListItemView {
    var itemView:KidsningAdItemView?
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        
        itemView = loadView()
        
        if let view = itemView {
            contentView.addSubview(view)
            NSLayoutConstraint.activate([
                view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                view.topAnchor.constraint(equalTo: contentView.topAnchor),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
            
            view.iconImageView.layer.cornerRadius = 4
            view.iconImageView.layer.borderWidth = 1
            view.iconImageView.layer.borderColor = TnkColor.argb(0xfff1f3f5).cgColor

            
        }
              
        
        
        //itemView?.pointAmountTag.isUserInteractionEnabled = false
        //itemView?.pointAmountTag.setBackgroundColor(TnkColor.argb(0xff5f0d80), for: .normal)
        //itemView?.pointAmountTag.setTitleColor(.white, for: .normal)
        //itemView?.pointAmountTag.layer.cornerRadius = 13 // 포인크 금액 영역 라운드 처리
        //itemView?.pointAmountTag.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        //itemView?.pointAmountTag.titleLabel?.textColor = .white
        
        //itemView?.divider.backgroundColor = TnkColor.argb(0xfff1f3f5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadView() -> KidsningAdItemView {
        let bundleName = Bundle(for: type(of: self))
        let nib = UINib(nibName: "KidsningAdItemView", bundle: bundleName)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! KidsningAdItemView
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
    
    override func getIconImageView() -> UIImageView? {
        return itemView?.iconImageView
    }
    
    override func useImageFeed() -> Bool {
        return false
    }
    
    override func useImageIcon() -> Bool {
        return true
    }
    
    override func setData(_ adItem: AdItem?, row: Int, itemsPerPage: Int, itemIndex: Int, numberOfItems: Int) {
        if let adItem = adItem as? AdListItem {
            
            itemView?.titleLabel.text = adItem.appName
            itemView?.pointAmountTag.setTitle(adItem.pointText + "P", for: .normal)
            
            // 광고 상태에 따라서 타이틀 문구를 변경한다.
            if adItem.state == .confirm {
                itemView?.descLabel.text = "설치확인 후 리워드가 지급됩니다."
            }
            else if adItem.state == .paid {
                itemView?.descLabel.text = "이미 지급된 광고입니다."
            }
            else if adItem.state == .disabled || adItem.state == .ended {
                itemView?.descLabel.text = "종료된 광고입니다."
            }
            else {
                itemView?.descLabel.text = adItem.cmpnDesc
            }
        }
    }
}

class KidsningAdItemView : UIView {
    @IBOutlet var iconImageView:UIImageView!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var pointAmountTag:UIButton!
    @IBOutlet var descLabel:UILabel!
    @IBOutlet var divider:UIView!
}
