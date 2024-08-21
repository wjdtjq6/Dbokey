//
//  LoginQuery.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation
//회원인증
struct LoginQuery: Encodable {
    let email: String
    let password: String
}
struct JoinQuery: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String
    let birthDay: String
}
struct emailCheckQuery: Encodable {
    let email: String
}
//포스트(게시글)
struct uploadFilesQuery: Encodable {
    let files: Data
}
struct writeEditPostQuery: Encodable {
    let title: String
    let content: String
    let content1: String
    let content2: String
    let content3: String
    let content4: String
    let product_id: String
    let files: [String]
}
//댓글(코멘트)
struct writeEditCommentsQuery: Encodable {
    let content: String
}
//좋아요(Like1,2)
struct likePostQuery: Encodable {
    let like_status: Bool
}

//profile
struct editProfileQuery: Encodable {
    let nick: String
    let phoneNum: String
    let birthDay: String
    let profile: Data
}
