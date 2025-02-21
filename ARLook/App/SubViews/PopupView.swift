//
//  PopupView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

struct PopupView: View {
  
//  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @Environment(\.colorScheme) private var colorScheme

  let action: () -> Void
  
  private var isDarkMode: Bool {
    colorScheme == .dark
  }
  
  var body: some View {
    VStack(spacing: 20) {
      icon
      titleView
      button
    }
    .padding()
    .background(.regularMaterial)
    .background(isDarkMode ? Color.gray.opacity(0.15) : Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 24))
    .shadow(radius: 10)
    .padding(.horizontal, 16)
  }
  
  private var icon: some View {
    Image(.lidar)
      .resizable()
      .frame(width: 50, height: 50)
  }
  
  private var titleView: some View {
    Text(LocString.canNotScanModel)
      .dynamicFont()
      .multilineTextAlignment(.center)
      .foregroundStyle(isDarkMode ? .white : .black)
  }
  
  private var button: some View {
    Button {
      action()
    } label: {
      Text(LocString.ok)
        .dynamicFont()
        .foregroundStyle(.white)
        .padding(.vertical, 8)
        .frame(minWidth: 100, idealWidth: 100, maxWidth: 140)
        .background(Color.purple)
        .clipShape(Capsule())
    }
  }
  
}
