//
//  showOfferwall+Listener.swift
//  tnk_flutter_rwd
//
//  Created by jameson on 2023/09/26.
//

import Foundation
import TnkRwdSdk2

extension SwiftTnkFlutterRwdPlugin : OfferwallEventListener
{
    
    public func didOfferwallRemoved() {
        print("closed")
        SwiftTnkFlutterRwdPlugin.channel?.invokeMethod("didOfferwallRemoved", arguments:"success")
    }
}
