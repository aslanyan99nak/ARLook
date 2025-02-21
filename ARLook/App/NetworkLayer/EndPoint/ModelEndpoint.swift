//
//  ModelEndpoint.swift
//  ARLook
//
//  Created by Narek on 17.02.25.
//

import Moya

enum ModelEndpoint {
  
  case getList
  case upload(Bool)
  
}

extension ModelEndpoint: MultiTargetType {
  
  var path: String {
    switch self {
    case .getList: "/files/list"
    case .upload: "/files/upload"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .getList: .get
    default: .post
    }
  }

  var parameters: Parameter {
    switch self {
    case let .upload(isOnline):
      return ["is_online": isOnline]
    default: return [:]
    }
  }

  private var headers: Header {
    switch self {
    case .getList: [:]
    default: [:]
    }
  }

  var task: Task {
    switch self {
    case .getList: .requestParameters(parameters: parameters, encoding: URLEncoding())
    default: .requestParameters(parameters: parameters, encoding: JSONEncoding())
    }
  }
  
}
