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
        let listObservable = NetworkManager.usersPost(userID: UserDefaultsManager.shared.user_id, next: "", limit: "9999999999999999")
            .asObservable()
            .catch { error in
                print(error.localizedDescription)
                return Observable.just(ViewPostModel(data: [], next_cursor: ""))
            }
            .map { $0.data }
            .share(replay: 1, scope: .whileConnected)

        input.likeTap
            .flatMapLatest { postId -> Observable<likeModel> in
                return Observable.create { observer in
                    NetworkManager.likePost(postID: postId, like_status: true) { result in
                        switch result {
                        case .success(let model):
                            observer.onNext(model)
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            }
            .subscribe(onNext: { [weak self] model in
                self?.likeList.onNext(model)
            })
            .disposed(by: disposeBag)

        return Output(list: listObservable, likeList: likeList, selectCell: input.selectCell)
    }
}
