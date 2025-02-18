//
//  ProConListView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct ProConListView: View {

  let prosTitle: String
  let pros: [String]
  let consTitle: String
  let cons: [String]

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Divider()
        .padding(.bottom, 4)

      rightInfoView

      Divider()
        .padding(.bottom, 4)
        .padding(.top, 20)

      wrongInfoView
    }
  }

  private var rightInfoView: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(prosTitle)
          .dynamicFont(weight: .bold)
          .bold()

        Spacer()
        
        Image(systemName: Image.checkMarkCircle)
          .renderingMode(.template)
          .resizable()
          .frame(width: 24, height: 24)
          .foregroundStyle(.green)
      }

      ForEach(pros, id: \.self) { pro in
        Text(pro)
          .dynamicFont()
          .foregroundStyle(.secondary)
      }
    }
  }

  private var wrongInfoView: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(consTitle)
          .dynamicFont(weight: .bold)

        Spacer()
        
        Image(systemName: Image.xMarkCircle)
          .renderingMode(.template)
          .resizable()
          .frame(width: 24, height: 24)
          .foregroundStyle(.red)
        
      }

      ForEach(cons, id: \.self) { con in
        Text(con)
          .dynamicFont()
          .foregroundStyle(.secondary)
      }
    }
  }

}

#Preview {
  ProConListView(
    prosTitle: "esdfgdfg",
    pros: ["sad", "dsfdf", "dsfdsf"],
    consTitle: "dsgsdf",
    cons: ["dsfdsf"]
  )
}
