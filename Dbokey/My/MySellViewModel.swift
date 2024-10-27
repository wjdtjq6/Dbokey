//
//  MySellViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/30/24.
//

import Foundation
import RxSwift
import RxCocoa

class MySellViewModel {
    let disposeBag = DisposeBag()
    private var likeData = likeModel(like_status: false)
    private lazy var likeList = BehaviorSubject(value: likeData)

    struct Input {
        let likeTap: Observable<String>
        let selectCell: ControlEvent<IndexPath>
    }

    struct Output {
        let list: Observable<[PostData]>
        let likeList: BehaviorSubject<likeModel>
        let selectCell: ControlEvent<IndexPath>
    }

    func transform(input: Input) -> Output {
        // 게시글 목록 조회
        let listObservable = NetworkManager.usersPost(
            userID: UserDefaultsManager.shared.user_id,
            next: "",
            limit: "9999999999999999"
        )
        .asObservable()
        .catch { error in
            print("게시글 조회 실패:", error.localizedDescription)
            return .just(ViewPostModel(data: [], next_cursor: ""))
        }
        .map { $0.data }
        .share(replay: 1, scope: .whileConnected)

        // 좋아요 처리
        input.likeTap
            .flatMapLatest { [weak self] postId -> Observable<likeModel> in
                guard let self = self else {
                    return .error(NetworkError.unknown)
                }
                
                return NetworkManager.likePost(postID: postId, like_status: true)
                    .asObservable()
                    .catch { error in
                        print("좋아요 처리 실패:", error.localizedDescription)
                        return .empty()
                    }
            }
            .bind(to: likeList)
            .disposed(by: disposeBag)

        return Output(
            list: listObservable,
            likeList: likeList,
            selectCell: input.selectCell
        )
    }
}
