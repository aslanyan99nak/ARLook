//
//  View3DScreen.swift
//  ARLook
//
//  Created by Narek on 17.03.25.
//

import SwiftUI

struct View3DScreen: View {
  
  @Binding var previewURL: URL?
  var action: () -> Void

  var body: some View {
    VStack(spacing: 40) {
      Text(LocString.viewModelDescription)
        .font(.extraLargeTitle)
        .padding(20)

      Button {
        action()
      } label: {
        Text(LocString.view3DMode)
      }
      .quickLookPreview($previewURL)
    }

  }

}
