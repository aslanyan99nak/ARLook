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
    GeometryReader { geomReader in
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
          .frame(width: 0.85 * geomReader.size.width) // Leaves 15% margins.
          .padding(.leading)

        ProConListView(
          prosTitle: prosTitle,
          pros: pros,
          consTitle: consTitle,
          cons: cons
        )

        Spacer()
      }
      .frame(width: geomReader.size.width, height: geomReader.size.height)
    }
    .navigationBarTitle(pageName, displayMode: .inline)
  }

}
