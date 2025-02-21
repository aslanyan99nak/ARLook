//
//  CreateButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct CreateButton: View {

  @EnvironmentObject var appModel: AppDataModel
  @Environment(\.colorScheme) private var colorScheme

  let buttonLabel: String
  var buttonLabelColor: Color = Color.white
  var buttonBackgroundColor: Color = Color.blue
  var shouldApplyBackground = false
  var showBusyIndicator = false
  let action: () -> Void

  private var tintColor: Color {
    shouldApplyBackground ? .white : (colorScheme == .light ? .black : .white)
  }

  var body: some View {
    Button {
      print("\(buttonLabel) clicked!")
      action()
    } label: {
      buttonContentView
    }
    .if(shouldApplyBackground) { view in
      view.background(RoundedRectangle(cornerRadius: 16.0).fill(buttonBackgroundColor))
    }
    .padding(.leading)
    .padding(.trailing)
    .frame(maxWidth: UIDevice.isPad ? 380 : .infinity)
  }

  private var buttonContentView: some View {
    ZStack {
      if showBusyIndicator {
        HStack {
          Text(buttonLabel)
            .dynamicFont()
            .hidden()
          Spacer().frame(maxWidth: 48)

          CircularProgressView(tintColor: tintColor)
        }
      }
      Text(buttonLabel)
        .dynamicFont(weight: .bold)
        .foregroundStyle(buttonLabelColor)
        .padding()
        .frame(maxWidth: .infinity)
    }
  }

}
