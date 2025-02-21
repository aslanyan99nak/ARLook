//
//  NetworkProvider.swift
//  ARLook
//
//  Created by Narek on 17.02.25.
//

import Alamofire
import Combine
import CombineMoya
import Foundation
import Moya

final class Provider<T>: MoyaProvider<T> where T: MultiTargetType {
  typealias Target = T

  init() {
    super.init(
      endpointClosure: MoyaProvider.defaultEndpointMapping,
      requestClosure: MoyaProvider<Target>.defaultRequestMapping,
      stubClosure: MoyaProvider.neverStub,
      session: NetworkConfiguration.sessionManager,
      plugins: [NetworkActivityPlugin(
        networkActivityClosure: NetworkConfiguration.networkActivityIndicator),
      NetworkConfiguration.networkLogger],
      trackInflights: false)
  }

  func request<C>(_ target: Target) async throws -> C where C: Codable {
    return try await withCheckedThrowingContinuation { continuation in
      self.request(target) { result in
        switch result {
        case let .success(response):
          do {
            let data = try response.map(C.self)
            continuation.resume(returning: data)
          } catch {
            continuation.resume(throwing: error)
          }
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func downloadRequest(_ target: Target) async throws -> AsyncThrowingStream<ProgressResponse, Error> {
    AsyncThrowingStream { continuation in
      self.request(
        target,
        progress: { progress in
          continuation.yield(progress)
        },
        completion: { result in
          switch result {
          case let .success(response):
            print("Response: \(response)")
            continuation.finish()
          case let .failure(error):
            continuation.finish(throwing: error)
          }
        })
    }
  }
}
