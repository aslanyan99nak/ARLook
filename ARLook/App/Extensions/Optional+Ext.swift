//
//  Optional+Ext.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//


extension Optional {
  
  var isNil: Bool { self == nil }
  
  var isNotNil: Bool { !isNil }
  
}
