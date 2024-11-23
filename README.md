# ⌨️ Dbokey
> ### 키보드 중고 거래 앱
> 
<br />

## 📱 프로젝트 소개
> **개발 기간**: 2024.8.14 ~ 2024.9.1  
> **개발 인원**: 1인 (기획/디자인/개발)

<br />

<div align="center">
  <img width="19%" src="https://github.com/user-attachments/assets/607414b2-4034-4622-9091-173fcf133666" />
  <img width="19%" src="https://github.com/user-attachments/assets/4895df6a-d397-412e-a8b8-d5203c0633b1" />
  <img width="19%" src="https://github.com/user-attachments/assets/5f73bd29-77c7-430c-9083-9611a99b8659" />
  <img width="19%" src="https://github.com/user-attachments/assets/62a1fc0d-3e71-4cb2-bf42-5a1dfe185a02" />
  <img width="19%" src="https://github.com/user-attachments/assets/b3407d82-97ac-496a-a8d4-44ec16acee81" />
</div>

<br /><br />

## 🛠 기술 스택

### iOS
- **Language**: Swift 5.10
- **Minimum Target**: iOS 15.0
- **UI Framework**: UIKit
- **Design Pattern**: MVVM

### Dependencies
- **UI/Layout**: SnapKit
- **Reactive Programming**: RxSwift, RxCocoa
- **Networking**: Alamofire
- **Image Loading**: Kingfisher
- **Payment**: iamport-ios
- **Utility**: Then

## 📋 주요 기능

### 사용자 인증 시스템
- JWT 기반 토큰 인증 구현 (Access Token + Refresh Token)
- 자동 토큰 갱신 및 세션 관리
- 회원가입 단계별 유효성 검증 (이메일, 비밀번호, 닉네임, 전화번호, 생년월일)

### 상품 리스트 및 필터링
- 카테고리별 상품 목록 제공 (기성품/커스텀 키보드, 키캡, 스위치 등)
- 무한 스크롤 페이지네이션
- 상품 좋아요 및 찜하기 기능

### 상품 상세 정보
- 이미지 슬라이더 (UICollectionView 활용)
- 상품 정보 표시 (가격, 상태, 설명 등)
- 댓글 시스템
- 아임포트 결제 모듈 연동

### 판매자 기능
- 상품 등록/수정/삭제
- 다중 이미지 업로드
- 판매 내역 관리

## 🔧 트러블 슈팅

### 1. 토큰 기반 인증 처리

#### 문제
- API 요청마다 토큰 검증이 필요하며, 토큰 만료 시 모든 요청에서 401 에러 발생
- 여러 요청이 동시에 실행될 때 토큰 갱신이 중복으로 발생하는 Race Condition 문제
- 토큰 갱신 실패 시 로그인 화면 전환과 기존 요청들의 처리가 비일관적
#### 해결
```swift
// UserDefaultsManager를 활용한 토큰 관리
class UserDefaultsManager {
    var token: String {
        get { UserDefaults.standard.string(forKey: UserDefaultsKey.access.rawValue) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.access.rawValue) }
    }
    
    func clearAll() {
        UserDefaultsKey.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
}
```

### 2. 커서기반 페이지네이션 데이터 관리

#### 문제
- MainViewModel에서 페이지네이션 시 데이터 중복 및 누적 처리 이슈
#### 해결
-  currentCursor와 hasMorePages 플래그를 활용한 데이터 스트림 관리
```swift
private var currentCursor: String = ""
private var hasMorePages = true

private func fetchData(for item: CategoryItem, cursor: String) -> Observable<[PostData]> {
    guard hasMorePages else { return .just([]) }
    return NetworkManager.viewPost2(...)
        .do(onSuccess: { [weak self] response in
            if response.next_cursor == "0" {
                self?.hasMorePages = false
            }
            self?.currentCursor = response.next_cursor
        })
}
```

### 3. 카테고리 상태 관리와 데이터 동기화

#### 문제
- 카테고리 변경 시 이전 데이터와 새로운 요청 데이터 간의 동기화 문제
#### 해결
-   distinctUntilChanged와 scan 연산자를 활용한 상태 관리
```swift
let listObservable = Observable.merge(initialList, additionalList)
    .scan(([], "")) { [weak self] (accumulated, newList) -> ([PostData], String) in
        let (accumulatedList, lastCategory) = accumulated
        if self?.currentCategory?.title == lastCategory {
            return (accumulatedList + newList, lastCategory)
        } else {
            return (newList, self?.currentCategory?.title ?? "")
        }
    }
```

### 4. 다중 이미지 업로드 최적화

#### 문제
- WriteViewController에서 다중 이미지 업로드 시 메모리 관리 및 성능 이슈
#### 해결
-   이미지 압축과 동시성 처리를 통한 최적화
```swift
private func uploadPostFiles() {
    let images = imageViews.compactMap { $0.image?.jpegData(compressionQuality: 0.5) }
    NetworkManager.uploadFiles(images: images)
        .observe(on: MainScheduler.instance)
        .flatMap { [weak self] uploadResult -> Single<PostData> in
            // 압축된 이미지 업로드 후 게시글 등록
        }
}
```

## 📝 회고

### Keep (유지할 점)
1. **단계별 회원가입 플로우**
   - 각 단계별 독립적인 ViewModel과 유효성 검증
   - RxSwift를 활용한 실시간 입력 validation

2. **모듈화된 UI 컴포넌트**
   - IPointButton, SignTextField 등 재사용 가능한 커스텀 컴포넌트

3. **토큰 인터셉터를 통한 인증 처리**
    ```swift
    final class AuthInterceptor: RequestInterceptor {
        private let lock = NSLock()
        private var isRefreshing = false
        private var requestsToRetry: [(RetryResult) -> Void] = []
    }
    ```

### Problem (개선할 점)
1. **중복되는 네트워크 요청 처리**
   - API 호출 중복 로직 개선 필요
   - 캐싱 전략 수립 필요

2. **UIKit과 RxSwift 결합도**
   - View와 ViewModel 간 의존성 개선 필요
   - 테스트 가능한 구조로 리팩토링 필요

### Try (시도할 점)
1. **코드 기반 UI의 모듈화 개선**
