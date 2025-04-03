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

  case objectScanner
  case upload
  //  case qrCodeScanner
  case importQR
  case file
  case view3DMode
  case lookAround

  var icon: Image {
    switch self {
    case .objectScanner: Image(systemName: Image.visionPro)
    case .upload: Image(.upload)
    //    case .qrCodeScanner: Image(systemName: Image.qrCodeScanner)
    case .importQR: Image(systemName: Image.qrCode)
    case .file: Image(.openFile)
    case .view3DMode: Image(systemName: Image.arkit)
    case .lookAround: Image(systemName: Image.eye)
    }
  }

  var title: String {
    switch self {
    case .objectScanner: ""
    case .upload: LocString.upload
    //    case .qrCodeScanner: LocString.qrCodeScannerTitle
    case .importQR: LocString.importQRTitle
    case .file: LocString.fileManagmentTitle
    case .view3DMode: LocString.view3DMode
    case .lookAround: LocString.lookAroundTitle
    }
  }

  var description: String {
    switch self {
    case .objectScanner: ""
    case .upload: LocString.uploadDescription
    //    case .qrCodeScanner: LocString.qrCodeScannerDescription
    case .importQR: LocString.importQRDescription
    case .file: LocString.fileManagmentDescription
    case .view3DMode: LocString.viewModelDescription
    case .lookAround: LocString.lookAroundDescription
    }
  }

}

struct SideBarView: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue

  @Binding var selectedItem: SideMenuItem?
  @Binding var sideMenuItems: [SideMenuItem]

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 16) {
        ForEach(sideMenuItems) { item in
          Button {
            selectedItem = item
          } label: {
            if item == .objectScanner {
              objectScannerContent
            } else {
              makeItemContent(item)
            }
          }
          .buttonStyle(.plain)
          .padding(.horizontal, 16)
        }
      }
    }
  }

  private func makeItemContent(_ item: SideMenuItem) -> some View {
    HStack(spacing: 16) {
      item.icon
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 32)
        .foregroundStyle(accentColorType.color)

      Text(item.title)

      Spacer()
    }
    .padding(.horizontal, 16)
    .frame(height: 80)
    .scaleHoverEffect(scale: 1.05)
  }

  var objectScannerContent: some View {
    SideMenuItem.objectScanner.icon
      .renderingMode(.template)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 100)
      .foregroundStyle(accentColorType.color)
      .padding(.horizontal, 16)
      .padding()
      .frame(height: 80)
      .scaleHoverEffect(scale: 1.05)
  }

}

#Preview {
  SideBarView(
    selectedItem: .constant(.objectScanner),
    sideMenuItems: .constant(SideMenuItem.allCases)
  )
}
