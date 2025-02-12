//
//  Show3DCardView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import SwiftUI

struct Show3DCardView: View {
  
  @Environment(\.colorScheme) var colorScheme
  
  private var isDarkMode: Bool {
    colorScheme == .dark
  }
  
  var body: some View {
    HStack(spacing: 0) {
      cardLeftSideView
      Spacer()
      
      Image(.qrEmpty)
        .resizable()
        .frame(width: 100, height: 100)
      
    }
    .padding()
    .background(.regularMaterial)
    .background(isDarkMode ? Color.gray.opacity(0.15) : Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 24))
    .shadow(radius: 10)
  }
  
  private var cardLeftSideView: some View {
    VStack(spacing: 8) {
      Text(String.LocString.view3DMode)
        .font(Font.system(size: 24, weight: .bold))
        .foregroundStyle(isDarkMode ? Color.white : Color.black)
      
      HStack(spacing: 0) {
        Image(systemName: "cube")
          .resizable()
          .frame(width: 60, height: 60)
          .foregroundStyle(isDarkMode ? Color.white : Color.black)
        
        Spacer()
      }
      .padding()
    }
  }

}

#Preview {
  Show3DCardView()
    .padding()
}
