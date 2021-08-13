//
//  TiQrcodeModule.swift
//  titanium-qrcode
//
//  Created by Hans Knoechel
//  Copyright (c) 2020 Hans Knoechel. All rights reserved.
//

import TitaniumKit

@available(macCatalyst 14.0, *)
@objc(TiQrcodeModule)
class TiQrcodeModule: TiModule {

  func moduleGUID() -> String {
    return "bb7cc9ed-8591-467b-8608-be59b82bf201"
  }
  
  override func moduleId() -> String! {
    return "ti.qrcode"
  }

  @objc(fromString:)
  func fromString(arguments: Array<Any>?) -> TiBlob? {
    guard let arguments = arguments, let text = arguments.first as? String else {
      return nil
    }
    
    guard var qrCode = QRCode(text) else {
      return nil
    }

    qrCode.size = CGSize(width: 450, height: 450)
    
    if let options = arguments[1] as? [String: Any] {
      if let size = options["size"] as? [String: Int],
        let width = size["width"],
        let height = size["height"] {
        qrCode.size = CGSize(width: width, height: height)
      }
      
      if let color = options["color"], let nativeColor = TiUtils.colorValue(color) {
        qrCode.color = CIColor(color: nativeColor.color)
      }
      
      if let backgroundColor = options["backgroundColor"], let nativeBackgroundColor = TiUtils.colorValue(backgroundColor) {
        qrCode.backgroundColor = CIColor(color: nativeBackgroundColor.color)
      }
    }

    return TiBlob(image: qrCode.image)
  }

  @objc(scan:)
   func scan(arguments: Array<Any>?) {
    guard let arguments = arguments, let callback = arguments.first as? KrollCallback else {
      return
    }
    
    let builder = QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        
        $0.showTorchButton        = false
        $0.showSwitchCameraButton = false
        $0.showCancelButton       = true
        $0.showOverlayView        = false
        $0.cancelButtonTitle = NSLocalizedString("cancel", comment: "Cancel")
    }
    
    let readerVC = QRCodeReaderViewController(builder: builder)
    readerVC.delegate = self

    readerVC.completionBlock = { (result: QRCodeReaderResult?) in
      callback.call([["text": result?.value ?? "", "success": result != nil]], thisObject: self)
    }

    readerVC.modalPresentationStyle = .formSheet
    topMostViewController()?.present(readerVC, animated: true, completion: nil)
  }
  
  private func topMostViewController() -> UIViewController? {
     guard let controller = TiApp.controller(), let topPresentedController = controller.topPresentedController() else {
       print("[WARN] No window opened. Ignoring gallery call …")
       return nil
     }

     return topPresentedController
   }
}

// MARK: QRCodeReaderViewControllerDelegate

@available(macCatalyst 14.0, *)
extension TiQrcodeModule : QRCodeReaderViewControllerDelegate {

  func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
    reader.stopScanning()

    reader.dismiss(animated: true, completion: nil)
  }

  func readerDidCancel(_ reader: QRCodeReaderViewController) {
    reader.stopScanning()

    reader.dismiss(animated: true, completion: nil)
  }
}
