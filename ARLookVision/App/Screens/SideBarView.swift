//
//  SideBarView.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
//

import SwiftUI

enum SideMenuItem: String, Identifiable, CaseIterable {

  var id: String {
    self.rawValue
  }

  case upload
  case qrCodeScanner
  case importQR
  case file
  case view3DMode
  case lookAround

  var icon: Image {
    switch self {
    case .upload: Image(systemName: Image.upload)
    case .qrCodeScanner: Image(systemName: Image.qrCodeScanner)
    case .importQR: Image(systemName: Image.qrCode)
    case .file: Image(.openFile)
    case .view3DMode: Image(systemName: Image.arkit)
    case .lookAround: Image(systemName: Image.eye)
    }
  }

  var title: String {
    switch self {
    case .upload: LocString.upload
    case .qrCodeScanner: LocString.qrCodeScannerTitle
    case .importQR: LocString.importQRTitle
    case .file: LocString.fileManagmentTitle
    case .view3DMode: LocString.view3DMode
    case .lookAround: LocString.lookAroundTitle
    }
  }

  var description: String {
    switch self {
    case .upload: LocString.uploadDescription
    case .qrCodeScanner: LocString.qrCodeScannerDescription
    case .importQR: LocString.importQRDescription
    case .file: LocString.fileManagmentDescription
    case .view3DMode: LocString.viewModelDescription
    case .lookAround: LocString.lookAroundDescription
    }
  }

}

struct SideBarView: View {

  @Binding var selectedItem: SideMenuItem?
  @Binding var sideMenuItems: [SideMenuItem]  

  var body: some View {
    List(sideMenuItems) { item in
      Button {
        selectedItem = item
      } label: {
        HStack(spacing: 16) {
          item.icon
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32)
            .foregroundStyle(.white)
          
          Text(item.title)
        }
        .padding(.horizontal, 16)
        .padding()
        .hoverEffect(ScaleHoverEffect())
      }
      .buttonStyle(PlainButtonStyle())
    }
  }

}

#Preview {
  SideBarView(
    selectedItem: .constant(nil),
    sideMenuItems: .constant([])
  )
}
