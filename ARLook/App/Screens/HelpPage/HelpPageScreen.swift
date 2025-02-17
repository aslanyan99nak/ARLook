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
          Text(String.LocString.captureHelp)
            .foregroundStyle(.secondary)
            .dynamicFont()

          Spacer()
          closeButton
        }
        tabView
      }
      .padding()
    }
    .navigationTitle(String.LocString.scanningInfo)
    .navigationViewStyle(StackNavigationViewStyle())
  }
  
  private var closeButton: some View {
    Button {
      withAnimation {
        showInfo = false
      }
    } label: {
      Image(systemName: "xmark.circle.fill")
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
    TutorialPageView(
      pageName: String.LocString.objectHelpPageName,
      imageName: Constant.objectHelpImageName,
      imageCaption: String.LocString.objectHelpCaption,
      prosTitle: String.LocString.objectProsTitle,
      pros: [
        String.LocString.objectPros1,
        String.LocString.objectPros2,
        String.LocString.objectPros3,
      ],
      consTitle: String.LocString.objectConsTitle,
      cons: [
        String.LocString.objectCons1,
        String.LocString.objectCons2,
      ])
  }

  private var environmentHelpPageView: some View {
    TutorialPageView(
      pageName: String.LocString.envHelpPageName,
      imageName: Constant.envHelpImageName,
      imageCaption: String.LocString.environmentHelpCaption,
      prosTitle: String.LocString.envProsTitle,
      pros: [
        String.LocString.envPros1,
        String.LocString.envPros2,
        String.LocString.envPros3,
      ],
      consTitle: String.LocString.envConsTitle,
      cons: [
        String.LocString.envCons1,
        String.LocString.envCons2,
      ])
  }

}

#Preview {
  HelpPageScreen(showInfo: .constant(false))
}
