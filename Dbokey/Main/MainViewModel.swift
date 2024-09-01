//
//  MainViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/19/24.
//

import Foundation
import RxSwift
import RxCocoa
enum CategoryItem: Equatable {
    static func == (lhs: CategoryItem, rhs: CategoryItem) -> Bool {
        return lhs.title == rhs.title
    }
    
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
struct Category: Equatable {
    let productId: String
    let productId1: String
    let productId2: String
    let productId3: String
    let productId4: String
    let productId5: String

    let title : String
}
struct Category2: Equatable {
    let productId: String
    let title: String
}

class MainViewModel {
    let disposeBag = DisposeBag()
    
    private var likeData = likeModel(like_status: false)
    private lazy var likeList = BehaviorSubject(value: likeData)
    //pagenation
    private var currentCursor: String = ""
    private var currentCategory: CategoryItem?
    
    private var isLoading = false
   private var hasMorePages = true
    
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
        let loadMore: Observable<Void>
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
        
        let categoryChanged = input.select.distinctUntilChanged()
        
        let initialList = categoryChanged.flatMapLatest { [weak self] (item: CategoryItem) -> Observable<[PostData]> in
            self?.currentCursor = "" // 카테고리 선택 시 cursor 초기화
            self?.currentCategory = item
            return self?.fetchData(for: item, cursor: "") ?? .empty()
        }.share(replay: 1, scope: .forever)

        let additionalList = input.loadMore
            .withLatestFrom(Observable.just(()))
            .flatMapLatest { [weak self] _ -> Observable<[PostData]> in
                guard let self = self, let category = self.currentCategory else { return .empty() }
                return self.fetchData(for: category, cursor: self.currentCursor)
            }

        let listObservable = Observable.merge(initialList, additionalList)
            .scan(([], "")) { [weak self] (accumulated, newList) -> ([PostData], String) in
                let (accumulatedList, lastCategory) = accumulated
                if self?.currentCategory?.title == lastCategory {
                    return (accumulatedList + newList, lastCategory)
                } else {
                    return (newList, self?.currentCategory?.title ?? "")
                }
            }
            .map { $0.0 }  // 튜플에서 리스트만 추출
            .share(replay: 1, scope: .forever)
        
        
        return Output(list: listObservable, likeList: likeList, categories: Observable.just(categories), selectCell: input.selectCell, selectedCategoryTitle: selectedCategoryTitle)
    }
    private func fetchData(for item: CategoryItem, cursor: String) -> Observable<[PostData]> {
        switch item {
        case .category(let category):
            return NetworkManager.viewPost(next: cursor, limit: "6", productId: category.productId, productId1: category.productId1, productId2: category.productId2, productId3: category.productId3, productId4: category.productId4, productId5: category.productId5)
                .do(onSuccess: { [weak self] response in
                    self?.currentCursor = response.next_cursor
                })
                .map { $0.data }
                .asObservable()
                .catch { error in
                    print(error.localizedDescription)
                    return .just([])
                }
        case .category2(let category2):
            return NetworkManager.viewPost2(next: cursor, limit: "6", productId: category2.productId)
                .do(onSuccess: { [weak self] response in
                    self?.currentCursor = response.next_cursor
                })
                .map { $0.data }
                .asObservable()
                .catch { error in
                    print(error.localizedDescription)
                    return .just([])
                }
        }
    }
}

