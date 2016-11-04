//
//  HUD.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import MBProgressHUD

class HUD {

    private init() { }
    /**
     显示一个提示消息

     - parameter message: 显示内容
     */
    static func showMessage(_ message: String) {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)

        hud.mode = MBProgressHUDMode.text
        hud.label.text = message
        hud.margin = 10
        hud.offset.y = 150
        hud.removeFromSuperViewOnHide = true
        hud.isUserInteractionEnabled = false

        hud.hide(animated: true, afterDelay: 1)
    }
}
