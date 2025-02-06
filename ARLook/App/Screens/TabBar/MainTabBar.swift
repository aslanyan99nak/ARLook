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
          Image(systemName: "house")

          Text("Home")
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

          Text("List")
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

          Text("Search")
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

          Text("Settings")
            .foregroundStyle(.blue)
        }
      }
  }

}

#Preview {
  MainTabBar()
}
