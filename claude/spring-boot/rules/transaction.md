---
paths:
  - "src/main/**"
---

# 트랜잭션

서비스 내부 단계는 설치된 `service-layering.md`를 따른다. 수치와 선택은 `<<결정>>`.

## 경계
- 트랜잭션은 Service에서 시작한다. Controller, Repository, Entity에서 시작하지 않는다.
- `@Transactional`은 구체 클래스(Impl)에 붙인다. 인터페이스에 붙이지 않는다.
- 클래스 레벨 기본값: `<<결정: 읽기 전용 기본 + 쓰기 메서드만 재정의 / 메서드별 지정>>`. `readOnly = true`는 힌트이며 쓰기 차단을 보장한다고 가정하지 않는다.
- 트랜잭션은 짧게 유지한다. 필요한 DB 작업만 포함한다.

## 하지 않는 것
- 같은 클래스 안에서 `this`로 `@Transactional` 메서드를 호출하지 않는다. 프록시를 거치지 않아 적용되지 않는다. 단위가 다르면 클래스를 나눈다.
- `private`, `final`(프록시가 가로채지 못하는) 메서드에 `@Transactional`을 붙이지 않는다.
- 트랜잭션 안에서 외부 API 호출, 파일·네트워크 대기 같은 느린 작업을 하지 않는다. DB 커넥션을 오래 점유해 풀이 고갈될 수 있다. 외부 호출은 트랜잭션 밖(상위 단계)에서 하거나, 커밋 이후 이벤트로 처리한다.
- 참여 중인 내부 트랜잭션에서 예외가 났는데 바깥에서 catch로 삼키고 계속 진행하지 않는다. 트랜잭션이 rollback-only로 표시되어 커밋 시 예기치 않은 롤백이 난다.

## 롤백
- 기본은 `RuntimeException`, `Error`에서 롤백한다. 체크 예외로 롤백해야 하면 `rollbackFor`를 명시한다.
- 업무 예외는 `RuntimeException` 계열로 정의한다(`exception-handling.md`).

## 전파와 격리
- 기본 전파(`REQUIRED`)를 쓴다. `REQUIRES_NEW`, `NESTED` 등은 이유를 주석으로 남긴다.
- 격리 수준 변경은 `<<결정>>`하고 이유를 남긴다.

## 이벤트와 커밋 이후 작업
- 커밋 이후에 해야 하는 일(알림, 외부 호출)은 `@TransactionalEventListener`(기본 `AFTER_COMMIT`)로 분리한다.
- `AFTER_COMMIT` 리스너에서 DB 쓰기가 필요하면 새 트랜잭션(`REQUIRES_NEW`)이 필요하다.
- 커밋 이후 발행만으로는 발행 실패 시 이벤트가 유실될 수 있다. 유실되면 안 되는 이벤트는 `messaging-outbox.md`를 따른다.

## 영속성 컨텍스트
- `open-in-view`는 `false`로 둔다(`spring.jpa.open-in-view`). 지연 로딩은 트랜잭션 안에서 끝낸다.

## 근거
- [공식] Spring Framework 트랜잭션 문서: 프록시 기반이라 self-invocation에는 적용되지 않고, 구체 클래스 사용이 권장되며, `readOnly`는 힌트, 기본 롤백은 RuntimeException/Error, `@TransactionalEventListener` 기본 단계는 `AFTER_COMMIT`.
- [자료] 우아한형제들 기술블로그: 참여 트랜잭션 실패 시 rollback-only 표시. 외부 호출을 트랜잭션 안에서 하면 커넥션 풀이 고갈될 수 있다는 사례(ongitech 글).
- 읽은 문서는 Framework 7.0.x 기준이다. 대상 프로젝트 버전(Boot 4.0.x)에서 동작을 확인한다.
