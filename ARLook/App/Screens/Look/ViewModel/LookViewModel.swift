//
//  LookViewModel.swift
//  ARLook
//
//  Created by Narek on 28.02.25.
//

import SwiftUI
import FocusEntity

class LookViewModel: ObservableObject {
  
  @Published var fileURL: URL?
  @Published var isShowPicker: Bool = false
  @Published var isLoading: Bool = false
  @Published var selectedModel: Model?
  @Published var isShowSelectedModel: Bool = true
  @Published var isFocusEntityEnabled: Bool = true
  @Published var isShowSelected: Bool = true
  @Published var isShowButtonsStack: Bool = true
  @Published var focusEntity: FocusEntity?
  
}
