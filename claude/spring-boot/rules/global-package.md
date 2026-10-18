---
paths:
  - "src/main/**"
---

# `global` 패키지 — 다른 프로젝트로 이식하는 공통 코드

`preview` 프로젝트의 `global`을 그대로 옮겨 쓰기 위한 목록과 경계다. 패키지 이름만 새 프로젝트로 바꾸는 것을 기본으로 한다.

## 이식 대상 (`{base-package}.global`)
| 위치 | 클래스 | 상세 규칙 |
|---|---|---|
| `common` | `CommonApiResponse` | `common-api-response.md` |
| `common` | `BaseEntity` | `base-entity.md` |
| `config` | `JpaConfig` | `base-entity.md` |
| `exception` | `ErrorCode` | 아래 |
| `exception` | `BusinessException` | 아래 |
| `exception` | `GlobalExceptionHandler` | 아래 |

## 예외 구성의 현재 계약
- `ErrorCode`: enum. 필드 `HttpStatus httpStatus`, `String code`, `String message` (`@Getter` + `@RequiredArgsConstructor`).
- `BusinessException`: `RuntimeException` 상속. `ErrorCode`를 필드로 갖고, 생성자는 `BusinessException(ErrorCode)` 하나이며 메시지는 `errorCode.getMessage()`다.
- 도메인 예외는 `BusinessException`을 상속하고 정적 팩토리로 만든다(`CouponException.notFound()` 형태, 생성자는 `private`).
- `GlobalExceptionHandler`(`@RestControllerAdvice`)의 처리 목록:

| 예외 | 응답 |
|---|---|
| `BusinessException` | 해당 `ErrorCode`의 상태·코드·메시지 |
| `MethodArgumentNotValidException` | 400, `INVALID_INPUT`, 필드 오류 메시지를 `", "`로 연결 |
| `HandlerMethodValidationException` | 400, `INVALID_INPUT`, 검증 결과 메시지를 `", "`로 연결 |
| `Exception` (나머지 전부) | 500, `INTERNAL_SERVER_ERROR` 일반 메시지. 로그는 예외 클래스명과 메시지를 남긴다 |

- 응답은 모두 `CommonApiResponse.error(...)`로 만든다.
- 공통 오류 코드는 `C###`, 도메인 오류 코드는 도메인 약어 + 숫자(`CP001`)다. 새 도메인의 약어: `<<결정>>`.

## 이식 경계
- `ErrorCode`의 공통 코드(`INVALID_INPUT`, `INTERNAL_SERVER_ERROR`)는 그대로 옮긴다.
- 현재 `ErrorCode`에는 도메인 코드(쿠폰)가 같은 enum 안에 있다. 새 프로젝트로 옮길 때는 도메인 코드를 지우고 공통 코드만 남긴 뒤, 새 도메인 코드를 같은 enum에 추가한다. 이 방식이면 도메인이 늘 때마다 `global`이 바뀐다. 도메인 코드를 도메인별로 분리하려면 `ErrorCode` 구조 변경이 필요하며, 하려면 `<<결정>>`한다.
- 의존성: `spring-boot-starter-web`(또는 대상 Boot 버전의 웹 스타터), `spring-boot-starter-validation`, `spring-boot-starter-data-jpa`, Lombok.
- 이식 후 확인: 컴파일, 검증 실패 요청이 400 `INVALID_INPUT`으로 오는지, 업무 예외가 코드대로 오는지, 엔티티 저장 시 `createdAt`이 채워지는지.

## 다른 규칙과 다른 점 (현재 코드 기준, 코드는 수정하지 않음)
이식을 그대로 할지, 아래를 고칠지는 `<<결정>>`이다.
- `BusinessException`에 cause를 넘기는 생성자와 메시지 교체 생성자가 없다. `external-client.md`의 "cause 보존"을 하려면 생성자 추가가 필요하다.
- `Exception` 처리기가 스택트레이스 없이 클래스명과 메시지만 로그로 남긴다. `logging.md`/`exception-handling.md`는 5xx에 스택트레이스를 남기도록 한다.
- `Exception` 처리기가 나머지 예외를 모두 500으로 처리한다. 요청 본문 파싱 실패, 지원하지 않는 메서드 등 다른 상태 코드가 맞는 예외도 이 핸들러로 들어가는지는 프로젝트에서 테스트로 확인한다.
- 이 프로젝트의 계층 폴더(`presentation`, `application`, `domain`, `infrastructure`)는 킷의 `package-structure` 선택지와 이름이 다르다. 새 프로젝트에서 어느 쪽을 쓸지는 `package-structure` 선택으로 정한다.
