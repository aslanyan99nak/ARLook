//
//  CustomColorSchemeViewModifier.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

struct CustomColorSchemeViewModifier: ViewModifier {

  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @State private var tempColorScheme: ColorScheme? = nil
  @Binding var customColorScheme: CustomColorScheme

  init(_ customColorScheme: Binding<CustomColorScheme>) {
    self._customColorScheme = customColorScheme
  }

  func getSystemColorScheme() -> ColorScheme {
    UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
  }

  func body(content: Content) -> some View {
    content
      .preferredColorScheme(tempColorScheme ?? customColorScheme.colorScheme)
      .onChange(of: customColorScheme) { _, value in
        if value == .system {
          tempColorScheme = getSystemColorScheme()
        }
      }
      .onReceive(
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
      ) { _ in
        if customColorScheme == .system {
          let systemColorScheme = getSystemColorScheme()
          if systemColorScheme != colorScheme.colorScheme {
            tempColorScheme = systemColorScheme
          }
        }
      }
      .onChange(of: tempColorScheme) { _, value in
        if value != nil {
          DispatchQueue.main.async {
            // Resets tempColorScheme back to nil. This occurs after colorScheme has been updated
            tempColorScheme = nil
          }
        }
      }
  }
  
}
