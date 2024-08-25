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
    var category = ""
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
        let selectCell: ControlEvent<IndexPath>
    }
    struct Output {
        //탭한 결과 = 통신 응답
        let list: Observable<ViewPostModel>
        let likeList: BehaviorSubject<likeModel>
        let categories: Observable<[Category]>
        let selectCell: ControlEvent<IndexPath>
        let selectedCategoryTitle: Observable<String> // 카테고리 제목을 전달할 Observable
    }
    func transform(input: Input) -> Output {
        input.selectCell
            .subscribe(with: self) { owner, _ in
            }
            .disposed(by: disposeBag)
        
        let categories = Observable.just(self.categories)
        //카테고리 제목 전달
        let selectedCategoryTitle = input.select
            .map { $0.title }
        
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
/*
    //MARK: 좋아요 버튼 기능 되도록 할 것(인섬니아로 바꿔놓으면 보이긴함)
        input.likeTap
            .withLatestFrom(listObservable) { (postID, viewPostModel) -> (String, ViewPostModel) in
                return (postID, viewPostModel)
            }
            .debug("체크1")
            .flatMapLatest { postID, viewPostModel -> Observable<ViewPostModel> in
                // 선택된 게시글을 찾습니다.
                guard let post = viewPostModel.data.first(where: { $0.post_id == postID }) else {
                    return Observable.just(viewPostModel)
                }
                
                // 현재 좋아요 상태를 확인합니다.
                let userId = UserDefaults.standard.string(forKey: "id") ?? ""
                print(userId,"현재 id")
                let currentLikeStatus = post.likes.contains(userId)
                print(currentLikeStatus, "현재 좋아요 상태") // 디버깅용 출력

                // 좋아요 상태를 변경하는 네트워크 요청
                return NetworkManager.likePost(postID: "1", like_status: !currentLikeStatus)
                    .asObservable()
                    .catch { error in
                        print(error.localizedDescription)
                        return Observable.just(likeModel(like_status: currentLikeStatus))
                    }
                    .map { _ in viewPostModel } // 여기서 반환된 likeModel을 이용해 새 ViewPostModel을 생성하지 않음, 원래 모델 그대로 반환
            }
            .debug("체크2")
            .subscribe(with: self, onNext: { owner, updateModel in
                print(updateModel,"나를 찾아봐...")
                owner.list.onNext(updateModel)
            })
            .disposed(by: disposeBag)
*/
        return Output(list: listObservable, likeList: likeList, categories: categories, selectCell: input.selectCell, selectedCategoryTitle: selectedCategoryTitle)
        }}
