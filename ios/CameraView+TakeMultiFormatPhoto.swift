//
//  CameraView+TakeMultiFormatPhoto.swift
//  mrousavy
//
//  Created by Marc Rousavy on 16.12.20.
//  Copyright © 2020 mrousavy. All rights reserved.
//

import AVFoundation

// MARK: - TakePhotoOptions

extension CameraView {
  func takeMultiFormatPhoto(options: NSDictionary, promise: Promise) {
    guard #available(iOS 14.3, *) else { return }
    guard let photoOutput = self.photoOutput else {
      if self.photo?.boolValue == true {
        promise.reject(error: .session(.cameraNotReady))
        return
      } else {
        promise.reject(error: .capture(.photoNotEnabled))
        return
      }
    }
    jpegCapture(promise, photoOutput)
    hvecCapture(promise, photoOutput)
    uncompressedCapture(promise, photoOutput)
    bayerRAWCapture(promise, photoOutput)
    appleProRAWCapture(promise, photoOutput)
  }
  
  func jpegCapture(_ promise: Promise, _ photoOutput: AVCapturePhotoOutput) {
    guard #available(iOS 14.3, *) else { return }
    print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
          "jpegCapture")
    videoOutputQueue.async {
      let jpegFormat = [AVVideoCodecKey: AVVideoCodecType.jpeg]
      let jpegPhotoSettings = AVCapturePhotoSettings(format: jpegFormat)
      jpegPhotoSettings.isHighResolutionPhotoEnabled = true
      jpegPhotoSettings.photoQualityPrioritization = .quality
      photoOutput.capturePhoto(
        with: jpegPhotoSettings,
        delegate: MultiFormatPhotoCaptureDelegate(
          promise: promise,
          format: .jpeg
        )
      )
      print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
            "jpegCapture done")
    }
  }
  
  func hvecCapture(_ promise: Promise, _ photoOutput: AVCapturePhotoOutput) {
    guard #available(iOS 14.3, *) else { return }
    print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
          "hvecCapture")
    videoOutputQueue.async {
      let hevcFormat = [AVVideoCodecKey: AVVideoCodecType.hevc]
      let hevcPhotoSettings = AVCapturePhotoSettings(format: hevcFormat)
      hevcPhotoSettings.isHighResolutionPhotoEnabled = true
      hevcPhotoSettings.photoQualityPrioritization = .quality
      photoOutput.capturePhoto(
        with: hevcPhotoSettings,
        delegate: MultiFormatPhotoCaptureDelegate(
          promise: promise,
          format: .hvec
        )
      )
      print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
            "hvecCapture done")
    }
  }
  
  func uncompressedCapture(_ promise: Promise, _ photoOutput: AVCapturePhotoOutput) {
    guard #available(iOS 14.3, *) else { return }
    print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
          "uncompressedCapture")
    videoOutputQueue.async {
      let uncompressedPixelFormatType = kCVPixelFormatType_32BGRA
      if photoOutput.availablePhotoPixelFormatTypes.contains(uncompressedPixelFormatType) {
        let uncompressedFormat: [String: Any] = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
        let uncompressedPhotoSettings = AVCapturePhotoSettings(format: uncompressedFormat)
        uncompressedPhotoSettings.isHighResolutionPhotoEnabled = true
        uncompressedPhotoSettings.photoQualityPrioritization = .quality
        photoOutput.capturePhoto(
          with: uncompressedPhotoSettings,
          delegate: MultiFormatPhotoCaptureDelegate(
            promise: promise,
            format: .uncompressedTIFF
          )
        )
        print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
              "uncompressedCapture done")
      } else {
        print("🔴 \((#file as NSString).lastPathComponent):\(#line) " +
              "kCVPixelFormatType_32BGRA format not available")
      }
    }
  }
  
  func bayerRAWCapture(_ promise: Promise, _ photoOutput: AVCapturePhotoOutput) {
    guard #available(iOS 14.3, *) else { return }
    print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
          "bayerRAWCapture")
    videoOutputQueue.async {
      if let bayerRAWPixelFormat = photoOutput.availableRawPhotoPixelFormatTypes.first(
            where: { AVCapturePhotoOutput.isBayerRAWPixelFormat($0)} ) {
        let bayerRAWPhotoSettings = AVCapturePhotoSettings(rawPixelFormatType: bayerRAWPixelFormat)
        bayerRAWPhotoSettings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(
          with: bayerRAWPhotoSettings,
          delegate: MultiFormatPhotoCaptureDelegate(
            promise: promise,
            format: .bayerRAW
          )
        )
        print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
              "bayerRAWCapture done")
      } else {
        print("🔴 \((#file as NSString).lastPathComponent):\(#line) " +
              "Bayer RAW pixel format not available")
      }
    }
  }
  
  func appleProRAWCapture(_ promise: Promise, _ photoOutput: AVCapturePhotoOutput) {
    guard #available(iOS 14.3, *) else { return }
    print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
          "appleProRAWCapture")
    videoOutputQueue.async {
      if let appleProRAWPixelFormat = photoOutput.availableRawPhotoPixelFormatTypes.first(
            where: { AVCapturePhotoOutput.isAppleProRAWPixelFormat($0)} ) {
        let appleProRAWPhotoSettings = AVCapturePhotoSettings(rawPixelFormatType: appleProRAWPixelFormat)
        appleProRAWPhotoSettings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(
          with: appleProRAWPhotoSettings,
          delegate: MultiFormatPhotoCaptureDelegate(
            promise: promise,
            format: .appleProRAW
          )
        )
        print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
              "appleProRAWCapture done")
      } else {
        print("🔴 \((#file as NSString).lastPathComponent):\(#line) " +
              "Apple ProRAW pixel format not available")
      }
    }
  }
}
