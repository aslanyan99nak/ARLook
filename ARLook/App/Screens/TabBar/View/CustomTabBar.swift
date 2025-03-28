//
//  CustomTabBar.swift
//  ARLook
//
//  Created by Narek on 28.03.25.
//

import SwiftUI

struct CustomTabBar: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @State var midPoint: CGFloat = 1.0
  @Binding var selectedTab: TabItem

  var animation: Namespace.ID

  private let iconH: CGFloat = 60
  private let screenWidth: CGFloat = UIApplication.shared.screenWidth

  private var tabWidth: CGFloat {
    screenWidth / 3
  }

  var body: some View {
    ZStack {
      BeziperCurveBelowPath(midPoint: midPoint)
        .fill(.ultraThinMaterial)

      HStack(spacing: 0) {
        ForEach(TabItem.allCases, id: \.id) { tab in
          createTabBarItem(tab)
        }
      }
      .background(Color.clear)
    }
    .frame(maxHeight: 60)
    .onAppear {
      midPoint = tabWidth * (-CGFloat(selectedTab.id - 1))
    }
  }

  private func createTabIconContent(_ tab: TabItem) -> some View {
    let isCurentTab = selectedTab == tab
    return tab
      .icon
      .renderingMode(.template)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .aspectRatio(isCurentTab ? 0.5 : 0.7, contentMode: .fit)
      .foregroundStyle(isCurentTab ? .white : .gray)
      .frame(
        width: isCurentTab ? iconH : 35,
        height: isCurentTab ? iconH : 35
      )
      .if(isCurentTab) { view in
        view
          .padding(4)
          .background(
            Circle()
              .foregroundStyle(accentColorType.color)
              .matchedGeometryEffect(id: "CircleAnimation", in: animation)
              .shadow(color: accentColorType.color.opacity(0.7), radius: 12, x: 0, y: 6)
              .shadow(color: accentColorType.color.opacity(0.7), radius: 12, x: 0, y: -6)

          )
      }
      .offset(y: isCurentTab ? -iconH / 2 : 0)
  }

  private func createTabBarItem(_ tab: TabItem) -> some View {
    Button {
      selectedTab = tab
      withAnimation(.spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.3)) {
        midPoint = tabWidth * (-CGFloat(selectedTab.id - 1))
      }
    } label: {
      VStack(spacing: 2) {
        createTabIconContent(tab)

        Text(tab.name)
          .font(.caption)
          .fontDesign(.rounded)
          .offset(y: selectedTab == tab ? -16 : 0)
      }
      .frame(maxWidth: .infinity)
    }
    .buttonStyle(.plain)
    .foregroundStyle(selectedTab == tab ? accentColorType.color : .gray)
  }

}
