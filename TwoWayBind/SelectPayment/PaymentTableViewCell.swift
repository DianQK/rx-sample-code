//
//  PaymentTableViewCell.swift
//  RxDealCell
//
//  Created by DianQK on 8/5/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum Payment: Hashable, Equatable, IdentifiableType {
    /// 支付宝
    case alipay
    /// 微信
    case wechat
    /// 银联
    case unionpay
    // Apple Pay
    case applepay

    fileprivate var icon: UIImage? {
        switch self {
        case .alipay:
            return #imageLiteral(resourceName: "purchase_icon_alipay")
            //            return R.image.purchase_icon_alipay()
        case .wechat:
            return #imageLiteral(resourceName: "purchase_icon_wechat")
            //            return R.image.purchase_icon_wechat()
        case .unionpay:
            return #imageLiteral(resourceName: "purchase_icon_unionpay")
            //            return R.image.purchase_icon_unionpay()
        case .applepay:
            return #imageLiteral(resourceName: "purchase_icon_applepay")
        }
    }

    var name: String {
        switch self {
        case .alipay:
            return "支付宝支付"
        case .wechat:
            return "微信支付"
        case .unionpay:
            return "银联支付"
        case .applepay:
            return "Apple Pay"
        }
    }

    var identity: Int {
        return hashValue
    }
}

class PaymentTableViewCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var selectButton: UIButton!

    private var _payment: Payment = Payment.alipay {
        didSet {
            iconImageView.image = _payment.icon
            nameLabel.text = _payment.name
        }
    }

    func setPayment(_ payment: Payment) {
        _payment = payment
    }

}

extension Reactive where Base: PaymentTableViewCell {
    var isSelectedPayment: UIBindingObserver<UIButton, Bool> {
        return base.selectButton.rx.selected
    }
}
