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
    let title: String//제목
    let content: String//내용
    let content1: String//브랜드명
    let content2: String//장소
    let content3: String//중고용품or새상품
    let price: Int//가격
    let product_id: String//카테고리
    let files: [String]//이미지
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
