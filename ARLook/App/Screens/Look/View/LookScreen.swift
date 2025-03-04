//
//  LookScreen.swift
//  ARLook
//
//  Created by Narek on 21.02.25.
//

import ARKit
import Combine
import FocusEntity
import RealityKit
import SwiftUI

struct LookScreen: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @StateObject private var searchViewModel = SearchViewModel()
  @StateObject private var viewModel = LookViewModel()
  @Environment(\.colorScheme) var colorScheme

  private let arView = ARView(frame: .zero)

  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  var body: some View {
    ZStack {
      ARViewContainer(
        fileURL: $viewModel.fileURL,
        focusEntity: $viewModel.focusEntity,
        isLoading: $viewModel.isLoading,
        arView: arView
      )
      .edgesIgnoringSafeArea(.all)

      overlayContent
    }
    .toolbar(.hidden, for: .tabBar)
    .sheet(isPresented: $viewModel.isShowPicker) {
      MenuScreen(
        isShowPicker: $viewModel.isShowPicker,
        fileURL: $viewModel.fileURL,
        selectedModel: $viewModel.selectedModel
      )
    }
  }

  private var overlayContent: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Spacer()

        if let selectedModel = viewModel.selectedModel, viewModel.isShowSelectedModel {
          ModelItemView(isList: .constant(false), model: selectedModel)
            .frame(width: 150, height: viewModel.isShowSelectedModel ? 200 : 40)
            .padding(.trailing, 8)
        }

        horizontalExpandButton
          .padding(.trailing, 16)
      }
      .padding(.top, 50)

      Spacer()

      HStack(spacing: 0) {
        Spacer()
        buttonsStack
          .padding(.trailing, 16)
      }

      snapShotButton
        .padding(.bottom, 20)
    }
  }

  private var buttonsStack: some View {
    VStack(spacing: 16) {
      VStack(spacing: 16) {
        deleteEntityButton
        cursorEnableButton
        focusEntityEnableButton
        resetButton
        addButton
          .disabled(viewModel.isLoading || viewModel.selectedModel.isNil)
        folderButton
      }
      .padding(.vertical, 8)
      .background(.black.opacity(0.3))
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .frame(maxHeight: viewModel.isShowButtonsStack ? .infinity : 0)
      .opacity(viewModel.isShowButtonsStack ? 1 : 0)
      .offset(y: viewModel.isShowButtonsStack ? 0 : 140)
      .animation(.easeInOut(duration: 0.5), value: viewModel.isShowButtonsStack)

      if !viewModel.isShowButtonsStack {
        Spacer()
      }
      verticalExpandButton
    }
    .frame(width: 40, height: 264)
  }

  private var cursorEnableButton: some View {
    Button {
      // Action
      NotificationCenter.default.post(name: .toggleArrowVisibility, object: nil)
    } label: {
      Image(systemName: viewModel.isShowSelected ? "cursorarrow.slash" : "cursorarrow")
        .renderingMode(.template)
        .resizable()
        .frame(width: 24, height: 24)
        .foregroundStyle(accentColorType.color)
        .padding(8)
    }
    .onReceive(NotificationCenter.default.publisher(for: .showSelected)) { notification in
      if let isShow = notification.object as? Bool {
        viewModel.isShowSelected = isShow
      }
    }
  }
  
  private var deleteEntityButton: some View {
    Button {
      // Action
      NotificationCenter.default.post(name: .deleteSelectedEntity, object: nil)
    } label: {
      Image(systemName: "square.3.stack.3d.slash")
        .renderingMode(.template)
        .resizable()
        .frame(width: 24, height: 24)
        .foregroundStyle(accentColorType.color)
        .padding(8)
    }
  }

  private var focusEntityEnableButton: some View {
    Button {
      viewModel.isFocusEntityEnabled.toggle()
      viewModel.focusEntity?.isEnabled = viewModel.isFocusEntityEnabled
    } label: {
      Image(systemName: viewModel.isFocusEntityEnabled ? Image.rectangleSlash : Image.rectangle)
        .renderingMode(.template)
        .resizable()
        .frame(width: 24, height: 24)
        .foregroundStyle(accentColorType.color)
        .padding(8)
    }
  }

  private var resetButton: some View {
    Button {
      NotificationCenter.default.post(name: .reset, object: nil)
    } label: {
      Image(systemName: Image.reset)
        .renderingMode(.template)
        .resizable()
        .frame(width: 24, height: 24)
        .foregroundStyle(accentColorType.color)
        .padding(8)
    }
  }

  private var addButton: some View {
    Button {
      NotificationCenter.default.post(name: .placeModel, object: nil)
    } label: {
      if viewModel.isLoading {
        CircularProgressView(tintColor: accentColorType.color)
      } else {
        Image(systemName: Image.plus)
          .renderingMode(.template)
          .resizable()
          .frame(width: 24, height: 24)
          .foregroundStyle(viewModel.isLoading || viewModel.selectedModel.isNil ? .gray : accentColorType.color)
          .padding(8)
      }
    }
  }

  private var folderButton: some View {
    Button {
      viewModel.isShowPicker = true
    } label: {
      Image(systemName: Image.folder)
        .renderingMode(.template)
        .resizable()
        .frame(width: 24, height: 24)
        .foregroundStyle(accentColorType.color)
        .padding(8)
    }
  }

  private var snapShotButton: some View {
    Button {
      NotificationCenter.default.post(name: .snapshot, object: nil)
    } label: {
      // Image(systemName: Image.snapshot2)
      Image(systemName: Image.snapshot)
        .renderingMode(.template)
        .resizable()
        .frame(width: 60, height: 60)
        .background(.black.opacity(0.3))
        .foregroundStyle(accentColorType.color)
        .clipShape(Circle())
    }
  }

  private var horizontalExpandButton: some View {
    Button {
      if viewModel.selectedModel.isNotNil {
        withAnimation(.easeInOut(duration: 0.3)) {
          viewModel.isShowSelectedModel.toggle()
        }
      }
    } label: {
      VStack(spacing: 0) {
        Spacer()
        Image(systemName: Image.chevronForward)
          .renderingMode(.template)
          .resizable()
          .frame(width: 8, height: 24)
          .padding(16)
          .background(.black.opacity(0.3))
          .foregroundStyle(accentColorType.color)
          .clipShape(Circle())
          .rotationEffect(.radians(viewModel.isShowSelectedModel ? 0 : .pi))
        Spacer()
      }
      .frame(height: 200)
    }
  }

  private var verticalExpandButton: some View {
    Button {
      viewModel.isShowButtonsStack.toggle()
    } label: {
      Image(systemName: Image.chevronDown)
        .renderingMode(.template)
        .resizable()
        .frame(width: 24, height: 8)
        .padding(16)
        .background(.black.opacity(0.3))
        .foregroundStyle(accentColorType.color)
        .clipShape(Circle())
        .rotationEffect(.radians(viewModel.isShowButtonsStack ? 0 : .pi))
    }
  }

}

#Preview {
  LookScreen()
}
