//
//  HelpPageScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct HelpPageScreen: View {

  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @Binding var showInfo: Bool

  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  var body: some View {
    ZStack {
      VStack(alignment: .leading) {
        HStack {
          Text(LocString.captureHelp)
            .foregroundStyle(.secondary)
            .dynamicFont()

          Spacer()
          closeButton
        }
        tabView
      }
      .padding()
    }
    .navigationTitle(LocString.scanningInfo)
    .navigationViewStyle(StackNavigationViewStyle())
  }

  private var closeButton: some View {
    Button {
      withAnimation {
        showInfo = false
      }
    } label: {
      Image(systemName: Image.xMarkCircleFill)
        .foregroundStyle(.white.opacity(0.5))
        .font(.title)
    }
  }

  private var tabView: some View {
    TabView {
      objectHelpPageView
      environmentHelpPageView
    }
    .tabViewStyle(PageTabViewStyle())
    .onAppear {
      UIPageControl.appearance().currentPageIndicatorTintColor = .black
      UIPageControl.appearance().pageIndicatorTintColor = .lightGray
    }
  }

  private var objectHelpPageView: some View {
    ScrollView(showsIndicators: false) {
      TutorialPageView(
        pageName: LocString.objectHelpPageName,
        imageName: Image.objectHelp,
        imageCaption: LocString.objectHelpCaption,
        prosTitle: LocString.objectProsTitle,
        pros: [
          LocString.objectPros1,
          LocString.objectPros2,
          LocString.objectPros3,
        ],
        consTitle: LocString.objectConsTitle,
        cons: [
          LocString.objectCons1,
          LocString.objectCons2,
        ])
      .padding(.bottom, 40)
    }
  }

  private var environmentHelpPageView: some View {
    ScrollView(showsIndicators: false) {
      TutorialPageView(
        pageName: LocString.envHelpPageName,
        imageName: Image.envHelp,
        imageCaption: LocString.environmentHelpCaption,
        prosTitle: LocString.envProsTitle,
        pros: [
          LocString.envPros1,
          LocString.envPros2,
          LocString.envPros3,
        ],
        consTitle: LocString.envConsTitle,
        cons: [
          LocString.envCons1,
          LocString.envCons2,
        ])
      .padding(.bottom, 40)
    }
  }

}

#Preview {
  HelpPageScreen(showInfo: .constant(false))
}
