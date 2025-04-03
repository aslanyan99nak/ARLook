//
//  Env.swift
//  ARLook
//
//  Created by Narek on 17.02.25.
//


enum Env: String {
  
  case production
  case development
  case local

  var baseURL: String {
    switch self {
    case .production: "http://192.168.11.64:8080"
    case .development: "http://192.168.11.64:8080"
    case .local: "http://192.168.11.64:8080"
    }
  }
  
}
