//
//  MainViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/19/24.
//

import Foundation
import RxSwift
import RxCocoa
enum CategoryItem {
    case category(Category)
    case category2(Category2)

    var title: String {
        switch self {
        case .category(let category):
            return category.title
        case .category2(let category2):
            return category2.title
        }
    }
}
struct Category {
    let productId: String
    let productId1: String
    let productId2: String
    let productId3: String
    let productId4: String
    let productId5: String

    let title : String
}
struct Category2 {
    let productId: String
    let title: String
}

class MainViewModel {
    let disposeBag = DisposeBag()

    private var likeData = likeModel(like_status: false)
    private lazy var likeList = BehaviorSubject(value: likeData)
    
    //TopCollectioView Data
    
    private let categories: [CategoryItem] = [
        .category(Category(productId: "dbokeyt_made", productId1: "dbokey_custom",productId2: "dbokey_keycap", productId3: "dbokey_artisan",productId4: "dbokey_switch",productId5: "dbokey_etc",title: "전체")),
        .category2(Category2(productId: "dbokeyt_made", title: "기성품 키보드")),
        .category2(Category2(productId: "dbokey_custom", title: "커스텀 키보드")),
        .category2(Category2(productId: "dbokey_keycap", title: "키캡")),
        .category2(Category2(productId: "dbokey_artisan", title: "아티산")),
        .category2(Category2(productId: "dbokey_switch", title: "스위치")),
        .category2(Category2(productId: "dbokey_etc", title: "기타"))
    ]

    struct Input {
        let select: ControlEvent<CategoryItem>
        let likeTap: Observable<String>
        let selectCell: ControlEvent<IndexPath>
    }
    struct Output {
        //탭한 결과 = 통신 응답
        let list: Observable<[PostData]>
        let likeList: BehaviorSubject<likeModel>
        let categories: Observable<[CategoryItem]>//<[Category]>
        //let categories2: Observable<[Category2]>
        let selectCell: ControlEvent<IndexPath>
        let selectedCategoryTitle: Observable<String> // 카테고리 제목을 전달할 Observable
    }
    func transform(input: Input) -> Output {
        let selectedCategoryTitle = input.select.map { $0.title }
        
        let listObservable = input.select.flatMapLatest { item -> Observable<[PostData]> in
            switch item {
            case .category(let category):
                return NetworkManager.viewPost(next: "", limit: "100", productId: category.productId, productId1: category.productId1, productId2: category.productId2, productId3: category.productId3, productId4: category.productId4, productId5: category.productId5)
                    .asObservable()
                    .catch { error in
                        print(error.localizedDescription)
                        return Observable.just(ViewPostModel(data: [], next_cursor: ""))
                    }
                    .map { $0.data }
            case .category2(let category2):
                return NetworkManager.viewPost2(next: "", limit: "100", productId: category2.productId)
                    .asObservable()
                    .catch { error in
                        print(error.localizedDescription)
                        return Observable.just(ViewPostModel(data: [], next_cursor: ""))
                    }
                    .map { $0.data }
            }
        }.share(replay: 1, scope: .whileConnected)
        
        // 나머지 코드는 그대로 유지...
        
        return Output(list: listObservable, likeList: likeList, categories: Observable.just(categories), selectCell: input.selectCell, selectedCategoryTitle: selectedCategoryTitle)
    }    }
