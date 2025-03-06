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
    case .production: "http://192.168.11.212:8080/v1"
    case .development: "http://192.168.11.212:8080/v1"
    case .local: "http://192.168.11.212:8080/v1"
    }
  }
  
}
