//
//  ViewController.swift
//  QRScan
//
//  Created by Johnson Zhou on 9/15/15.
//  Copyright © 2015 Johnson Zhou. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var transText:String?
    
    @IBOutlet weak var corner4: UIImageView!
    @IBOutlet weak var corner3: UIImageView!
    @IBOutlet weak var corner2: UIImageView!
    @IBOutlet weak var corner1: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.clipsToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.blackColor().CGColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.5
        self.navigationController?.navigationBar.layer.shadowOffset = CGSizeMake(0, 5)
        
        corner1.clipsToBounds = false
        corner1.layer.shadowColor = UIColor.blackColor().CGColor
        corner1.layer.shadowOpacity = 0.3
        corner1.layer.shadowOffset = CGSizeMake(3, 3)
        
        corner2.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2));
        corner2.clipsToBounds = false
        corner2.layer.shadowColor = UIColor.blackColor().CGColor
        corner2.layer.shadowOpacity = 0.3
        corner2.layer.shadowOffset = CGSizeMake(3, 3)
        
        corner3.transform = CGAffineTransformMakeRotation(CGFloat(3 * M_PI_2));
        corner3.clipsToBounds = false
        corner3.layer.shadowColor = UIColor.blackColor().CGColor
        corner3.layer.shadowOpacity = 0.3
        corner3.layer.shadowOffset = CGSizeMake(3, 3)
        
        corner4.transform = CGAffineTransformMakeRotation(CGFloat(2 * M_PI_2));
        corner4.clipsToBounds = false
        corner4.layer.shadowColor = UIColor.blackColor().CGColor
        corner4.layer.shadowOpacity = 0.3
        corner4.layer.shadowOffset = CGSizeMake(3, 3)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "restart:",name:"restartQRScanner", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:",name:"UIDeviceOrientationDidChangeNotification", object: nil)
        
        self.restart(nil)

        
    }
    
    func orientationChanged(notification: NSNotification?){
        videoPreviewLayer?.frame = view.layer.bounds
        let connection = videoPreviewLayer?.connection
        switch UIApplication.sharedApplication().statusBarOrientation {
        case UIInterfaceOrientation.LandscapeLeft :
            connection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft;
        case UIInterfaceOrientation.LandscapeRight:
            connection?.videoOrientation  = AVCaptureVideoOrientation.LandscapeRight;
        case UIInterfaceOrientation.PortraitUpsideDown:
            connection?.videoOrientation  = AVCaptureVideoOrientation.PortraitUpsideDown;
        default:
            connection?.videoOrientation = AVCaptureVideoOrientation.Portrait;
        }
    }
    
    @IBAction func pressFlash(sender: AnyObject) {
        toggleFlash()
    }
    
    func toggleFlash() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
               try device.lockForConfiguration()
            } catch {
                print("Flashlight error")
                return
            }
            if (device.torchMode == AVCaptureTorchMode.On) {
                device.torchMode = AVCaptureTorchMode.Off
            } else {
                do {
                    try device.setTorchModeOnWithLevel(1.0)
                } catch {
                    print("Flashlight error")
                    return
                }
            }
            device.unlockForConfiguration()
        }
    }
    
    
    func restart(notification: NSNotification?){
        //load data here
        captureSession?.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
        qrCodeFrameView?.removeFromSuperview()
        var input:AVCaptureDeviceInput
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as AVCaptureInput)
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        captureSession?.startRunning()
        
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        view.bringSubviewToFront(corner1)
        view.bringSubviewToFront(corner2)
        view.bringSubviewToFront(corner3)
        view.bringSubviewToFront(corner4)

    }
    
    func stringToAction(data: String) {
        qrCodeFrameView?.removeFromSuperview()
        captureSession?.stopRunning()
        let dataString = data.lowercaseString
        let url = NSURL(string: dataString)
        if url != nil {
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
                return
            }
        }

        transText = data
        performSegueWithIdentifier("showText", sender: self)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.removeFromSuperview()
            transText = "No QRCode Found"
            captureSession?.stopRunning()
            print("stopped by error")
            performSegueWithIdentifier("showText", sender: self)
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                stringToAction(metadataObj.stringValue)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showText" {
            let destination = segue.destinationViewController as! TextViewController
            destination.thisText = transText
        }
    }


}

