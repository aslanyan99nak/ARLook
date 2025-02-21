//
//  HelpButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct HelpButton: View {

  @Binding var showInfo: Bool

  var body: some View {
    Button {
      print("\(LocString.help) button clicked!")
      withAnimation {
        showInfo = true
      }
    } label: {
      buttonContentView
    }
  }
  
  private var buttonContentView: some View {
    VStack(spacing: 10) {
      Image(systemName: Image.questionMark)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 32, height: 32)

      Text(LocString.help)
        .fontWeight(.semibold)
        .opacity(0.7)
    }
    .foregroundStyle(.white)
  }
  
}
