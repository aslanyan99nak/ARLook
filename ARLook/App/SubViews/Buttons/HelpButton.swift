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
      print("\(String.LocString.help) button clicked!")
      withAnimation {
        showInfo = true
      }
    } label: {
      buttonContentView
    }
  }
  
  private var buttonContentView: some View {
    VStack(spacing: 10) {
      Image(systemName: "questionmark.circle")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 22)

      Text(String.LocString.help)
        .font(.footnote)
        .opacity(0.7)
        .fontWeight(.semibold)
    }
    .foregroundStyle(.white)
  }
  
}
