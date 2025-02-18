//
//  FilesButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct FilesButton: View {

  @State private var showDocumentBrowser = false
  @Binding var selectedURL: URL?

  var body: some View {
    Button {
      print("Files button clicked!")
      let fileManager = FileManager.default
      if let testDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        print("Test Directory: \(testDir)")
        showDocumentBrowser = true
      }
    } label: {
      Image(systemName: Image.folder)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 32, height: 32)
        .foregroundStyle(.white)
    }
    .sheet(isPresented: $showDocumentBrowser) {
      DocumentPicker { url in
        selectedURL = url
        if let selectedURL {
          print("Selected URL: \(selectedURL)")
        }
      }
    }
  }

}

#Preview {
  FilesButton(selectedURL: .constant(nil))
}
