//
//  FilesButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct FilesButton: View {

  @EnvironmentObject var appModel: AppDataModel
  @State private var showDocumentBrowser = false

  var body: some View {
    Button {
      print("Files button clicked!")
      showDocumentBrowser = true
      // Test opening document picker with a fixed, known-good directory
      let fileManager = FileManager.default
      if let testDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        print("Test Directory: \(testDir)")
      }
    } label: {
      Image(systemName: "folder")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 22)
        .foregroundStyle(.white)
    }
    .sheet(isPresented: $showDocumentBrowser) {
      // Test DocumentBrowser with a fixed directory
      DocumentBrowser(
        startingDir: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      )
    }
  }

}
