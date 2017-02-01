//
//  RxQBImagePickerControllerDelegateProxy.swift
//  UploadImageDemo
//
//  Created by DianQK on 05/01/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import QBImagePicker
import RxSwift
import RxCocoa

public class RxQBImagePickerControllerDelegateProxy: DelegateProxy, DelegateProxyType, QBImagePickerControllerDelegate {

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let imagePickerController = object as? QBImagePickerController
        imagePickerController?.delegate = delegate as? QBImagePickerControllerDelegate
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let imagePickerController = object as? QBImagePickerController
        return imagePickerController?.delegate
    }
    
}
