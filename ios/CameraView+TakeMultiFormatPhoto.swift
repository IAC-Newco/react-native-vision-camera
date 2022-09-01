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
    jpegCapture(promise)
    hvecCapture(promise)
    uncompressedCapture(promise)
    bayerRAWCapture(promise)
    appleProRAWCapture(promise)
  }
  
  func jpegCapture(_ promise: Promise) {
    guard #available(iOS 14.3, *) else { return }
    videoOutputQueue.async {
      guard let photoOutput = self.photoOutput else {
        if self.photo?.boolValue == true {
          promise.reject(error: .session(.cameraNotReady))
          return
        } else {
          promise.reject(error: .capture(.photoNotEnabled))
          return
        }
      }
      // JPEG
      let jpegPhotoSettings = AVCapturePhotoSettings(format: nil)
      jpegPhotoSettings.isHighResolutionPhotoEnabled = true
      jpegPhotoSettings.photoQualityPrioritization = .quality
      photoOutput.capturePhoto(
        with: jpegPhotoSettings,
        delegate: MultiFormatPhotoCaptureDelegate(
          promise: promise,
          format: .jpeg
        )
      )
    }
  }
  
  func hvecCapture(_ promise: Promise) {
    guard #available(iOS 14.3, *) else { return }
    videoOutputQueue.async {
      guard let photoOutput = self.photoOutput else {
        if self.photo?.boolValue == true {
          promise.reject(error: .session(.cameraNotReady))
          return
        } else {
          promise.reject(error: .capture(.photoNotEnabled))
          return
        }
      }
      // HEIC/HEVC
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
    }
  }
  
  func uncompressedCapture(_ promise: Promise) {
    guard #available(iOS 14.3, *) else { return }
    videoOutputQueue.async {
      guard let photoOutput = self.photoOutput else {
        if self.photo?.boolValue == true {
          promise.reject(error: .session(.cameraNotReady))
          return
        } else {
          promise.reject(error: .capture(.photoNotEnabled))
          return
        }
      }
      // Uncompressed
      let uncompressedPixelFormatType = kCVPixelFormatType_32BGRA
      for availablePhotoPixelFormatType in photoOutput.availablePhotoPixelFormatTypes {
        print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
              "availablePhotoPixelFormatType: \(availablePhotoPixelFormatType)")
      }
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
      } else {
        print("🔴 \((#file as NSString).lastPathComponent):\(#line) " +
              "kCVPixelFormatType_32BGRA format not available")
      }
    }
  }
  
  func bayerRAWCapture(_ promise: Promise) {
    guard #available(iOS 14.3, *) else { return }
    videoOutputQueue.async {
      guard let photoOutput = self.photoOutput else {
        if self.photo?.boolValue == true {
          promise.reject(error: .session(.cameraNotReady))
          return
        } else {
          promise.reject(error: .capture(.photoNotEnabled))
          return
        }
      }
      
      // RAW (Bayer)
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
      } else {
        print("🔴 \((#file as NSString).lastPathComponent):\(#line) " +
              "Bayer RAW pixel format not available")
      }
    }
  }
  
  func appleProRAWCapture(_ promise: Promise) {
    guard #available(iOS 14.3, *) else { return }
    videoOutputQueue.async {
      guard let photoOutput = self.photoOutput else {
        if self.photo?.boolValue == true {
          promise.reject(error: .session(.cameraNotReady))
          return
        } else {
          promise.reject(error: .capture(.photoNotEnabled))
          return
        }
      }
      // Apple ProRAW
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
      } else {
        print("🔴 \((#file as NSString).lastPathComponent):\(#line) " +
              "Apple ProRAW pixel format not available")
      }
    }
  }
}
