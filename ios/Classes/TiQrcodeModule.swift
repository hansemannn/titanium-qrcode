//
//  TiQrcodeModule.swift
//  titanium-qrcode
//
//  Created by Hans Knoechel
//  Copyright (c) 2020 Your Company. All rights reserved.
//

import TitaniumKit

@objc(TiQrcodeModule)
class TiQrcodeModule: TiModule {

  public let testProperty: String = "Hello World"
  
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

    return TiBlob(image: qrCode.image)
  }
}
