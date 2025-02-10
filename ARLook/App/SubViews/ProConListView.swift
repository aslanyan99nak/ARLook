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
          .bold()

        Spacer()

        Text(Image(systemName: "checkmark.circle"))
          .bold()
          .foregroundStyle(.green)
      }

      ForEach(pros, id: \.self) { pro in
        Text(pro)
          .foregroundStyle(.secondary)
      }
    }
  }

  private var wrongInfoView: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(consTitle)
          .bold()

        Spacer()

        Text(Image(systemName: "xmark.circle"))
          .bold()
          .foregroundStyle(.red)
      }

      ForEach(cons, id: \.self) { con in
        Text(con)
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
