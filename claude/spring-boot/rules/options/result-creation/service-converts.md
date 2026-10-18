---
paths:
  - "src/main/**"
---

# Result 생성 — Service가 엔티티를 받아 변환

Repository는 엔티티를 반환하고, Service가 트랜잭션 안에서 Result로 변환한다.

## 규칙
- Repository는 엔티티(또는 엔티티 컬렉션/페이지)만 반환한다. Result를 알지 못한다.
- Result는 `static from(Entity)` 팩토리를 가진다. 호출은 Service가 한다.
- 변환은 트랜잭션 안에서 한다. 지연 로딩이 필요한 필드는 변환 시점에 읽는다(`open-in-view`는 `false`로 둔다).
- 목록 조회에서 연관 엔티티를 변환 중 접근하면 N+1이 생긴다. fetch join, `@EntityGraph`, 배치 페치(`default_batch_fetch_size`) 중 `<<결정>>`하고 `jpa-query` 규칙을 따른다.
- Service는 엔티티를 Result로 바꾼 뒤 Response로 바꾼다(`Response.from(Result)`). 엔티티가 Service 밖으로 나가지 않는다.
- 이 방식은 엔티티 전체를 로딩한다. 화면에 필요한 컬럼이 적은 대량 조회는 성능을 검토하고, 필요하면 해당 조회만 `query-repository` 방식을 쓴다: `<<결정: 혼용 허용 여부>>`.
