---
paths:
  - "src/main/**"
---

# Result 생성 — 조회용 Repository가 직접 반환

조회 전용 Repository가 쿼리 단계에서 Result를 직접 만든다. 엔티티를 거치지 않는다.

## 규칙
- 조회 결과를 쓰는 곳이 화면·응답용이면, 조회 Repository 메서드가 Result를 반환한다(JPQL `select new`, QueryDSL `Projections`, 인터페이스/클래스 프로젝션 중 `<<결정>>`).
- 변경(저장·수정·삭제) 흐름에서 쓰는 Repository 메서드는 엔티티를 다룬다. 이 엔티티는 Service 안에서만 쓰고 밖으로 반환하지 않는다.
- 조회 전용 Repository는 변경용 Repository와 분리한다: `{Domain}QueryRepository` 또는 `{Domain}Repository`의 조회 메서드 구분 중 `<<결정>>`.
- Service는 Result를 받아 Response로 바꾼다(`Response.from(Result)`). Result가 `from(Entity)` 팩토리를 가질 필요는 없다.
- Result는 필요한 컬럼만 담는다. 엔티티를 통째로 필드에 담지 않는다.
- 이 방식은 Repository 계층이 Result 타입을 안다. DTO 독립 규칙(`dto-layer`)의 "Controller는 Result를 모른다"는 유지되고, "Repository가 Result를 만든다"가 이 옵션의 정의다.
