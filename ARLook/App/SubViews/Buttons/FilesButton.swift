//
//  FilesButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct FilesButton: View {

//  @EnvironmentObject var appModel: AppDataModel
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
      Image(systemName: "folder")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 22)
        .foregroundStyle(.white)
        .padding(20)
        .background(Material.regular)
        .clipShape(Circle())
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
