//
//  TiQrcodeModule.swift
//  titanium-qrcode
//
//  Created by Hans Knoechel
//  Copyright (c) 2020 Hans Knoechel. All rights reserved.
//

import TitaniumKit
import QRScanner

@available(macCatalyst 14.0, *)
@objc(TiQrcodeModule)
class TiQrcodeModule: TiModule {

  func moduleGUID() -> String {
    return "bb7cc9ed-8591-467b-8608-be59b82bf201"
  }
  
  override func moduleId() -> String! {
    return "ti.qrcode"
  }
  
  var _scannerCallback: KrollCallback?

  @objc(fromString:)
  func fromString(arguments: Array<Any>?) -> TiBlob? {
    guard let arguments = arguments, let text = arguments.first as? String else {
      return nil
    }
    
    guard var qrCode = QRCode(text) else {
      return nil
    }

    qrCode.size = CGSize(width: 450, height: 450)
    
    if arguments.count == 2, let options = arguments[1] as? [String: Any] {
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
     guard let arguments = arguments,
           let params = arguments.first as? [String: Any],
           let callback = params["callback"] as? KrollCallback else {
       return
     }
     
     _scannerCallback = callback

     let focusImage = TiUtils.toImage(params["scanImage"], proxy: self)
     
     let vc = UIViewController()
     let qrScannerView = QRScannerView(frame: vc.view.bounds)
     vc.view.addSubview(qrScannerView)
     qrScannerView.configure(delegate: self, input: .init(focusImage: focusImage, animationDuration: 0.75, isBlurEffectEnabled: true))
     qrScannerView.startRunning()
     
     let nav = UINavigationController(rootViewController: vc)
     nav.isNavigationBarHidden = true

     topMostViewController()?.present(nav, animated: true)
  }
  
  private func topMostViewController() -> UIViewController? {
     guard let controller = TiApp.controller(), let topPresentedController = controller.topPresentedController() else {
       print("[WARN] No window opened. Ignoring gallery call …")
       return nil
     }

     return topPresentedController
   }
}

// MARK: QRScannerViewDelegate

extension TiQrcodeModule: QRScannerViewDelegate {
  func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
    qrScannerView.parentViewController?.dismiss(animated: true)

    _scannerCallback?.call([["success": true, "text": code]], thisObject: self)
    _scannerCallback = nil
  }
  
  func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
    qrScannerView.parentViewController?.dismiss(animated: true)

    _scannerCallback?.call([["success": false, "error": error.localizedDescription]], thisObject: self)
    _scannerCallback = nil
  }
}

extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
