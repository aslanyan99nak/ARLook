//
//  HelpPageScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct HelpPageScreen: View {

  @Binding var showInfo: Bool

  var body: some View {
    ZStack {
      VStack(alignment: .leading) {
        HStack {
          Text("Capture Help")
            .foregroundStyle(.secondary)
          Spacer()
          closeButton
        }
        tabView
      }
      .padding()
    }
    .navigationTitle("Scanning Info")
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
      pageName: String.LocalizedString.objectHelpPageName,
      imageName: Constant.objectHelpImageName,
      imageCaption: String.LocalizedString.objectHelpCaption,
      prosTitle: String.LocalizedString.objectProsTitle,
      pros: [
        String.LocalizedString.objectPros1,
        String.LocalizedString.objectPros2,
        String.LocalizedString.objectPros3,
      ],
      consTitle: String.LocalizedString.objectConsTitle,
      cons: [
        String.LocalizedString.objectCons1,
        String.LocalizedString.objectCons2,
      ])
  }

  private var environmentHelpPageView: some View {
    TutorialPageView(
      pageName: String.LocalizedString.envHelpPageName,
      imageName: Constant.envHelpImageName,
      imageCaption: String.LocalizedString.environmentHelpCaption,
      prosTitle: String.LocalizedString.envProsTitle,
      pros: [
        String.LocalizedString.envPros1,
        String.LocalizedString.envPros2,
        String.LocalizedString.envPros3,
      ],
      consTitle: String.LocalizedString.envConsTitle,
      cons: [
        String.LocalizedString.envCons1,
        String.LocalizedString.envCons2,
      ])
  }

}

#Preview {
  HelpPageScreen(showInfo: .constant(false))
}
