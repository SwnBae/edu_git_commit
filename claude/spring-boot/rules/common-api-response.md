---
paths:
  - "src/main/**"
---

# 공통 API 응답 (`CommonApiResponse`)

모든 API 응답은 `CommonApiResponse<T>` 한 가지 형식으로 내려간다. 이 문서는 `preview` 프로젝트의 `global/common/CommonApiResponse.java`를 기준으로 한 규약이다. 이식할 때 필드 이름과 타입은 API 계약이므로 바꾸지 않는다. `<<결정>>`은 프로젝트가 채운다.

## 형식
위치: `{base-package}.global.common.CommonApiResponse`

| 필드 | 타입 | 성공 | 실패 |
|---|---|---|---|
| `success` | boolean | `true` | `false` |
| `status` | int | HTTP 상태 코드 값 | HTTP 상태 코드 값 |
| `data` | T | 응답 DTO(없으면 생략) | 생략 |
| `errorCode` | String | 생략 | 오류 코드 (`ErrorCode.code`) |
| `errorMessage` | String | 생략 | 오류 메시지 |
| `timestamp` | LocalDateTime | 생성 시각 | 생성 시각 |

- 클래스에 `@JsonInclude(NON_NULL)`이 있어 null 필드는 JSON에서 빠진다.
- Lombok은 `@Getter` + `@Builder`, 모든 필드 `final`. 생성은 아래 정적 팩토리만 쓴다.

```java
CommonApiResponse.success(T data, HttpStatus httpStatus)   // data 있는 성공
CommonApiResponse.success(HttpStatus httpStatus)            // data 없는 성공
CommonApiResponse.error(ErrorCode code)                     // 코드의 기본 메시지
CommonApiResponse.error(ErrorCode code, String overrideMessage) // 메시지 교체(검증 실패 등)
```
```json
{ "success": true,  "status": 201, "data": { }, "timestamp": "..." }
{ "success": false, "status": 404, "errorCode": "CP001", "errorMessage": "...", "timestamp": "..." }
```

## 사용 규칙
- Controller 반환 타입은 `ResponseEntity<CommonApiResponse<*Response>>`다. `data`에는 `*Response` DTO(또는 그 목록)만 담는다. Entity, Result를 담지 않는다(`dto-layer.md`).
- 성공 응답은 HTTP 상태를 `ResponseEntity`와 `CommonApiResponse`에 **같은 값**으로 넣는다. 서로 다르면 본문의 `status`와 실제 HTTP 상태가 어긋난다.
  ```java
  return ResponseEntity.status(HttpStatus.CREATED)
          .body(CommonApiResponse.success(response, HttpStatus.CREATED));
  ```
- 상태 코드 선택: 생성은 201, 조회·수정은 200: `<<결정>>`.
- 본문 없는 성공은 `success(HttpStatus)`를 쓴다. 이 래퍼는 본문이 있는 형식이므로 204(본문 없음) 대신 200을 쓰는 것을 기본으로 한다: `<<결정>>`.
- 실패 응답(`error(...)`)은 전역 예외 처리기만 만든다. Controller·Service가 직접 만들지 않는다. 오류는 예외로 던진다(`exception-handling.md`).
- 목록·페이지 응답의 `data` 형태: `<<결정: List<*Response> / 공통 페이지 타입>>`.
- `timestamp`는 `LocalDateTime.now()`(서버 기본 시간대)로 채워진다. JSON 직렬화 형식과 시간대 정책: `<<결정>>`.

## 이식 시 확인
- 의존성: `spring-web`(HttpStatus), Jackson 어노테이션, Lombok. 패키지명만 새 프로젝트에 맞게 바꾼다.
- `error(...)`가 `ErrorCode`에 의존하므로 `ErrorCode`, `BusinessException`, `GlobalExceptionHandler`와 함께 옮긴다(`global-package.md`).
