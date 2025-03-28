//
//  PopupViewModel.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

class PopupViewModel: ObservableObject {
  
  @Published var isShowPopup: Bool = false
  @Published var popupContent: AnyView = AnyView(EmptyView())
  @Published var isShowTabBar: Bool = true

}
