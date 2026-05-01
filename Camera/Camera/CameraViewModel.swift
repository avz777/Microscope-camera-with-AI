//
//  CameraViewModel.swift
//  Camera
//
//  Created by Andrey Zhuravlev on 13/4/25.
//
import Foundation
import AVFoundation
import AppKit
import SwiftUI
import Cocoa
import Vision


class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    private let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    @Published var availableDevices: [AVCaptureDevice] = []
    @Published var selectedDevice: AVCaptureDevice?
    @Published var capturedImage: NSImage?
    
    @Published var isSessionRunning = false
    
    var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        fetchAvailableDevices()
    }

    func fetchAvailableDevices() {
        availableDevices = AVCaptureDevice.devices(for: .video)

        selectedDevice = availableDevices.first
    }

    func startSession() {
        guard let device = selectedDevice else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.beginConfiguration()
            
            // Clean up previous inputs/outputs
            if let oldInput = currentInput {
                session.removeInput(oldInput)
            }
            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }
            
            // Set input/output
            if session.canAddInput(input) {
                session.addInput(input)
                currentInput = input
            }
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }

            session.sessionPreset = .photo
            session.commitConfiguration()

            // Setup preview layer
            if previewLayer == nil {
                let layer = AVCaptureVideoPreviewLayer(session: session)
                layer.videoGravity = .resizeAspectFill
                previewLayer = layer
            } else {
                previewLayer?.session = session
            }

            session.startRunning()
            isSessionRunning = true
        } catch {
            print("Failed to start session: \(error)")
        }
    }

    func stopSession() {
        if session.isRunning {
            session.stopRunning()
            isSessionRunning = false
        }
    }

    func switchCamera() {
        stopSession()
        startSession()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
 
    

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = NSImage(data: data) else {
            print("Failed to capture image.")
            return
        }

        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }

    func modelAI() -> String {
        guard let image = capturedImage else { return "--------" }
        var res = ""
        do {
            var model = try VNCoreMLModel(for: LmsClasMulti2().model)
            
            
            if let handler = createVNImageRequestHandler(from: image) {
                // Use handler with a VNRequest
                var request = VNCoreMLRequest(model: model, completionHandler: myResultsMethod)
                try handler.perform([request])
                func myResultsMethod(request: VNRequest, error: Error?) {
                    guard var results = request.results as? [VNClassificationObservation]
                    else { fatalError("Fatal error, sorry") }
                    
                    res=results[0].identifier + " (" + String(Int(100.0*results[0].confidence)) + "%)"
                    
                }
                
            }
            
        } catch {
            print(error)
        }
        return(res)
    }
    
    // Bioclast counts
    
    func bioclast() -> String{
        guard let image1 = capturedImage else { return "--------" }
        var res = ""
        var cgImage: CGImage!
        var w = 0
        var h = 0
       
            cgImage = image1.cgImage(forProposedRect: nil, context: nil, hints: nil)
            w = cgImage!.width
            h = cgImage!.height
   

        do {
            
            let model = try VNCoreMLModel(for: Bioclasts3603().model)
            
            var x = 0 as Int
            var y = 0 as Int
            
            var crin = 0.0
            var brach = 0.0
            var foram = 0.0
            var none = 0.0
            var sss = 0.0
       
            var xn = 0 as Int
            var yn = 0 as Int
            xn = Int(w / 90)
            yn = Int(h / 90)
            for j in 0..<yn - 4 {
                for i in 0..<xn - 4 {
                    x = 90 * i
                    y = 90 * j
                    let origin = CGPoint(x: x, y: y)
                            let size = CGSize(width: 360, height: 360)
                    let tileCgImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
                    let handler = VNImageRequestHandler(cgImage: tileCgImage)
                    
                        var request = VNCoreMLRequest(model: model, completionHandler: myResultsMethod)
                        try handler.perform([request])
                        func myResultsMethod(request: VNRequest, error: Error?) {
                            guard var results = request.results as? [VNClassificationObservation]
                            else { fatalError("Fatal error, sorry") }
                            if results[0].identifier == "crinoids" {
                                crin = crin + Double(results[0].confidence)
                            }
                            
                            if results[0].identifier == "forams" {
                                foram = foram + Double(results[0].confidence)
                            }
                            if results[0].identifier == "none" {
                                none = none + Double(results[0].confidence)
                            }
                            
                            
                            
                            
                        }
                    
                }
            }
            sss = none + crin + foram
            crin = 100.0 * crin / sss
            foram = 100.0 * foram / sss
            res = "Crinoids: " + String(Int(crin)) + " Forams:" + String (Int(foram))
                    
                } catch {
                    print(error)
                }
        
      return res
    }

    
// Recrystallisation diagnostics
    func modelAI2() -> String {
        guard let image = capturedImage else { return "--------" }
        var res = ""
        do {
            var model = try VNCoreMLModel(for: CarbonateRecrystallisation().model)
            
            
            if let handler = createVNImageRequestHandler(from: image) {
                // Use handler with a VNRequest
                var request = VNCoreMLRequest(model: model, completionHandler: myResultsMethod)
                try handler.perform([request])
                func myResultsMethod(request: VNRequest, error: Error?) {
                    guard var results = request.results as? [VNClassificationObservation]
                    else { fatalError("Fatal error, sorry") }
                    if results[0].identifier == "fresh" {
                        res="fresh (" + String(Int(100.0*results[0].confidence)) + "%)"
                    }
                    if results[0].identifier == "recryst" {
                        res="recrystallised (" + String(Int(100.0*results[0].confidence)) + "%)"
                    }
                    
                }
                
            }
            
        } catch {
            print(error)
        }
        return(res)
    }
    

    func createVNImageRequestHandler(from nsImage: NSImage) -> VNImageRequestHandler? {
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else {
            print("Failed to convert NSImage to CGImage")
            return nil
        }

        // Create a VNImageRequestHandler using the CGImage
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        return handler
    }

    func savelog(txtlog: String) {
        let txt = txtlog
        let panel = NSSavePanel()
        
        panel.allowedContentTypes = [UTType.text]
        
        panel.nameFieldStringValue = "info.txt"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    try txt.write(to: url, atomically: true, encoding: String.Encoding.utf8)
                    
                } catch {
                    print("Failed to save text file: \(error)")
                }
                
            }
            
        }
    }

    func savePhoto() {
        guard let image = capturedImage else { return }

        let panel = NSSavePanel()
    //    panel.allowedFileTypes = ["png"]
        panel.allowedContentTypes = [UTType.png]
        
        panel.nameFieldStringValue = "captured.png"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let tiff = image.tiffRepresentation,
                   let bitmap = NSBitmapImageRep(data: tiff),
                   let jpegData = bitmap.representation(using: .png, properties: [:]) {
                    do {
                        try jpegData.write(to: url)
                        print("Image saved to: \(url.path)")
                    } catch {
                        print("Failed to save image: \(error)")
                    }
                }
            }
        }
    }
}
