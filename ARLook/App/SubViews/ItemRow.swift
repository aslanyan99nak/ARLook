//
//  ItemRow.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import SwiftUI

struct ItemRow: View {
  
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
    .background(Color.gray.opacity(0.4))
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
  
  private var icon: some View {
    image
      .resizable()
      .frame(width: 40, height: 40)
      .foregroundStyle(.black)
  }
  
  private var infoView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(Font.system(size: 20, weight: .bold))
        .foregroundStyle(Color.black)
        .multilineTextAlignment(.leading)
      
      Text(description)
        .font(Font.system(size: 16, weight: .regular))
        .foregroundStyle(Color.black)
        .multilineTextAlignment(.leading)
    }
  }
  
}

#Preview {
  ItemRow(
    image: Image(systemName: "qrcode"),
    title: "QR code title",
    description: "QR code description"
  )
  .padding()
}
