//
//  Proposer.swift
//  Lady
//
//  Created by NIX on 15/7/11.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import AddressBook
import Contacts
import EventKit
import CoreLocation

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    
    let locationUsage: PrivateResource.LocationUsage
    let successAction: ProposerAction
    let failureAction: ProposerAction
    
    
    
    init(locationUsage: PrivateResource.LocationUsage, successAction: @escaping ProposerAction, failureAction: @escaping ProposerAction) {
        self.locationUsage = locationUsage
        self.successAction = successAction
        self.failureAction = failureAction
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        DispatchQueue.main.async {
            
            switch status {
                
            case .authorizedWhenInUse:
                self.locationUsage == .whenInUse ? self.successAction() : self.failureAction()
                
                Proposer._locationManager = nil
                Proposer._locationDelegate = nil
                
            case .authorizedAlways:
                self.locationUsage == .always ? self.successAction() : self.failureAction()
                
                Proposer._locationManager = nil
                Proposer._locationDelegate = nil
                
            case .denied:
                self.failureAction()
                
                Proposer._locationManager = nil
                Proposer._locationDelegate = nil
                
            default:
                break
            }
        }
    }
}

struct Proposer {
    static fileprivate var _locationManager: LocationDelegate?
    static fileprivate var _locationDelegate: LocationDelegate? // as strong ref
}

public enum PrivateResource {
    case photos
    case camera
    case microphone
    case contacts
    case reminders
    case calendar

    public enum LocationUsage {
        case whenInUse
        case always
    }
    case location(LocationUsage)

    public var isNotDeterminedAuthorization: Bool {
        switch self {
        case .photos:
            return PHPhotoLibrary.authorizationStatus() == .notDetermined
        case .camera:
            return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .notDetermined
        case .microphone:
            return AVAudioSession.sharedInstance().recordPermission() == .undetermined
        case .contacts:
             return CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .notDetermined
        case .reminders:
            return EKEventStore.authorizationStatus(for: .reminder) == .notDetermined
        case .calendar:
            return EKEventStore.authorizationStatus(for: .event) == .notDetermined
        case .location:
            return CLLocationManager.authorizationStatus() == .notDetermined
        }
    }

    public var isAuthorized: Bool {
        switch self {
        case .photos:
            return PHPhotoLibrary.authorizationStatus() == .authorized
        case .camera:
            return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
        case .microphone:
            return AVAudioSession.sharedInstance().recordPermission() == .granted
        case .contacts:
            return CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .authorized
        case .reminders:
            return EKEventStore.authorizationStatus(for: .reminder) == .authorized
        case .calendar:
            return EKEventStore.authorizationStatus(for: .event) == .authorized
        case let .location(usage):
            switch usage {
            case .whenInUse:
                return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
            case .always:
                return CLLocationManager.authorizationStatus() == .authorizedAlways
            }
        }
    }
}

public typealias Propose = () -> Void

public typealias ProposerAction = () -> Void

public func proposeToAccess(_ resource: PrivateResource, agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    
    func proposeToAccessEvent(for entityYype: EKEntityType, agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
        
        switch EKEventStore.authorizationStatus(for: entityYype) {
        case .authorized:
            successAction()
        case .notDetermined:
            EKEventStore().requestAccess(to: entityYype) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        successAction()
                    } else {
                        failureAction()
                    }
                }
            }
        default:
            failureAction()
        }
    }

    switch resource {

    case .photos:
        proposeToAccessPhotos(agreed: successAction, rejected: failureAction)

    case .camera:
        proposeToAccessCamera(agreed: successAction, rejected: failureAction)

    case .microphone:
        func proposeToAccessMicrophone(agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    granted ? successAction() : failureAction()
                }
            }
        }

        proposeToAccessMicrophone(agreed: successAction, rejected: failureAction)

    case .contacts:
        proposeToAccessPhotos(agreed: successAction, rejected: failureAction)

    case .reminders:
        proposeToAccessEvent(for: .reminder, agreed: successAction, rejected: failureAction)

    case .calendar:
        proposeToAccessEvent(for: .event, agreed: successAction, rejected: failureAction)

    case .location(let usage):
        
        func proposeToAccessLocation(_ locationUsage: PrivateResource.LocationUsage, agreed successAction: ProposerAction, rejected failureAction: ProposerAction) {
            
            switch CLLocationManager.authorizationStatus() {
                
            case .authorizedWhenInUse:
                if locationUsage == .whenInUse {
                    successAction()
                } else {
                    failureAction()
                }
                
            case .authorizedAlways:
                successAction()
                
            case .notDetermined:
                if CLLocationManager.locationServicesEnabled() {
                    
//                    let locationManager = CLLocationManager()
//                    Proposer._locationManager = locationManager
                    
//                    let delegate = LocationDelegate(locationUsage: locationUsage, successAction: successAction, failureAction: failureAction)
//                    Proposer._locationDelegate = delegate
                    
////                    locationManager.delegate = delegate
//                    
//                    switch locationUsage {
//                        
//                    case .whenInUse:
//                        locationManager.requestWhenInUseAuthorization()
//                        
//                    case .always:
//                        locationManager.requestAlwaysAuthorization()
//                    }
//                    
//                    locationManager.startUpdatingLocation()
//                    
                } else {
                    failureAction()
                }
                
            default:
                failureAction()
            }
        }
        
        proposeToAccessLocation(usage, agreed: successAction, rejected: failureAction)
    }
}

private func proposeToAccessPhotos(agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    PHPhotoLibrary.requestAuthorization { status in
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                successAction()
            default:
                failureAction()
            }
        }
    }
}

private func proposeToAccessCamera(agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
        DispatchQueue.main.async {
            granted ? successAction() : failureAction()
        }
    }


func proposeToAccessMicrophone(agreed successAction: @escaping ProposerAction, rejected failureAction: @escaping ProposerAction) {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
        DispatchQueue.main.async {
            granted ? successAction() : failureAction()
        }
    }
}

//private func proposeToAccessContacts(agreed successAction: ProposerAction, rejected failureAction: ProposerAction) {
//
//    switch CNContactStore.authorizationStatus(for: .contacts) {
//        
//    case .authorized:
//        successAction()
//        
//    case .notDetermined:
//        CNContactStore().requestAccess(for: .contacts) { granted, error in
//            DispatchQueue.main.async {
//                if granted {
//                    successAction()
//                } else {
//                    failureAction()
//                }
//            }
//        }
//        
//    default:
//        failureAction()
//    }
//
//}

}
