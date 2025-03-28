//
//  MainTabBar.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

enum TabItem: String, CaseIterable, Hashable {

  case home
  //    case list
  case search
  case settings

  var icon: Image {
    switch self {
    case .home: Image(.scanner)
    case .search: Image(systemName: Image.search)
    case .settings: Image(systemName: Image.settings)
    }
  }

  var id: Int {
    switch self {
    case .home: 0
    case .search: 1
    case .settings: 2
    }
  }

  var name: String {
    switch self {
    case .home: LocString.scanner
    case .search: LocString.search
    case .settings: LocString.settings
    }
  }

}

struct MainTabBar: View {

  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @StateObject private var popupVM = PopupViewModel()
  @State private var selectedTab: TabItem = .home
  @State private var midPoint: CGFloat = 1.0
  @Namespace private var animation

  init() {
    let app = UITabBarAppearance()
    app.backgroundEffect = .none
    app.shadowColor = .clear
    UITabBar.appearance().standardAppearance = app
    UITabBar.appearance().isHidden = true
  }

  private let iconH: CGFloat = 60
  private let screenWidth: CGFloat = UIApplication.shared.screenWidth
  private var tabWidth: CGFloat { screenWidth / 3 }

  var body: some View {
    contentView
  }

  private var contentView: some View {
    ZStack {
      TabView(selection: $selectedTab) {
        mainScreen
        searchScreen
        settingsScreen
      }
      .overlay(alignment: .bottom) {
        CustomTabBar(
          selectedTab: $selectedTab,
          animation: animation
        )
        .offset(y: popupVM.isShowTabBar ? -20 : 150)
      }
      .ignoresSafeArea(.all)
      .accentColor(accentColorType.color)
      .blur(radius: popupVM.isShowPopup ? 5 : 0)
      .disabled(popupVM.isShowPopup)

      if popupVM.isShowPopup {
        Color.black.opacity(0.2).ignoresSafeArea()
          .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
              popupVM.isShowPopup = false
              popupVM.popupContent = AnyView(EmptyView())
            }
          }
        popupVM.popupContent
      }
    }
    .environmentObject(popupVM)
    .customColorScheme($colorScheme)
  }

  private var mainScreen: some View {
    MainScreen()
      .tag(TabItem.home)
  }

  //  private var modelsListScreen: some View {
  //    ModelsListScreen()
  //      .tag(TabItem.list)
  //  }

  private var searchScreen: some View {
    SearchScreen()
      .tag(TabItem.search)
  }

  private var settingsScreen: some View {
    SettingsScreen()
      .tag(TabItem.settings)
  }

}

#Preview {
  MainTabBar()
}
