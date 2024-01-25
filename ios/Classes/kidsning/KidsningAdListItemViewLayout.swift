//
//  KidsningAdListItemViewLayout.swift
//  newOfferwall2
//
//  Created by  김동혁 on 2023/09/01.
//

import UIKit
import TnkRwdSdk2

class KidsningAdListItemViewLayout : AdListItemViewLayout {
    
    override init() {
        super.init()
        
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    override func viewSize(_ parentSize:CGSize) -> CGSize {
        let width = parentSize.width - sectionInset.left - sectionInset.right
        
        let height:CGFloat = 80 // 광고 아이템 높이
        
        return CGSize(width: width, height:height)
    }
}
