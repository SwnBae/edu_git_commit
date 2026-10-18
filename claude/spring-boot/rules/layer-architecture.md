---
paths:
  - "src/main/**"
---

# 계층 구조와 책임

폴더 배치는 설치된 `package-structure.md`, 서비스 내부 단계는 `service-layering.md`를 따른다. 이 문서는 계층별 책임이다.

## Controller
- 하는 일: 요청 바인딩, 입력 검증(`@Valid`), DTO 변환(`toCommand()` 등), Service 호출, 응답 래핑.
- 하지 않는 일: 업무 로직, 트랜잭션 시작, Repository 직접 호출, Entity 다루기.
- 메서드 본문은 짧게 유지한다. 분기·계산이 생기면 Service로 옮긴다.
- HTTP 상태 코드와 응답 형식은 `exception-handling.md`, `common-api-response.md`를 따른다.

## Service
- 업무 규칙, 흐름 조립, 트랜잭션 경계를 담당한다.
- 인터페이스 + Impl 쌍으로 만든다. `@Transactional`은 Impl(구체 클래스)에 붙인다(`transaction.md`).
- Request, HttpServletRequest 등 웹 타입을 알지 못한다.

## Repository
- 영속화와 조회만 한다. 업무 규칙을 넣지 않는다.
- 복잡한 조회는 `jpa-query.md`를 따른다.

## Entity
- 자기 상태의 불변식을 스스로 지킨다(`jpa-entity.md`). 외부 시스템, Service, DTO를 알지 못한다.

## 공통
- 생성자 주입만 쓴다. 순환 의존이 생기면 책임을 다시 나눈다(`@Lazy`로 덮지 않는다).
- 설정 클래스는 `config` 패키지에 둔다. 값은 `config-properties.md`를 따른다.
- 외부 시스템 호출은 `external-client.md`의 구조 안에서만 한다.
- 정적 유틸 클래스에 업무 로직을 숨기지 않는다.
