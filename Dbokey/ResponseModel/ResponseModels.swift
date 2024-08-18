//
//  ResponseModels.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation

struct emailCheckModel: Decodable {
    let message: String
}
struct SignModel: Decodable {
    let id: String
    let email: String
    let nick: String
    let profile: String?
    let access: String?
    let refresh: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email,nick
        case profile = "profileImage"
        case access = "accessToken"
        case refresh = "refreshToken"
    }
}
struct RefreshModel: Decodable {
    let accessToken: String
}
struct FilesModel: Decodable {
    let files: [String]
}
