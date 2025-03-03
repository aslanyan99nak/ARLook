//
//  MainTabBar.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

extension MainTabBar {

  enum TabItem: Hashable {

    case home
//    case list
    case search
    case settings

  }

}

struct MainTabBar: View {

  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @StateObject private var popupVM = PopupViewModel()
  @State private var selectedTab: TabItem = .home

  var body: some View {
    contentView
  }

  private var contentView: some View {
    ZStack {
      TabView(selection: $selectedTab) {
        mainScreen
//        modelsListScreen
        searchScreen
        settingsScreen
      }
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
      .tabItem {
        VStack(spacing: 0) {
          Image(.scanner)
            .renderingMode(.template)
            .foregroundStyle(selectedTab == .home ? accentColorType.color : Color.gray)

          Text(LocString.scanner)
            .foregroundStyle(.blue)
            .dynamicFont()
        }
      }
  }

//  private var modelsListScreen: some View {
//    ModelsListScreen()
//      .tag(TabItem.list)
//      .tabItem {
//        VStack(spacing: 0) {
//          Image(systemName: Image.list)
//
//          Text(LocString.list)
//            .foregroundStyle(.blue)
//            .dynamicFont()
//        }
//      }
//  }

  private var searchScreen: some View {
    SearchScreen()
      .tag(TabItem.search)
      .tabItem {
        VStack(spacing: 0) {
          Image(systemName: Image.search)

          Text(LocString.search)
            .foregroundStyle(.blue)
            .dynamicFont()
        }
      }
  }

  private var settingsScreen: some View {
    SettingsScreen()
      .tag(TabItem.settings)
      .tabItem {
        VStack(spacing: 0) {
          Image(systemName: Image.settings)

          Text(LocString.settings)
            .foregroundStyle(.blue)
            .dynamicFont()
        }
      }
  }

}

#Preview {
  MainTabBar()
}
