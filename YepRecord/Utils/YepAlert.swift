
//
//  YepAlert.swift
//  Yep
//
//  Created by NIX on 15/3/17.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit

final class YepAlert {

    class func alert(title: String, message: String?, dismissTitle: String, inViewController viewController: UIViewController?, withDismissAction dismissAction: (() -> Void)?) {
        
        DispatchQueue.main.async {

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let action: UIAlertAction = UIAlertAction(title: dismissTitle, style: .default) { action in
                if let dismissAction = dismissAction {
                    dismissAction()
                }
            }
            alertController.addAction(action)

            viewController?.present(alertController, animated: true, completion: nil)
        }
    }

    class func alertSorry(message: String?, inViewController viewController: UIViewController?, withDismissAction dismissAction: @escaping (() -> Void)) {

        alert(title: NSLocalizedString("Sorry", comment: ""), message: message, dismissTitle: NSLocalizedString("OK", comment: ""), inViewController: viewController, withDismissAction: dismissAction)
    }

    class func alertSorry(message: String?, inViewController viewController: UIViewController?) {

        alert(title: NSLocalizedString("Sorry", comment: ""), message: message, dismissTitle: NSLocalizedString("OK", comment: ""), inViewController: viewController, withDismissAction: nil)
    }

    class func textInput(title: String, placeholder: String?, oldText: String?, dismissTitle: String, inViewController viewController: UIViewController?, withFinishedAction finishedAction: ((_ text: String) -> Void)?) {

        DispatchQueue.main.async {

            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.placeholder = placeholder
                textField.text = oldText
            }

            let action: UIAlertAction = UIAlertAction(title: dismissTitle, style: .default) { action in
                if let finishedAction = finishedAction {
                    if let textField = alertController.textFields?.first, let text = textField.text {
                        finishedAction(text)
                    }
                }
            }
            alertController.addAction(action)

            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    static weak var confirmAlertAction: UIAlertAction?
    
    class func textInput(title: String, message: String?, placeholder: String?, oldText: String?, confirmTitle: String, cancelTitle: String, inViewController viewController: UIViewController?, withConfirmAction confirmAction: ((_ text: String) -> Void)?, cancelAction: (() -> Void)?) {

        DispatchQueue.main.async {

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.placeholder = placeholder
                textField.text = oldText
                textField.addTarget(self, action: #selector(YepAlert.handleTextFieldTextDidChangeNotification(_:)), for: .editingChanged)
            }

            let _cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                cancelAction?()
            }
            
            alertController.addAction(_cancelAction)
            
            let _confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .default) { action in
                if let textField = alertController.textFields?.first, let text = textField.text {
                    
                    confirmAction?(text)
                }
            }
            _confirmAction.isEnabled = false
            self.confirmAlertAction = _confirmAction
            
            alertController.addAction(_confirmAction)

            viewController?.present(alertController, animated: true, completion: nil)
        }
    }

    @objc class func handleTextFieldTextDidChangeNotification(_ sender: UITextField) {

        YepAlert.confirmAlertAction?.isEnabled = (sender.text?.utf16.count)! >= 1
    }
    
    class func confirmOrCancel(title: String, message: String, confirmTitle: String, cancelTitle: String, inViewController viewController: UIViewController?, withConfirmAction confirmAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {

        DispatchQueue.main.async {

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                cancelAction()
            }
            alertController.addAction(cancelAction)

            let confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .default) { action in
                confirmAction()
            }
            alertController.addAction(confirmAction)

            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension UIViewController {

    func alertCanNotAccessCameraRoll() {

        DispatchQueue.main.async {
//            YepAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Yep can not access your Camera Roll!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: String.trans_titleChangeItNow, cancelTitle: String.trans_titleDismiss, inViewController: self, withConfirmAction: {
//
//                UIApplication.sharedApplication().openURL(URL(string: UIApplicationOpenSettingsURLString)!)
//
//            }, cancelAction: {
//            })
        }
    }

//    func alertCanNotOpenCamera() {
//
//        DispatchQueue.main.async {
//            YepAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Yep can not open your Camera!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: String.trans_titleChangeItNow, cancelTitle: String.trans_titleDismiss, inViewController: self, withConfirmAction: {
//
//                UIApplication.sharedApplication().openURL(URL(string: UIApplicationOpenSettingsURLString)!)
//
//            }, cancelAction: {
//            })
//        }
//    }

    func alertCanNotAccessMicrophone() {

        DispatchQueue.main.async {
//            YepAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Yep can not access your Microphone!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: String.trans_titleChangeItNow, cancelTitle: String.trans_titleDismiss, inViewController: self, withConfirmAction: {
//
//                UIApplication.sharedApplication().openURL(URL(string: UIApplicationOpenSettingsURLString)!)
//
//            }, cancelAction: {
//            })
        }
    }

//    func alertCanNotAccessContacts() {
//
//        DispatchQueue.main.async {
//            YepAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Yep can not read your Contacts!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: String.trans_titleChangeItNow, cancelTitle: String.trans_titleDismiss, inViewController: self, withConfirmAction: {
//
//            UIApplication.sharedApplication().openURL(URL(string: UIApplicationOpenSettingsURLString)!)
//
//            }, cancelAction: {
//            })
//        }
//    }

//    func alertCanNotAccessLocation() {
//
//        DispatchQueue.main.async {
//            YepAlert.confirmOrCancel(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Yep can not get your Location!\nBut you can change it in iOS Settings.", comment: ""), confirmTitle: String.trans_titleChangeItNow, cancelTitle: String.trans_titleDismiss, inViewController: self, withConfirmAction: {
//
//                UIApplication.sharedApplication().openURL(URL(string: UIApplicationOpenSettingsURLString)!)
//
//            }, cancelAction: {
//            })
//        }
//    }

    func showProposeMessageIfNeedForContactsAndTryPropose(propose: @escaping Propose) {

        if PrivateResource.contacts.isNotDeterminedAuthorization {

            DispatchQueue.main.async {

                YepAlert.confirmOrCancel(title: NSLocalizedString("Notice", comment: ""), message: NSLocalizedString("Yep need to read your Contacts to continue this operation.\nIs that OK?", comment: ""), confirmTitle: NSLocalizedString("OK", comment: ""), cancelTitle: NSLocalizedString("Not now", comment: ""), inViewController: self, withConfirmAction: {

                    propose()

                }, cancelAction: {
                })
            }

        } else {
            propose()
        }
    }
}

