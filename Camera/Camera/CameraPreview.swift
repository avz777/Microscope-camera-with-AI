//
//  CameraPreview.swift
//  Camera
//
//  Created by Andrey Zhuravlev on 13/4/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: NSViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        previewLayer.frame = view.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer = CALayer()
        view.layer?.addSublayer(previewLayer)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
