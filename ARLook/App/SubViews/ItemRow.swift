//
//  ItemRow.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import SwiftUI

struct ItemRow: View {

  @Environment(\.colorScheme) private var colorScheme

  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  let image: Image
  let title: String
  let description: String

  var body: some View {
    HStack(spacing: 0) {
      icon
      infoView
        .padding(.leading, 16)
      Spacer()
    }
    .padding()
    .if(isDarkMode) { view in
      view
        .background(.regularMaterial)
    }
    .if(!isDarkMode) { view in
      view
        .background(.white)
    }
    .background(isDarkMode ? Color.gray.opacity(0.15) : Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 24))
    .if(!isDarkMode) { view in
      view
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: -1)
        .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4)
    }
  }

  private var icon: some View {
    ZStack {
      Image(.itemBackground)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 62)

      image
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 40)
    }
  }

  private var infoView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .dynamicFont(size: 20, weight: .bold)
        .foregroundStyle(isDarkMode ? Color.white : Color.black)
        .multilineTextAlignment(.leading)

      Text(description)
        .dynamicFont(weight: .regular)
        .foregroundStyle(isDarkMode ? Color.white : Color.black)
        .multilineTextAlignment(.leading)
    }
  }

}

#Preview {
  ItemRow(
    image: Image(systemName: Image.qrCode),
    title: "QR code title",
    description: "QR code description"
  )
  .padding()
}
