---
name: new-domain
description: 새 도메인(엔티티, 리포지토리, 서비스, 컨트롤러, DTO)의 골격을 설치된 패키지 구조·DTO·계층 규칙에 맞게 생성한다.
---

# /new-domain — 도메인 골격 생성

인자(`$ARGUMENTS`)는 도메인 이름과 필요한 기능(생성/조회/수정/삭제 등)이다.

1. `.claude/rules/`에서 `package-structure.md`, `service-layering.md`, `result-creation.md`, `dto-layer.md`, `dto-create.md`, `layer-architecture.md`, `jpa-entity.md`, `transaction.md`를 읽는다. 설치되지 않은 규칙이 있으면 알린다.
2. 아래를 확인한다. 인자에 없고 결과가 달라지는 것만 묻는다.
   - 도메인 이름, 엔티티 필드와 제약
   - 필요한 기능 목록(요청한 것만 만든다)
   - 다른 도메인과의 관계(id 참조 / 연관관계)
3. 생성 계획(파일 목록과 위치)을 보여주고 승인받는다.
4. 계획대로 만든다. 요청한 기능에 필요한 파일만 만들고, 빈 서브패키지와 쓰이지 않는 DTO는 만들지 않는다.
   - Entity: `jpa-entity.md` 규칙(정적 팩토리, 지연 로딩, enum STRING)
   - Repository
   - Service 인터페이스 + Impl (`@Transactional`은 Impl). 단계 구분은 `service-layering.md`를 따른다.
   - Controller, Request/Command/Query/Result/Response (필요한 것만)
5. 컴파일한다(`<<결정: ./gradlew compileJava>>`). 요청 시 `/test`로 테스트를 추가한다.
6. 만든 파일 목록과 규칙 대비 가정(정해지지 않아 기본값으로 둔 것)을 보고한다.
