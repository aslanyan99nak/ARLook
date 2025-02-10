//
//  Show3DCardView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import SwiftUI

struct Show3DCardView: View {
  
  var body: some View {
    HStack(spacing: 0) {
      cardLeftSideView
      Spacer()
      
      Image(.rocket)
        .resizable()
        .frame(width: 100, height: 100)
      
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 8)
        .foregroundStyle(.white)
    )
    .compositingGroup()
    .shadow(color: .black, radius: 10, x: 10, y: 10)
    .padding()
  }
  
  private var cardLeftSideView: some View {
    VStack(spacing: 8) {
      Text("View in 3D mode")
        .font(Font.system(size: 24, weight: .bold))
        .foregroundStyle(Color.black)
      
      HStack(spacing: 0) {
        Image(systemName: "cube")
          .resizable()
          .frame(width: 60, height: 60)
          .foregroundStyle(.black)
        
        Spacer()
      }
      .padding()
    }
  }

}

#Preview {
  Show3DCardView()
}
