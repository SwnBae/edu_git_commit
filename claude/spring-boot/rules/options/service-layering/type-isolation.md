---
paths:
  - "src/main/**"
---

# 서비스 단계 — 타입 격리형

`one-way-dependency`의 호출 방향 규칙에 더해, **아래 단계의 내부 타입이 위 단계로 올라오지 못하게** 한다. 위 단계는 아래 단계의 구현 세부(엔티티, 리포지토리 타입, 영속 상태)를 볼 수 없다.

## 단계 (이름은 `<<결정>>`)
| 단계 | 예시 이름 | 다루는 타입 |
|---|---|---|
| 1 (위) | `{Domain}Facade` | Command, Query, Result, Response |
| 2 (아래) | `{Domain}ServiceImpl` | Command, Query, Result, Entity |
| 3 | Repository | Entity, Result(조회 전용) |

## 규칙
- `one-way-dependency`의 모든 규칙을 따른다(호출 방향, 같은 단계 호출 금지, 외부 호출은 1단계, 인터페이스+Impl, Impl에 `@Transactional`).
- 2단계의 공개 메서드(인터페이스)는 Entity를 매개변수로 받거나 반환하지 않는다. 입력은 Command/Query, 출력은 Result 또는 원시 값·void다.
- 1단계는 Entity, Repository 타입을 import하지 않는다.
- 엔티티의 지연 로딩 프록시가 트랜잭션 밖으로 나가지 않는다. 2단계가 트랜잭션 안에서 Result로 변환한 뒤 반환한다.
- 1단계가 필요한 정보가 2단계 반환값에 없으면 1단계가 아래 타입을 우회해서 얻지 않고, 2단계에 해당 Result를 반환하는 메서드를 추가한다.

## 검증 (ArchUnit 제안)
- 1단계 패키지가 `model`(Entity), `repository` 패키지에 의존하지 않는지.
- 2단계 인터페이스의 메서드 시그니처에 Entity 타입이 없는지(커스텀 조건 규칙).
