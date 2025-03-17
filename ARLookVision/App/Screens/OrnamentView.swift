//
//  OrnamentView.swift
//  ARLookVision
//
//  Created by Narek on 04.03.25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct OrnamentView: View {

  var body: some View {
    TabView {
      mainScreen
      searchScreen
      settingsScreen
    }
  }

  private var mainScreen: some View {
    MainScreen()
      .tabItem {
        Label(LocString.scanner, image: .scanner)
      }
  }

  private var searchScreen: some View {
    SearchScreen()
      .tabItem {
        Label(LocString.search, systemImage: Image.search)
      }
  }

  private var settingsScreen: some View {
    SettingsScreen()
      .tabItem {
        Label(LocString.settings, systemImage: Image.settings)
      }
  }

}

#Preview(windowStyle: .automatic) {
  OrnamentView()
}
