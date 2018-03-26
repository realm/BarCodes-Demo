//
//  ScannerViewController.swift
//  RealmBarcode
//
//  Created by David HM Spector on 3/23/18.
//  Copyright © 2018 Realm. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
import RealmSwift

let PlaceholderImageTag = 162

enum ScanButtonState : String {
    case scan = "Scan"
    case accept = "Accept"
}


class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // Realm bits
    
    var realm: Realm?
    
    // AVFoundation items used to enable bar-/qr-code scanning
    var captureDevice:AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var buttonState: ScanButtonState = .scan
    
    let codeFrame : UIView = {
        let codeFrame = UIView()
        codeFrame.layer.borderColor = UIColor.green.cgColor
        codeFrame.layer.borderWidth = 2
        codeFrame.frame = CGRect.zero
        codeFrame.translatesAutoresizingMaskIntoConstraints = false
        return codeFrame
    }()
    
    
    // UI Controls/Elements
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var scannedIDLabel: UILabel!
    @IBOutlet weak var scanActionButton: UIButton!
    @IBOutlet weak var cencelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Scanner"
        view.backgroundColor = .white
        
        scannedIDLabel.text = NSLocalizedString("No Data", comment: "initial value")
        
        scannerView.backgroundColor = .lightGray
        scannerView.layer.borderColor = UIColor.blue.cgColor
        scannerView.layer.borderWidth = 0.75
        scannerView.contentMode = .scaleAspectFit
        
        scanActionButton.setTitle(NSLocalizedString(buttonState.rawValue, comment: "scan, or accept"), for: .normal)
        
        captureDevice = AVCaptureDevice.default(for: .video)
        if let captureDevice = captureDevice {
           self.captureSession =  setupScanner(captureDevice)
        } //  if/let
    } // viewDidLoad
    
    
    override func viewWillAppear(_ animated: Bool) {
        resetScannerView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Utilties
    fileprivate func setupScanner(_ captureDevice: AVCaptureDevice) -> AVCaptureSession? {
        var captureSession: AVCaptureSession?
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            captureMetadataOutput.metadataObjectTypes = [.code128, .qr, .ean13,  .ean8, .code39]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = scannerView.layer.bounds
            scannerView.layer.addSublayer(videoPreviewLayer!)
        } catch {
            print("Error Device Input")
        }
        return captureSession
    }
    
    
    fileprivate func startScanning() {
        scanActionButton.isEnabled = false
        captureSession?.startRunning()
    }
    
    fileprivate func resetScannerView() {
        captureSession?.stopRunning()
        buttonState = .scan
        scanActionButton.setTitle(NSLocalizedString(buttonState.rawValue, comment: "scan, or accept"), for: .normal)
    }
    
    
    
    @IBAction func scanActionButtonTapped(_ sender: Any) {
        switch buttonState {
        case .scan:
            self.startScanning()
        case .accept:
            print("need to process the accepted scan")
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if self.buttonState == .scan {
            self.resetScannerView()
            scanActionButton.isEnabled = true

        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // AVFoundation / Barcode utils
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            codeFrame.frame = CGRect.zero
            scannedIDLabel.text = NSLocalizedString("No Data", comment: "no data")
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        guard let stringCodeValue = metadataObject.stringValue else { return }

        codeFrame.bounds = scannerView.bounds
        
        view.addSubview(codeFrame)
        
        guard let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) else { return }
        
        let systemSoundId: SystemSoundID = 1016
        AudioServicesAddSystemSoundCompletion(systemSoundId, nil, nil, { (customSoundId, _) -> Void in
            AudioServicesDisposeSystemSoundID(customSoundId)
        }, nil)
        
        AudioServicesPlaySystemSound(systemSoundId)
        scanDidSucceed(result: stringCodeValue)
    } // metadataOutput(output:metadataObjects)
    
    
    func scanDidSucceed(result: String) {
        scannedIDLabel.text = result
        if entryExists(id: result) {
            // just take the user to the record
            performSegue(withIdentifier: "showDetailSegue", sender: nil)
        } else {
            // set the action button to "accept"
            buttonState = .accept
            scanActionButton.isEnabled = true
            scanActionButton.setTitle(NSLocalizedString(buttonState.rawValue, comment: "scan, or accept"), for: .normal)
        }
        

    } // scanDidSucceed
    
    func entryExists(id:String) -> Bool {
        guard realm != nil else {
            return false
        }
        return realm?.object(ofType: Item.self, forPrimaryKey: id ) != nil
    } //entryExists

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "" {
            if let vc = segue.destination as? ItemDetailViewController {
                vc.realm = realm
            }
        }
     // Get the new view controller using segue.destinationViewController.
        
        
     // Pass the selected object to the new view controller.
     }

}
