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
    
    private var isLoading = false
    private var nextCursor: String = ""
    
    struct Input {
        //let select: ControlEvent<CategoryItem>
        //let likeTap: Observable<String>
        let selectCell: ControlEvent<IndexPath>// 셀 선택 트리거
        let loadMoreData: AnyObserver<Void> // 데이터 로드 트리거
    }
    struct Output {
        //탭한 결과 = 통신 응답
        let list: Observable<[PostData]>
        let likeList: BehaviorSubject<likeModel>
        let categories: Observable<[Category]>//<[CategoryItem]>
        //let categories2: Observable<[Category2]>
        let selectCell: ControlEvent<IndexPath>
        let selectedCategoryTitle: Observable<String> // 카테고리 제목을 전달할 Observable
    }
    func transform(input: Input) -> Output {
        let selectedCategoryTitle = input.select.map { $0.title }
        
        let listObservable = input.select.flatMapLatest { item -> Observable<[PostData]> in
            return self.paginatedRequest(for: item)
        }
            .share(replay: 1, scope: .whileConnected)
        
        return Output(list: listObservable, likeList: likeList, categories: Observable.just(categories), selectCell: input.selectCell, selectedCategoryTitle: selectedCategoryTitle)
    }
    func loadMoreData() {
        guard !isLoading, nextCursor != "nil" else { return }
        isLoading = true
        // 여기서 현재 선택된 카테고리에 대한 데이터를 로드합니다.
        // 로드가 완료되면 isLoading을 false로 설정합니다.
    }
    private func paginatedRequest(for item: CategoryItem) -> Observable<[PostData]> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            func loadData() {
                guard self.nextCursor != "nil" else {
                    observer.onCompleted()
                    return
                }
                
                let singleObservable: Single<ViewPostModel>
                switch item {
                case .category(let category):
                    singleObservable = NetworkManager.viewPost(next: self.nextCursor, limit: "6", productId: category.productId, productId1: category.productId1, productId2: category.productId2, productId3: category.productId3, productId4: category.productId4, productId5: category.productId5)
                case .category2(let category2):
                    singleObservable = NetworkManager.viewPost2(next: self.nextCursor, limit: "6", productId: category2.productId)
                }
                
                singleObservable
                    .subscribe(onSuccess: { response in
                        self.nextCursor = response.next_cursor
                        observer.onNext(response.data)
                        if self.nextCursor != "nil" {
                            loadData() // 다음 페이지 로드
                        } else {
                            observer.onCompleted()
                        }
                    }, onFailure: { error in
                        observer.onError(error)
                    })
                    .disposed(by: self.disposeBag)
            }
            
            loadData()
            return Disposables.create()
        }
    }
}
