---
paths:
  - "src/main/**"
---

# DTO 레이어 규칙

요청·응답 객체는 레이어별로 역할이 분리된다. 네이밍을 반드시 지킨다.
작성 방법은 `dto-create.md`, 폴더 위치는 설치된 `package-structure.md`, Result를 만드는 위치는 `result-creation.md`를 따른다.

## 네이밍

| 접미어 | 레이어 | 설명 |
|---|---|---|
| `*Request` | Controller | HTTP 요청 바인딩 |
| `*Command` | Service | 데이터 변경 요청 |
| `*Query` | Service | 데이터 조회·필터 요청 |
| `*Result` | Service ↔ Repository | 조회/변환 결과. 만드는 위치는 `result-creation.md` |
| `*Response` | API 계약(Controller가 반환) | API 응답 페이로드 |

- 이름은 `{Domain}{Action}{Suffix}` 형태로 짓는다. 예) `ExcelJobCreateRequest`, `OrderSearchQuery`.
- 접미어 없는 DTO, `Dto` 접미어, `XxxDto` 컨테이너 안의 inner Request/Response는 금지한다. 각 DTO는 개별 파일이다.

## 흐름 (기본)

```
HTTP 요청
  └─▶ *Request            (Controller 수신)
        └─▶ *Command / *Query   (Controller가 변환해 Service로 전달)
                └─▶ Repository 호출
                      └─▶ *Result        (Service가 수신. 생성 위치는 result-creation.md)
                            └─▶ *Response      (Service가 변환, Controller가 반환)
                                  └─▶ CommonApiResponse<*Response>  (클라이언트 전달)
```
- `hexagonal` 구조를 선택한 경우 Response는 application 계층이 알지 못하므로 Controller(adapter.in.web)가 Result에서 만든다.
- 공통 응답 래퍼는 `CommonApiResponse`이며 형식은 `common-api-response.md`를 따른다.

## 계층 간 독립성

- Controller는 `*Result`를 알아서는 안 된다.
- Service는 `*Request`를 알아서는 안 된다.
- Controller ↔ Service 사이에 Entity를 직접 전달하지 않는다.
- Entity는 `dto` 패키지를 import하지 않는다. DTO는 Entity를 필드로 갖지 않는다(Result의 `from(Entity)` 인자는 예외).
- 각 DTO는 해당 레이어 안에서만 생성·소비한다.

## 레이어 경계에서 자주 생기는 상황

| 상황 | 규칙 |
|---|---|
| Service가 다른 Service를 호출할 때 | 입력은 Command/Query, 출력은 Result(또는 원시 값/void). Request/Response를 주고받지 않는다. |
| Command를 Entity로 바꿀 때 | Service가 Command의 값을 꺼내 Entity의 정적 팩토리/생성자에 넘긴다. Entity가 Command를 import하지 않는다. |
| 목록·페이징 조회 | Query가 페이지 조건(page, size, sort)을 담는다. 최대 size: `<<결정>>`. 응답은 `<<결정: 공통 페이지 응답 타입>>`에 `*Response`를 담는다. |
| 중첩 구조 | 중첩 객체도 별도 파일의 DTO다(`OrderItemResponse`). inner class로 만들지 않는다. |
| 부분 수정(PATCH) | 미지정과 null을 구분해야 하면 방식을 `<<결정>>`한다(필드 존재 여부 표시 / 별도 Command 분리). 기본은 변경 의도마다 Command를 분리한다. |
| null 정책 | 컬렉션 필드는 null이 아니라 빈 컬렉션이다. 응답의 null 필드 직렬화 여부는 `<<결정>>`. |
| 단건 ID 조회 | 별도 Query 없이 ID 파라미터로 전달해도 된다. |

## 패키지 (위치는 package-structure에서 정한 폴더 아래)

```
dto/
├── request/    *Request
├── command/    *Command
├── query/      *Query
├── result/     *Result
└── response/   *Response
```
- 클래스 접미어와 서브패키지 이름은 항상 일치한다(`*Request` → `dto/request/`).
- 해당 종류의 DTO가 없으면 서브패키지를 만들지 않는다.
- Entity는 `dto/` 아래에 두지 않는다. 엔티티 전용 패키지(`model/`)에만 둔다.

## 검증 (ArchUnit 제안)
- Service 패키지가 `dto.request`를 참조하지 않는지.
- Controller 패키지가 `dto.result`와 Entity 패키지를 참조하지 않는지.
- Entity 패키지가 `dto` 패키지를 참조하지 않는지.
- 클래스 접미어와 서브패키지 이름이 일치하는지.
