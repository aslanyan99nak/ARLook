//
//  SettingsScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

extension SettingsScreen {

  enum AppearanceType: String, CaseIterable {

    case icon
    case theme
    case font

    var name: String {
      switch self {
      case .icon: "App icon"
      case .theme: "Theme"
      case .font: "Font"
      }
    }

    var icon: Image {
      switch self {
      case .icon: Image(systemName: "squareshape")
      case .theme: Image(systemName: "paintbrush")
      case .font: Image(systemName: "textformat.abc")
      }
    }

  }

}

struct SettingsScreen: View {

  var body: some View {
    NavigationStack {
      Form {
        sectionView
      }
      .navigationTitle("Settings")
    }
  }

  private var sectionView: some View {
    Section {
      ForEach(AppearanceType.allCases, id: \.self) { appearance in
        NavigationLink {
          Text(appearance.name)
        } label: {
          Label {
            Text(appearance.name)
          } icon: {
            appearance.icon
              .resizable()
              .frame(width: 24, height: 24)
          }
        }
      }
    } header: {
      Text("Appearance")
    }
  }

}

#Preview {
  SettingsScreen()
}
