//
//  ContentView.swift
//  Camera
//
//  Created by Andrey Zhuravlev on 13/4/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraModel = CameraViewModel()
    @State private var txt : String = "--------"
    @State private var txt1 : String = "--------"
    @State private var txt2 : String = "--------"
    @State private var txtlog : String = "Limestone type,Recrystallisation,Bioclasts \n"
    var body: some View {
        VStack {
            Text("Limestone classification v.4.1")
                .font(.title)
            if let previewLayer = cameraModel.previewLayer {
                CameraPreview(previewLayer: previewLayer)
                    .frame(minWidth: 640, minHeight: 480)
                    .cornerRadius(12)
                    .padding()
            } else {
                Text("Camera preview not available. Connect a camera.")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 20) {
                Picker("Camera", selection: $cameraModel.selectedDevice) {
                    ForEach(cameraModel.availableDevices, id: \.uniqueID) { device in
                        Text(device.localizedName).tag(device as AVCaptureDevice?)
                    }
                }
                .frame(width: 200)
                .onChange(of: cameraModel.selectedDevice) { _ in
                    cameraModel.switchCamera()
                }

                Button("Capture image") {
                    cameraModel.capturePhoto()
                 txt="--------"
                txt1="--------"
                txt2="--------"
                }
                .disabled(!cameraModel.isSessionRunning)
                
                Button("Save") {
                    cameraModel.savePhoto()
                }
                .disabled(cameraModel.capturedImage == nil)
                
                Button("Analyse captured image") {
                    txt=cameraModel.modelAI()
                    txt1=cameraModel.modelAI2()
                    txt2=cameraModel.bioclast()
                    txtlog = txtlog + txt + "," + txt1 + "," + txt2 + "\n"
                }
                .disabled(cameraModel.capturedImage == nil)
                
                Button("Save log") {
                    cameraModel.savelog(txtlog: txtlog)
                }
                .disabled(cameraModel.capturedImage == nil)
                
                VStack {
                    Text(txt)
                        .font(.title)
                    Text(txt1)
                        .font(.title)
                    Text(txt2)
                        .font(.footnote)
                    
                }
            }
            .padding()
        }
        .onAppear {
            cameraModel.startSession()
        }
        .onDisappear {
            cameraModel.stopSession()
        }
    }
}
