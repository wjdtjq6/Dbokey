//
//  ResponseModels.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation

struct uploadFilesModel: Decodable {
    let files: [String]
}

struct likeModel: Decodable {
    var like_status: Bool
}

struct ViewPostModel: Decodable {
    var data: [PostData]
    let next_cursor: String
}
struct PostData: Decodable {
    let post_id: String
    let product_id: String?
    let title: String?
    let content: String?
    let content1: String?
    let content2: String?
    let content3: String?
    let content4: String?
    //let content5: String?
    let createdAt: String
    let creator: Creator
    let files: [String?]
    var likes: [String?]
    var likes2: [String?]
    //let buyers: [String?]
    //let hashTages: [String?]
    let comments: [Comments?]
}
struct Creator: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String?
}
struct Comments: Decodable {
    let comment_id: String
    let content: String
    let createdAt: String
    let creator: Creator
}

struct EmailCheckModel: Decodable {
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
