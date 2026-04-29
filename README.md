# Mammazone (맘마존)

전국 수유실 지도 앱 - 주변 수유실을 쉽고 빠르게 찾아보세요.

## 주요 기능

- **수유실 지도** - 네이버 지도 기반으로 현재 위치 주변 수유실을 마커로 표시
- **수유실 상세 정보** - 주소, 층 정보, 운영 시간, 편의시설(유모차 대여, 키즈존, 장애인 화장실) 확인
- **즐겨찾기** - 자주 방문하는 수유실을 기기별로 저장/관리
- **길안내** - 네이버 지도, 카카오맵 앱 연동 길안내
- **평점/리뷰** - 수유실별 평균 평점 및 리뷰 수 표시

## 기술 스택

| 분류 | 기술 |
|------|------|
| Framework | Flutter (Dart) |
| Backend | Supabase (PostgreSQL, RPC) |
| 지도 | Naver Map SDK (`flutter_naver_map`) |
| 상태 관리 | Riverpod |
| 라우팅 | GoRouter |
| 광고 | Google AdMob (`google_mobile_ads`) |
| 위치 | Geolocator, Permission Handler |

## 프로젝트 구조

```
lib/
├── main.dart
├── core/
│   ├── constants/          # 환경변수, Supabase 테이블/뷰/RPC 상수
│   ├── router/             # GoRouter 라우트 설정
│   ├── services/           # 기기 ID 서비스
│   └── theme/              # Material Design 3 테마 (핑크 #E8609A)
├── data/
│   ├── models/             # 수유실, 리뷰, 즐겨찾기, 신고 모델
│   └── repositories/       # 즐겨찾기 CRUD
├── features/
│   ├─�� map/                # 메인 지도 화면
│   ├── detail/             # 수유실 상세 화면
│   ├── favorite/           # 즐겨찾기 목록
│   └── mypage/             # 마이페이지
└── shared/
    └── widgets/            # 하단 탭바, 광고 배너
```

## 환경 설정

### 1. 환경변수 파일 생성

프로젝트 루트에 `.env` 파일을 생성합니다.

```bash
cp .env.example .env
```

`.env` 파일에 실제 키 값을 입력합니다:

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
NAVER_MAP_CLIENT_ID=your_naver_map_client_id
ADMOB_BANNER_ID=your_admob_banner_id
```

### 2. Android 설정

`android/local.properties`에 다음 항목을 추가합니다:

```properties
naver.map.client.id=your_naver_map_client_id
admob.app.id=your_admob_app_id
```

릴리스 빌드 시 `android/key.properties`에 서명 키를 설정합니다:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=your_keystore_file.jks
```

### 3. 실행

```bash
# 개발 실행
flutter run --dart-define-from-file=.env

# 릴리스 빌드
flutter build appbundle --dart-define-from-file=.env
```

## Supabase 스키마

| 테이블/뷰 | 설명 |
|-----------|------|
| `nursing_room` | 수유실 정보 (위치, 주소, 편의시설, 출처 등) |
| `nursing_room_rating` | 수유실별 평균 평점 집계 뷰 |
| `review` / `review_photo` | 리뷰 및 리뷰 사진 |
| `favorite` | 기기 ID 기반 즐겨찾기 |
| `report` | 정보 수정 신고 |
| `get_nursing_rooms_nearby()` | 반경 내 수유실 검색 RPC |
