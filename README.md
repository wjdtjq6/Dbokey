# ⌨️ Dbokey
> ### 키보드 중고 거래 앱

<br />

## 📱 프로젝트 소개
> **개발 기간**: 2024.8.14 ~ 2024.9.1  
> **개발 인원**: 1인 (기획/디자인/개발)

<br />

<div align="center">
  <img width="16%" src="https://github.com/user-attachments/assets/607414b2-4034-4622-9091-173fcf133666" />
  <img width="16%" src="https://github.com/user-attachments/assets/4895df6a-d397-412e-a8b8-d5203c0633b1" />
  <img width="16%" src="https://github.com/user-attachments/assets/5f73bd29-77c7-430c-9083-9611a99b8659" />
  <img width="16%" src="https://github.com/user-attachments/assets/62a1fc0d-3e71-4cb2-bf42-5a1dfe185a02" />
  <img width="16%" src="https://github.com/user-attachments/assets/6067e8b3-5e51-46ed-81f6-2c02c9edac58" />
  <img width="16%" src="https://github.com/user-attachments/assets/e14ec241-128e-439f-a3f6-91b2f6aca5d0" />
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
- JWT 기반 토큰 인증 및 자동 갱신
- 단계별 회원가입 (이메일, 비밀번호, 닉네임, 전화번호, 생년월일 유효성 검증)

### 상품 리스트 및 필터링
- 카테고리별 상품 목록 제공 (기성품/커스텀 키보드, 키캡, 스위치 등)
- 커서 기반 페이지네이션을 통한 무한 스크롤
- 상품 좋아요 및 찜하기 기능

### 상품 상세 정보
- 상품 정보 표시 (가격, 상태, 설명 등)
- 댓글 시스템
- PG사 결제 모듈 연동

### 판매자 기능
- 상품 등록/수정/삭제
- 다중 이미지 업로드
- 판매 내역 관리

## 🔧 트러블 슈팅

### 1. 토큰 기반 인증 처리
#### 문제 상황
- 토큰 만료 시 401 에러로 인한 API 요청 실패
- 다중 요청 시 토큰 갱신 중복 발생
- 토큰 갱신 실패 시 비일관적인 에러 처리

#### 해결 방안
- RequestInterceptor를 활용한 토큰 갱신 자동화
- 토큰 만료 시나리오별 에러 핸들링 구현
- UserDefaults를 활용한 토큰 영구 저장소 구현

### 2. 커서 기반 페이지네이션
#### 문제 상황
- 오프셋 기반 페이지네이션의 데이터 정합성 문제
- 새로운 데이터 추가/삭제 시 페이지 불일치 발생

#### 해결 방안
- 마지막 아이템 ID 기반의 커서 페이지네이션 도입
- RxSwift Operator를 활용한 페이지네이션 데이터 스트림 관리
- 카테고리 변경 시 데이터 상태 초기화 로직 구현

### 3. 카테고리 상태 관리
#### 문제 상황
- 카테고리 변경 시 이전 데이터와 새로운 데이터 간 동기화 이슈
- 불필요한 API 호출 발생

#### 해결 방안
- distinctUntilChanged를 활용한 중복 요청 방지
- 카테고리별 독립적인 데이터 스트림 관리
- share 연산자를 통한 데이터 스트림 공유

## 📝 회고

### Keep (유지할 점)
1. **단계별 회원가입 플로우**
  - 독립적인 ViewModel을 통한 관심사 분리
  - 실시간 입력 유효성 검증 구현

2. **모듈화된 UI 컴포넌트**
  - 재사용 가능한 커스텀 컴포넌트 설계
  - 일관된 UI/UX 제공

3. **효율적인 상태 관리**
  - RxSwift를 활용한 반응형 프로그래밍 구현
  - Input/Output 패턴을 통한 데이터 흐름 단순화

### Problem (개선할 점)
1. **네트워크 계층 최적화**
  - API 응답 데이터 캐싱 전략 수립 필요
  - 에러 처리 로직 체계화 필요
  - 네트워크 상태에 따른 요청 관리 개선

2. **아키텍처 개선**
  - View와 ViewModel 간 의존성 더 명확한 분리 필요
  - 테스트 용이성을 고려한 구조 개선
  - 비즈니스 로직 모듈화 강화

3. **UI/UX 개선**
  - 사용자 피드백 반영을 위한 에러 처리 UI 개선
  - 로딩 상태 표시 체계화
  - 오프라인 모드 지원 검토

### Try (시도할 점)
1. **테스트 커버리지 향상**
  - Unit Test 도입으로 신뢰성 향상
  - UI Test를 통한 사용자 시나리오 검증
  - Test Doubles를 활용한 격리된 테스트 환경 구축

2. **성능 최적화**
  - 메모리 사용량 모니터링 및 최적화
  - 이미지 캐싱 전략 개선
  - 앱 시작 시간 단축을 위한 초기화 로직 최적화

3. **코드 품질 개선**
  - 코드 컨벤션 확립
  - 문서화 강화
  - 재사용 가능한 컴포넌트 라이브러리화
