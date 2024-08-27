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
    //var parameter: String? { get }
    var parameter: Parameters? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
}
extension TargetType {
    func asURLRequest() throws -> URLRequest {
        let url = try baseUrl.asURL().appendingPathComponent(path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems

        var request = URLRequest(url: urlComponents?.url ?? url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = header
        request.httpBody = body

        if let parameters = parameter {
            request = try URLEncoding.default.encode(request, with: parameters)
        }

        return request
    }
}
