---
paths:
  - "src/main/**"
---

# 패키지 구조 — 헥사고날 (포트와 어댑터)

선택 기준: 큰 규모이면서 도메인 로직이 복잡하고, 외부 기술(DB·메시징·API) 교체나 도메인 단독 테스트가 중요하다. 단순 CRUD 위주면 과하다(매핑 비용).

## 구조
```
{base-package}/{domain}/
├── adapter/
│   ├── in/web/                  Controller, dto/request, dto/response
│   └── out/
│       ├── persistence/         JPA Entity, Spring Data Repository, 영속 어댑터
│       └── client/              외부 시스템 어댑터 (external-client 규칙)
├── application/
│   ├── port/
│   │   ├── in/                  유스케이스 인터페이스, dto/command, dto/query
│   │   └── out/                 아웃바운드 포트 인터페이스, dto/result
│   └── service/                 유스케이스 구현 (Impl)
└── domain/                      순수 도메인 모델 (프레임워크 의존 없음)
```
- DTO 5종은 위치만 바뀐다: Request/Response는 `adapter.in.web`, Command/Query는 `port.in`, Result는 `port.out`.
- 유스케이스 인터페이스(`port.in`)가 "인터페이스 + Impl 쌍"의 인터페이스이고, `application.service`가 Impl이다. `@Transactional`은 Impl에 둔다.

## 의존 규칙
- `adapter → application → domain` 방향으로만 의존한다. `domain`은 아무것도 import하지 않는다(Spring, JPA 포함).
- `application`은 `adapter`를 import하지 않는다. 외부와는 포트로만 대화한다.
- 어댑터끼리 서로 import하지 않는다.
- JPA 엔티티와 도메인 모델을 분리할지(매핑 필요) 같은 클래스로 쓸지: `<<결정>>`. 분리하면 매핑 코드의 책임은 영속 어댑터다.

## 검증 (ArchUnit 제안)
- `onionArchitecture()` 또는 `layeredArchitecture()`로 방향을 강제한다.
