//
//  CancelButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct CancelButton: View {

  @EnvironmentObject var appModel: AppDataModel
  
  let buttonLabel: String

  var body: some View {
    Button {
      print("Cancel button clicked!")
      appModel.setPreviewModelState(shown: false)
    } label: {
      Text(buttonLabel)
        .dynamicFont(weight: .bold)
        .padding(30)
        .foregroundStyle(.blue)
    }
  }

}
