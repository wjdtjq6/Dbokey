//
//  TargetType.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation
import Alamofire

protocol TargetType: URLRequestConvertible {
    var baseUrl: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var header: [String:String] { get }
    var parameter: String? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
}
extension TargetType {
    func asURLRequest() throws -> URLRequest {
        let url = try baseUrl.asURL()
        var request = try URLRequest(url: url.appendingPathComponent(path), method: method)
        request.allHTTPHeaderFields = header
        request.httpBody = body
        //request.httpBody = parameters?.data(using: .utf8)
        return request
    }
}
