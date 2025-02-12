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
    case list
    case search
    case settings
    
  }
  
}

struct MainTabBar: View {

  @State private var selectedTab: TabItem = .home

  var body: some View {
    contentView
  }

  private var contentView: some View {
    TabView(selection: $selectedTab) {
      mainScreen
      modelsListScreen
      searchScreen
      settingsScreen
    }
  }
  
  private var mainScreen: some View {
    MainScreen()
      .tag(TabItem.home)
      .tabItem {
        VStack(spacing: 0) {
          Image(.scanner)
            .renderingMode(.template)
            .foregroundStyle(selectedTab == .home ? Color.blue : Color.gray)

          Text(String.LocString.scanner)
            .foregroundStyle(.blue)
        }
      }
  }
  
  private var modelsListScreen: some View {
    ModelsListScreen()
      .tag(TabItem.list)
      .tabItem {
        VStack(spacing: 0) {
          Image(systemName: "list.bullet.clipboard")

          Text(String.LocString.list)
            .foregroundStyle(.blue)
        }
      }
  }
  
  private var searchScreen: some View {
    SearchScreen()
      .tag(TabItem.search)
      .tabItem {
        VStack(spacing: 0) {
          Image(systemName: "magnifyingglass")

          Text(String.LocString.search)
            .foregroundStyle(.blue)
        }
      }
  }
  
  private var settingsScreen: some View {
    SettingsScreen()
      .tag(TabItem.settings)
      .tabItem {
        VStack(spacing: 0) {
          Image(systemName: "gear")

          Text(String.LocString.settings)
            .foregroundStyle(.blue)
        }
      }
  }

}

#Preview {
  MainTabBar()
}
