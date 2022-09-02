//
//  MultiFormatPhotoCaptureDelegate.swift
//  mrousavy
//
//  Created by Marc Rousavy on 15.12.20.
//  Copyright © 2020 mrousavy. All rights reserved.
//

import AVFoundation
import Foundation

private var delegatesReferences: [NSObject] = []
private var processedPhotos: [[String: Any]] = []

// MARK: - MultiFormatPhotoCaptureDelegate

enum PhotoOutputFormat: String {
  case jpeg = "jpeg"
  case hvec = "heic"
  case uncompressedTIFF = "tiff"
  case bayerRAW = "bayerRAW.dng"
  case appleProRAW = "appleProRAW.dng"
}

class MultiFormatPhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
  private let promise: Promise
  private let format: PhotoOutputFormat

  required init(promise: Promise, format: PhotoOutputFormat) {
    self.promise = promise
    self.format = format
    super.init()
    delegatesReferences.append(self)
  }

  // TODO: modify this to take in a format and only resolve when all photos are captured
  func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let error = error as NSError? {
      promise.reject(error: .capture(.unknown(message: error.description)), cause: error)
      return
    }

    let error = ErrorPointer(nilLiteral: ())
    guard let tempFilePath: String = RCTTempFilePath(format.rawValue, error)
    else {
      promise.reject(error: .capture(.createTempFileError), cause: error?.pointee)
      return
    }
    let url = URL(string: "file://\(tempFilePath)")!
//    let filename = tempFilePath.replacingOccurrences(of: format.rawValue, with: "").suffix(5) + format.rawValue
    let filename = "card.\(format.rawValue)"

    guard let data = photo.fileDataRepresentation() else {
      promise.reject(error: .capture(.fileError))
      return
    }

    do {
      try data.write(to: url)
      let exif = photo.metadata["{Exif}"] as? [String: Any]
      let width = exif?["PixelXDimension"]
      let height = exif?["PixelYDimension"]

      processedPhotos.append([
        "format": self.format.rawValue,
        "path": tempFilePath,
        "filename": filename,
        "width": width as Any,
        "height": height as Any,
        "isRawPhoto": photo.isRawPhoto,
        "metadata": photo.metadata,
        "thumbnail": photo.embeddedThumbnailPhotoFormat as Any,
      ])
      print("🟡 \((#file as NSString).lastPathComponent):\(#line) " +
            "delegatesReferences.count: \(delegatesReferences.count) processedPhotos: \(processedPhotos.count)")
      delegatesReferences.removeAll(where: { $0 == self })
      if processedPhotos.count == 5 {
        promise.resolve(processedPhotos)
        processedPhotos = []
      }
    } catch {
      promise.reject(error: .capture(.fileError), cause: error as NSError)
    }
  }

  func photoOutput(_: AVCapturePhotoOutput, didFinishCaptureFor _: AVCaptureResolvedPhotoSettings, error: Error?) {
    defer {
      delegatesReferences.removeAll(where: { $0 == self })
    }
    if let error = error as NSError? {
      promise.reject(error: .capture(.unknown(message: error.description)), cause: error)
      return
    }
  }
}
