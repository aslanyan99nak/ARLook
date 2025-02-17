//
//  FeedbackView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import Foundation
import SwiftUI

struct FeedbackView: View {
  
  @ObservedObject var messageList: TimedMessageList

  var body: some View {
    VStack {
      if let activeMessage = messageList.activeMessage {
        Text(activeMessage.message)
          .dynamicFont(weight: .bold)
          .foregroundStyle(.white)
          .environment(\.colorScheme, .dark)
          .transition(.opacity)
      }
    }
  }
  
}
