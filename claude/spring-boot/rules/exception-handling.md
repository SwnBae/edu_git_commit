---
paths:
  - "src/main/**"
---

# 예외 처리

`<<결정>>`은 프로젝트가 채운다.

## 구조
- 전역 예외 처리기 한 곳(`@RestControllerAdvice`)이 모든 예외를 응답으로 바꾼다. Controller마다 try-catch를 두지 않는다.
- 오류 코드는 enum 한 곳(`ExceptionCode` 등: 코드 문자열, HTTP 상태, 기본 메시지)에서 관리한다.
- 업무 예외는 `RuntimeException`을 상속한 단일 기반 예외(`BusinessException` 등)에 오류 코드를 담아 던진다. 예외 종류가 늘어나면 기반 예외를 상속한다.
- 오류 응답 형식은 `CommonApiResponse.error(...)` 한 가지다(`common-api-response.md`). 오류 코드·예외·처리기의 현재 계약은 `global-package.md`를 따른다.

## 던지는 쪽
- 예외 메시지에는 원인 파악에 필요한 식별자(id 등)를 넣는다. 비밀 값과 개인정보는 넣지 않는다.
- 다른 예외를 감싸 던질 때 cause를 반드시 넘긴다. 생성자가 메시지나 cause를 버리지 않는다.
- 예외를 삼키지 않는다. `catch (Exception e) {}`, 로그만 남기고 정상 흐름으로 이어가는 처리 금지.
- `Exception`/`Throwable`을 광범위하게 잡지 않는다. 필요한 예외 타입만 잡는다.
- 존재하지 않는 자원은 404 계열 업무 예외로, 입력 오류는 400 계열로 구분한다.

## 처리하는 쪽 (전역 처리기)
- 검증 실패(`MethodArgumentNotValidException`, `ConstraintViolationException` 등)는 400으로 바꾸고, 필드별 사유를 응답에 담는다.
- 업무 예외는 코드에 정해진 상태와 메시지로 응답한다.
- 예상하지 못한 예외는 500과 일반화된 메시지로 응답한다. 스택트레이스와 내부 메시지를 응답에 노출하지 않는다.
- 로그는 이 처리기에서 한 번만 남긴다. 4xx는 `WARN`(또는 `INFO`), 5xx는 `ERROR`+스택트레이스: `<<결정>>`.
- 외부 연동 예외는 사용자에게는 일반화된 메시지, 로그에는 상세 원인을 남긴다(`external-client.md`).

## 트랜잭션과의 관계
- 롤백이 필요한 업무 예외는 `RuntimeException` 계열로 정의한다(`transaction.md`).
