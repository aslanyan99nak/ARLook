//
//  SidebarEmptyView.swift
//  ARLook
//
//  Created by Narek on 02.04.25.
//

import SwiftUI

struct SidebarEmptyView: View {
  
  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  
  var body: some View {
    VStack(spacing: 0) {
      Image(.sidebarEmptyState)
        .renderingMode(.template)
        .foregroundStyle(accentColorType.color)
        .padding(.bottom, 40)
      
      Text("Ready to explore?")
        .dynamicFont(size: 32, weight: .bold)
        .foregroundStyle(.white)
        .padding(.bottom, 20)
      
      HStack(spacing: 12) {
        Image(systemName: "sidebar.squares.leading")
          .renderingMode(.template)
          .resizable()
          .foregroundStyle(.white)
          .frame(width: 26, height: 26)
        
        Text("Choose a tool from the sidebar")
          .dynamicFont(size: 24, weight: .regular)
          .foregroundStyle(.white)
      }
    }
  }
  
}
