//
//  ReaderVC.swift
//  QRReader
//
//  Created by Esmeralda Angeles on 1/3/19.
//  Copyright © 2019 SmeAngeles. All rights reserved.
//

import UIKit
import AVFoundation


class ReaderVC: UIViewController {
    
    var captureSession:AVCaptureSession!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    var qrCodeFrameView:UIView?
    
    @IBOutlet weak var lblMessage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
            
        } catch {
            print(error)
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = view.layer.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
        
        view.bringSubviewToFront(lblMessage)
        
        qrCodeFrameView = UIView()
        
        qrCodeFrameView!.layer.borderColor = UIColor.blue.cgColor
        qrCodeFrameView!.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        
        view.bringSubviewToFront(qrCodeFrameView!)
        
    }
    
}


extension ReaderVC:  AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            captureSession.stopRunning()
            
            if readableObject.type == AVMetadataObject.ObjectType.qr{
                
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: readableObject)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                lblMessage.text = "QR detected"
                
                let alert = UIAlertController(title: "QR Code", message: readableObject.stringValue, preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Retake", style: UIAlertAction.Style.default, handler: { (nil) in
                    self.qrCodeFrameView?.frame = CGRect.zero
                    self.lblMessage.text = "Searching QR ..."
                    self.captureSession.startRunning()
                    
                }))
                alert.addAction(UIAlertAction(title: "copy", style: UIAlertAction.Style.default, handler: { (nil) in
                    UIPasteboard.general.string =  readableObject.stringValue
                }))
                
                present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
}
