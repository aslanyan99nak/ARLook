//
//  UIApplication+Ext.swift
//  ARLook
//
//  Created by Narek on 28.03.25.
//

import UIKit

extension UIApplication {

  var keyWindow: UIWindow {
    UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow }) ?? UIWindow()
  }

  var screenWidth: CGFloat {
    UIApplication.shared.keyWindow.bounds.size.width
  }

}
