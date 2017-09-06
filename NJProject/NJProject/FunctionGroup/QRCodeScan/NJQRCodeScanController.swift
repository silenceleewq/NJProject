//
//  NJQRCodeScanController.swift
//  NJProject
//
//  Created by slience on 2017/6/20.
//  Copyright © 2017年 Ninja. All rights reserved.
//

import UIKit
import AVFoundation

class NJQRCodeScanController: UIViewController {
    
    lazy var device: AVCaptureDevice = {
        let d = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        return d!
    }()
    
    lazy var input: AVCaptureDeviceInput? = {
        
        let input = try? AVCaptureDeviceInput.init(device: self.device)
        
        return input
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "扫描二维码"
        
        checkCameraAvailability { (auth) in
            if !auth {
                //如果不可用,那么提示用户去设置打开相机权限.
                let alertC = UIAlertController(title: "提示", message: "没有访问相机权限,\n请到设置中打开权限", preferredStyle: .alert)
                let _ = UIAlertAction(title: "立即开启", style: .default, handler: { (action) in

                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: ["":""], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                    }

                })
                
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertC.addAction(cancel)
                self.present(alertC, animated: true, completion: nil)
            }
        }
        
        
        
    }
    
}

extension NJQRCodeScanController {
    func checkCameraAvailability(result:@escaping (Bool)->Void) -> Void {
        var status = false
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .authorized {
            status = true
        } else if authStatus == .denied {
            status = false
        } else if authStatus == .restricted {
            status = false
        } else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                result(granted)
                return
            })
        }
        result(status)
    }
    
    func initUI(previewFrame: CGRect) {
        
    }
}

























