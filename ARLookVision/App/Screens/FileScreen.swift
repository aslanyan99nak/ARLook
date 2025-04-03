//
//  FileScreen.swift
//  ARLook
//
//  Created by Narek on 13.03.25.
//

import SwiftUI

struct FileScreen: View {
  
  @State private var isShowPicker: Bool = false
  
  var pickedURLCompletion: (URL?) -> Void

  var body: some View {
    Button {
      isShowPicker = true
    } label: {
      Text("Show Document Picker")
    }
    .linearGradientBackground()
    .sheet(isPresented: $isShowPicker) {
      DocumentPicker { url in
        pickedURLCompletion(url)
      }
      .onDisappear {
        isShowPicker = false
      }
    }
  }

}

#Preview(windowStyle: .automatic) {
  FileScreen { _ in }
}
