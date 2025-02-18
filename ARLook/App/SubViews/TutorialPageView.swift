//
//  TutorialPageView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct TutorialPageView: View {

  let pageName: String
  let imageName: String
  let imageCaption: String
  let prosTitle: String
  let pros: [String]
  let consTitle: String
  let cons: [String]

  var body: some View {
    VStack(alignment: .leading) {
      Text(pageName)
        .dynamicFont(size: 20, weight: .bold)
        .foregroundStyle(.primary)

      Text(imageCaption)
        .dynamicFont()
        .foregroundStyle(.secondary)

      Image(imageName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.leading)

      ProConListView(
        prosTitle: prosTitle,
        pros: pros,
        consTitle: consTitle,
        cons: cons
      )

      Spacer()
    }
    .navigationBarTitle(pageName, displayMode: .inline)
  }

}

#Preview {
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
    ]
  )
  .padding()
}
