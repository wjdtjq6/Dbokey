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
        let likeTap: Observable<Bool>
    }
    struct Output {
        //탭한 결과 = 통신 응답
        let list: Observable<ViewPostModel>//BehaviorSubject<ViewPostModel>
        let likeList: BehaviorSubject<likeModel>
        let categories: Observable<[Category]>
//        let select: ControlEvent<Category>
    }
    func transform(input: Input) -> Output {
        let categories = BehaviorSubject(value: categories)
        let likeList = BehaviorSubject(value: likeData)
        //like가 true면 false, false면 true로 근데 없으면 true로!
        input.likeTap
            .bind { row in
                var likeListValue = try! likeList.value()
                if likeListValue.like_status.description.isEmpty {
                    likeListValue.like_status = true
                    self.likeData.like_status = true
                } else {
                    likeListValue.like_status.toggle()
                    self.likeData.like_status.toggle()
                    likeList.onNext(likeListValue)
                }

            }
            .disposed(by: disposeBag)
        //select하면 통신!
        let listObservable = input.select
            .flatMapLatest { item in
                NetworkManager.viewPost(next: "", limit: "1", productID: "\(item.productId)")
                    .catch { error in
                        print(error.localizedDescription)
                        return Single.just(ViewPostModel(data: [], next_cursor: ""))
                    }
                    .debug("체크1")
                    //.map {$0.data}
                    .asObservable()
            }
            .debug("체크2")
//            .subscribe(onNext: { newData in
//                self.list.onNext(newData)
//            })
//            .disposed(by: disposeBag)
            .share(replay: 1, scope: .whileConnected)
        return Output(list: listObservable, likeList: likeList, categories: categories)
    }
}
