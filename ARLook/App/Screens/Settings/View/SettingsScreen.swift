//
//  SettingsScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct SettingsScreen: View {

  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @AppStorage("textSize") private var textSize: Double = 0
  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @AppStorage("isHandTrackingEnabled") var isHandTrackingEnabled: Bool = false
  #if os(visionOS)
    @EnvironmentObject var handTrackingViewModel: HandTrackingViewModel
  #endif
  @State private var isColorSheetPresented = false
  @State private var brightness: CGFloat = 0

  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 16) {
          Text(LocString.appearance)
            .dynamicFont()
            .foregroundStyle(UIDevice.isVision ? .white : .gray)
            .padding(.leading, 8)

          themeList
          accentColorRow
          TextSizeRow()
          if UIDevice.isVision {
            handTrackingSwitch
          }
        }
        .padding(.horizontal, 16)
      }
      .navigationTitle(LocString.settings)
    }
  }

  private var themeList: some View {
    VStack(spacing: 0) {
      ForEach(CustomColorScheme.allCases, id: \.self) { mode in
        VStack(spacing: 0) {
          ThemeRow(mode: mode)
            .padding(.vertical, 10)

          if mode != CustomColorScheme.allCases.last {
            Divider().overlay { Color.gray }
          }
        }
        .onTapGesture {
          withAnimation {
            colorScheme = mode
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .background(Material.regular)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  private var accentColorRow: some View {
    HStack(spacing: 0) {
      Text(LocString.accentColor)
        .minimumScaleFactor(0.5)
        .dynamicFont()

      Spacer()

      ColorPicker(accentColorType: $accentColorType)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(Material.regular)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  private var handTrackingSwitch: some View {
    Toggle(isOn: $isHandTrackingEnabled) {
      Text(isHandTrackingEnabled ? "Disable Hand Tracking" : "Enable Hand Tracking")
        .minimumScaleFactor(0.5)
        .dynamicFont()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(Material.regular)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .onChange(of: isHandTrackingEnabled) { _, newValue in
      #if os(visionOS)
        handTrackingViewModel.hideShowHandTracking(newValue)
      #endif
    }
  }

}

#Preview {
  SettingsScreen()
}
