//
//  MainViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/19/24.
//

import Foundation
import RxSwift
import RxCocoa

struct Category {
    let productId : String
    let title : String
}

class MainViewModel {
    let disposeBag = DisposeBag()
    //BottomCollectionView Data
    private var data = ViewPostModel(data: [], next_cursor: "")
    private lazy var list = BehaviorSubject(value: data)
//    
    private var likeData = likeModel(like_status: false)
    private lazy var likeList = BehaviorSubject(value: likeData)
    //TopCollectioView Data
    private var categories = [
        Category(productId: "dbokey_market_made", title: "기성품 키보드"),
        Category(productId: "dbokey_market_custom", title: "커스텀 키보드"),
        Category(productId: "dbokey_market_keycap", title:  "키캡"),
        Category(productId: "dbokey_market_artisan", title: "아티산"),
        Category(productId: "dbokey_market_switch", title: "스위치"),
        Category(productId: "dbokey_market_etc", title: "기타"),
        
    ]
    struct Input {
        //카테고리 선택하면 통신해야하고, 좋아요버튼 누르면 저장
        let select: ControlEvent<Category>
        let likeTap: Observable<String>
    }
    struct Output {
        //탭한 결과 = 통신 응답
        let list: Observable<ViewPostModel>//BehaviorSubject<ViewPostModel>
        //let likeList: BehaviorSubject<likeModel>
        let categories: Observable<[Category]>
//        let select: ControlEvent<Category>
    }
    func transform(input: Input) -> Output {
            let categories = Observable.just(self.categories)
            
            let listObservable = input.select
                .flatMapLatest { item in
                    NetworkManager.viewPost(next: "", limit: "10", productID: item.productId)
                        .asObservable()
                        .catch { error in
                            print(error.localizedDescription)
                            return Observable.just(ViewPostModel(data: [], next_cursor: ""))
                        }
                }
                .share(replay: 1, scope: .whileConnected)

            input.likeTap
                .withLatestFrom(listObservable) { (postID, viewPostModel) -> (String, ViewPostModel) in
                    return (postID, viewPostModel)
                }
                .debug("체크1")
                .flatMapLatest { postID, viewPostModel in
                    let post = viewPostModel.data.first { $0.post_id == postID }
                    let currentLikeStatus = post?.likes.contains(UserDefaults.standard.string(forKey: "user_id")) ?? false
                    print(currentLikeStatus,"ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ")
                    return NetworkManager.likePost(postID: postID, like_status: !currentLikeStatus)
                        .asObservable()
                        .map { _ in viewPostModel }
                }
                .debug("체크2")
                .subscribe(with: self, onNext: { owner, updateModel in
                    owner.list.onNext(updateModel)
                    print(updateModel,"ㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴ")
                })
                .disposed(by: disposeBag)

            return Output(list: listObservable, categories: categories)
        }}
