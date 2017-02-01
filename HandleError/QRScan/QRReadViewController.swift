//
//  QRReadViewController.swift
//  HandleError
//
//  Created by wc on 28/12/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                          AVMetadataObjectTypeCode39Code,
                          AVMetadataObjectTypeCode39Mod43Code,
                          AVMetadataObjectTypeCode93Code,
                          AVMetadataObjectTypeCode128Code,
                          AVMetadataObjectTypeEAN8Code,
                          AVMetadataObjectTypeEAN13Code,
                          AVMetadataObjectTypeAztecCode,
                          AVMetadataObjectTypePDF417Code,
                          AVMetadataObjectTypeQRCode]

/// 扫描二维码错误
///
/// - denied: 权限被拒绝
/// - unavailable: 相机不可用
enum QRScanError: Swift.Error {
    case denied
    case unavailable(Swift.Error)
    case machineUnreadableCodeObject
}

class QRReadViewController: UIViewController {
    
    @IBOutlet private weak var cancelBarButtonItem: UIBarButtonItem!

    private let captureSession = AVCaptureSession()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable
            .just(AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo))
            .flatMap { authorizationStatus -> Observable<()> in
                switch authorizationStatus {
                case .authorized:
                    return Observable.just()
                case .notDetermined:
                    return AVCaptureDevice.rx.requestAccess(forMediaType: AVMediaTypeVideo)
                        .flatMap { result -> Observable<()> in
                            if result {
                                return Observable.just(())
                            } else {
                                return Observable.error(QRScanError.denied)
                            }
                        }
                        .asObservable()
                case .denied, .restricted:
                    return Observable.error(QRScanError.denied)
                }
            }
            .flatMap { [unowned self] () -> Observable<(metadataObjects: [Any], connection: AVCaptureConnection)> in
                let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
                let input = try AVCaptureDeviceInput(device: captureDevice)

                let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)!
                videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoPreviewLayer.frame = self.view.layer.bounds
                self.view.layer.addSublayer(videoPreviewLayer)

                self.captureSession.addInput(input)
                let captureMetadataOutput = AVCaptureMetadataOutput()
                self.captureSession.addOutput(captureMetadataOutput)
                captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
                self.captureSession.startRunning()

                return captureMetadataOutput.rx.didOutputMetadataObjects

            }
            .flatMap { (metadataObjects: [Any], connection: AVCaptureConnection) -> Observable<String> in
                guard let metadataObj = metadataObjects.flatMap({ $0 as? AVMetadataMachineReadableCodeObject }).first else {
                    return Observable.empty()
                }
                guard let value = metadataObj.stringValue else {
                    return Observable.error(QRScanError.machineUnreadableCodeObject)
                }
                return Observable.just(value)
            }
            .debug()
            .subscribe()
            .disposed(by: disposeBag)

    }

}
