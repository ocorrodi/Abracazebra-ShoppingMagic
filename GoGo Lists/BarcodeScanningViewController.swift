//
//  BarcodeScanningViewController.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/18/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit
import AVFoundation

protocol BarcodeDelegate {
    func barcodeRead(barcode: String)
}

class BarcodeScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var delegate: BarcodeDelegate?
    
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    
    var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    
    var output = AVCaptureMetadataOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureSession = AVCaptureSession()
    
    var code: String? = ""
    
    var listTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        self.setupCamera()

        // Do any additional setup after loading the view.
    }
    
    private func setupCamera() {
        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if self.captureSession.canAddInput(input) {
            self.captureSession.addInput(input)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let videoPreviewLayer = self.previewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer.frame = self.view.bounds
            view.layer.addSublayer(videoPreviewLayer)
            
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeEAN8Code]
        }
        else {
            print("Could not scan barcode")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning == true {
            captureSession.stopRunning();
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        for metadata in metadataObjects {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            code = readableObject.stringValue
            self.delegate?.barcodeRead(barcode: code!)
            print(code!)
            performSegue(withIdentifier: "doneScanning", sender: self)
            // self.dismiss(animated: true, completion: nil)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneScanning" {
            let destinationVC = segue.destination as! ItemViewController
            destinationVC.barcodeScanned = code!
            destinationVC.listTitle = listTitle
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
