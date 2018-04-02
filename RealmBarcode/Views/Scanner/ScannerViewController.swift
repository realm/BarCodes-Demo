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

let kMinItemNameLength = 5


class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // Realm bits
    
    var realm: Realm?
    
    // AVFoundation items used to enable bar-/qr-code scanning
    var captureDevice:AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    // UI Controls/Elements
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var cencelButton: UIButton!
    
    // Misc
    // the "add" item in our new item dialog - this allows us to enable/disable
    // inside the processing of the alertview controller
    weak var AddAlertAction: UIAlertAction?
    
    var foundID = ""    // the most current bar/qr code we've scanned
    
    // the green frame we display around the barcode windown on a successful scan
    let codeFrame : UIView = {
        let codeFrame = UIView()
        codeFrame.layer.borderColor = UIColor.green.cgColor
        codeFrame.layer.borderWidth = 2
        codeFrame.frame = CGRect.zero
        codeFrame.translatesAutoresizingMaskIntoConstraints = false
        return codeFrame
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Scanner", comment:"scanner")
        view.backgroundColor = .white
        
        scannerView.backgroundColor = .clear
        scannerView.layer.borderColor = UIColor.gray.cgColor
        scannerView.layer.borderWidth = 0.75

        captureDevice = AVCaptureDevice.default(for: .video)
        if let captureDevice = captureDevice {
            self.captureSession =  setupScanner(captureDevice)
        }
    } // viewDidLoad
    
    
    override func viewWillAppear(_ animated: Bool) {
        stopScanning()
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopScanning()
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
            videoPreviewLayer?.frame = self.scannerView.layer.bounds
            videoPreviewLayer?.contentsCenter = self.scannerView.layer.contentsCenter
            videoPreviewLayer?.videoGravity = .resizeAspectFill

            scannerView.layer.addSublayer(videoPreviewLayer!)
        } catch {
            print("Error Device Input")
        }
        return captureSession
    }
    
    
    fileprivate func startScanning() {
        captureSession?.startRunning()
    }
    
    fileprivate func stopScanning() {
        captureSession?.stopRunning()
    }
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // AVFoundation / Barcode utils
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            codeFrame.frame = CGRect.zero
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        guard let stringCodeValue = metadataObject.stringValue else { return }
        
        //        codeFrame.bounds = scannerView.bounds
        codeFrame.bounds = videoPreviewLayer!.bounds
        view.addSubview(codeFrame)
        
        guard let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) else { return }
        
        scanDidSucceed(result: stringCodeValue)
    } // metadataOutput(output:metadataObjects)
    
    
    func scanDidSucceed(result: String) {
        if entryExists(id: result) {
            foundID = result
            performSegue(withIdentifier: "showDetailSegue", sender: nil)
        } else {
            // show the found ID dialog; ask user if they wish to create a new record
            self.showNewBarCodeAlert(withBarCode: result)
        }
    } // scanDidSucceed
    
    func entryExists(id:String) -> Bool {
        guard realm != nil else {
            return false
        }
        return realm?.object(ofType: Item.self, forPrimaryKey: id ) != nil
    } //entryExists
    
    
    
    func showNewBarCodeAlert(withBarCode barCode: String) {
        let alertController = UIAlertController(title: NSLocalizedString("New Barcode Detected", comment: "New Barcode Detected"),
                                                message: NSLocalizedString("Add ID \"\(barCode)\"?", comment: "Add \(barCode)?"),
                                                preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField) in
            textField.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Name for this item..."
            textField.clearButtonMode = .whileEditing
        }
        
        
        let addAction = UIAlertAction(title: "Add", style:
            .default, handler: { (_) -> Void in
                let itemName = alertController.textFields!.first!.text ?? "New Item Name"
                self.addnewItemWithID(barCode, productDescription: itemName)
                
        })
        
        self.AddAlertAction = addAction
        self.AddAlertAction?.isEnabled = false
        alertController.addAction(self.AddAlertAction!)
        
        alertController.addAction(UIAlertAction(title: "Ignore", style: .cancel, handler:nil))
        
        present(alertController, animated: true, completion: nil)
    } // presentNewBarcode
    
    
    @objc func textDidChange(_ notification: NSNotification) {
        let textField = notification.object as! UITextField
        AddAlertAction!.isEnabled = (textField.text?.count)! >= kMinItemNameLength
    } // textChanged
    
    
    func addnewItemWithID(_ barCode: String, productDescription: String){
        guard self.realm != nil else { return }
        
        try! realm?.write {
            let tmpDate = Date()
            let newItem = Item()
            newItem.id = barCode
            newItem.productDescription = productDescription
            newItem.creationDate = tmpDate
            newItem.lastUpdated = tmpDate
            realm?.add(newItem, update: true)
        }
    } // addnewItemWithID
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scannerToDetailSegue" {
            if let vc = segue.destination as? ItemDetailViewController {
                vc.realm = realm
                vc.itemId = self.foundID
            }
        }
    } // of prepareForSegue
    
} // of ScannerViewController
