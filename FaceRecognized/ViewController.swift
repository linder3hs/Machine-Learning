//
//  ViewController.swift
//  FaceRecognized
//
//  Created by Linder on 3/29/18.
//  Copyright © 2018 Linder. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var objectrRandom: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        objectrRandom.text = "hola jg"
        //here is where we start up the camera
    
        let captureSession =  AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input  = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       // print("Carea was bable to capture a frame: ", Date())
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel ( for : Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) {
            ( finishedReq, err) in
            //print(finishedReq.results)
            
            guard let results = finishedReq.results as?
                [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async {
                self.objectrRandom.text = String(firstObservation.identifier)
            }
        }
       try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
}

