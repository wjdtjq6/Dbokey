//
//  Router.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation
import Alamofire

enum Router {
    //회원인증
    case join(query: JoinQuery)
    case emailCheck(query: emailCheckQuery)
    case login(query: LoginQuery)
    case refresh
    case withdraw
    //포스트(게시글)
    case uploadFiles
    case writePost(query: writeEditPostQuery)
    case viewPost(next: String, limit: String, productId: String, productId1: String, productId2: String, productId3: String, productId4: String, productId5: String)//전체
    case viewPost2(next: String, limit: String, productId: String)//나머지
    case idPost(postID: String)
    case editPost(query: writeEditPostQuery, postID: String)
    case deletePost(postID: String)
    case usersPost(userID: String)
    //댓글(코멘트)
    case writeComments(query: writeEditCommentsQuery, postID: String)
    case editComments(query: writeEditCommentsQuery, postID: String, commentID: String)
    case deleteComments(postID: String, commentID: String)
    //좋아요(Like)
    case likePost(postID: String, query: likePostQuery)
    case viewLikePost
    //좋아요2(Like2) => 거래완료판별
    case like2Post(postID: String)
    case viewLike2Post
    //profile
    case viewProfile
    case editProfile(query: editProfileQuery)
    case viewAnotherProfile(userID: String)
}
extension Router: TargetType {
    var parameter: Alamofire.Parameters? {
        switch self {
        default:
            return nil
        }
    }
    var baseUrl: String {
        return APIKey.BaseURL + "v1"
    }
    var method: Alamofire.HTTPMethod {
        switch self {
        case .join, .emailCheck, .login, .uploadFiles, .writePost, .writeComments, .likePost, .like2Post:
            return .post
        case .refresh, .withdraw, .viewPost, .viewPost2, .idPost, .usersPost, .viewLikePost, .viewLike2Post, .viewProfile, .viewAnotherProfile:
            return .get
        case .editPost, .editComments, .editProfile:
            return .put
        case .deletePost, .deleteComments:
            return .delete
        }
    }
    var queryItems: [URLQueryItem]? {
        switch self {
        case .viewPost(let next, let limit, let productId, let productId1, let productId2, let productId3, let productId4, let productId5):
            return [
                URLQueryItem(name: "next", value: next),
                URLQueryItem(name: "limit", value: limit),
                URLQueryItem(name: "product_id", value: productId),
                URLQueryItem(name: "product_id", value: productId1),
                URLQueryItem(name: "product_id", value: productId2),
                URLQueryItem(name: "product_id", value: productId3),
                URLQueryItem(name: "product_id", value: productId4),
                URLQueryItem(name: "product_id", value: productId5)
            ]
        case .viewPost2(let next, let limit, let productId):
            return [
                URLQueryItem(name: "next", value: next),
                URLQueryItem(name: "limit", value: limit),
                URLQueryItem(name: "product_id", value: productId)
            ]
        default:
            return nil
        }
    }
    var body: Data? {
        switch self {
            /*
        case .editPost(let query,let postID):
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                print("게시글 수정 데이터: \(data)")
                return data
            } catch {
                print(error)
                return nil
            }
             */
        case .writePost(let query):
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                print("게시글 업로드 데이터: \(data)")
                return data
            } catch {
                print(error)
                return nil
            }
        case .likePost(_, let query):
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                print("좋아요 데이터: \(data)")
                return data
            } catch {
                print(error)
                return nil
            }
        case .join(let query):
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                print("회원가입 데이터: \(data)")
                return data
            } catch {
                print(error)
                return nil
            }
        case .emailCheck(let query):
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                print("이메일 중복 확인 데이터: \(data)")
                return data
            } catch {
                print(error)
                return nil
            }
        case .login(let query):
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                print("로그인 데이터: \(data)")
                return data
            } catch {
                print(error)
                return nil
            }
        case .writeComments(let query,let postID):
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                print("작성한 댓글 데이터: \(data)")
                return data
            } catch {
                print(error)
                return nil
            }
        case .editComments(let query, let postID, let commentID):
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                print("수정한 댓글 데이터: \(data)")
                return data
            } catch {
                print(error)
                return nil
            }
//        case .like2Post(let query,let postID):
//            let encoder = JSONEncoder()
//            do {
//                let data = try encoder.encode(query)
//                print("게시글 좋아요2 true or false 데이터: \(data)")
//                return data
//            } catch {
//                print(error)
//                return nil
//            }
        case .editProfile(let query):
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                print("댓글 수정 데이터: \(data)")
                return data
            } catch {
                print(error)
                return nil
            }
        default: return nil
        }
    }
    var path: String {
        switch self {
        case .join:
            return "/users/join"
        case .emailCheck:
            return "validation/email"
        case .login:
            return "/users/login"
        case .refresh:
            return "/auth/refresh"
        case .withdraw:
            return "/users/withdraw"
        case .uploadFiles:
            return "/posts/files"
        case .writePost ,.viewPost,.viewPost2:
            return "/posts"
        case .idPost(let postID):
            return "/posts/\(postID)"
        case .editPost(let postID):
            return "/posts/\(postID)"
        case .deletePost(let postID):
            return "/posts/\(postID)"
        case .usersPost(let userID):
            return "/users/\(userID)"
        case .writeComments(_, let postID):
            return "/posts/\(postID)/comments"
        case .editComments(_, let postID, let commentID):
            return "/posts/\(postID)/comments/\(commentID)"
        case .deleteComments(let postID, let commentID):
            return "/posts/\(postID)/comments/\(commentID)"
        case .likePost(let postID, _):
            return "/posts/\(postID)/like"
        case .viewLikePost:
            return "posts/likes/me"
        case .like2Post(let postID):
            return "posts/\(postID)/like-2"
        case .viewLike2Post:
            return "posts/likes-2/me"
        case .viewProfile, .editProfile:
            return "/users/me/profile"
        case .viewAnotherProfile(let userID):
            return "/users/\(userID)/profile"
        }
    }
    var header: [String : String] {
        switch self {
        case .join, .emailCheck, .login, .usersPost:
            return [
                Header.contentType.rawValue: Header.json.rawValue,
                Header.sesacKey.rawValue: APIKey.SesacKey
            ]
        case .uploadFiles, .editProfile:
            return [
                Header.contentType.rawValue: Header.multipart.rawValue,
                Header.sesacKey.rawValue: APIKey.SesacKey
            ]
        case .withdraw, .viewPost, .viewPost2, .deletePost, .idPost, .viewLikePost, .viewLike2Post, .viewProfile, .viewAnotherProfile, .refresh, .writePost, .editPost, .editComments,.writeComments, .deleteComments, .likePost ,.like2Post://follow, cancleFollow hashTags
            return [
                Header.authorization.rawValue: UserDefaultsManager.shared.token,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.sesacKey.rawValue: APIKey.SesacKey
            ]
        }
    }
}
