//
//  ModelsListScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct ModelsListScreen: View {
  
  let modelManager = ModelManager.shared
  
  var body: some View {
    fileNames
  }
  
  private var fileNames: some View {
    VStack(alignment: .leading, spacing: 10) {
      let files = modelManager.loadFiles()
//      let files = modelManager.mockFiles
      if !files.isEmpty {
        HStack(spacing: 0) {
          Text("Existing Models")
            .foregroundStyle(.black)
            .font(.title)
            .fontWeight(.bold)
            .padding()

          Spacer()
        }
      }

      ForEach(files, id: \.self) { file in
        HStack(spacing: 0) {
          Text(file)
            .foregroundStyle(.black)
            .padding()
            .background(Color.gray.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 8))

          Spacer()
        }
        .padding(.horizontal, 16)
      }
      
      Spacer()
    }
    .padding(.bottom, 40)
  }
  
}

#Preview {
  ModelsListScreen()
}
