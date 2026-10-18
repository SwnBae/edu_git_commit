---
paths:
  - "src/main/**"
---

# JPA 엔티티

## 선언
- `@Entity` + `@Getter`. `@Setter`, `@Data`는 쓰지 않는다.
- 기본 생성자는 `@NoArgsConstructor(access = AccessLevel.PROTECTED)`로 막는다. 생성은 정적 팩토리 메서드(또는 `private` 생성자 + `@Builder`)로 한다. 클래스 레벨 `@AllArgsConstructor`·`@Builder`로 모든 필드를 열지 않는다.
- 상태 변경은 의미가 드러나는 메서드(`cancel()`, `changeStatus(...)`)로 한다. 메서드 안에서 불변식을 확인한다.
- Entity는 DTO, Service, 외부 클라이언트를 import하지 않는다. Command의 값은 Service가 꺼내 인자로 넘긴다(`dto-layer.md`).

## 매핑
- `@Enumerated(EnumType.STRING)`을 쓴다. `ORDINAL`은 쓰지 않는다.
- 모든 연관관계는 `fetch = LAZY`를 명시한다. 특히 `@ManyToOne`, `@OneToOne`은 기본이 즉시 로딩이므로 반드시 지정한다.
- 연관관계의 주인을 명확히 하고, 양방향이면 연관관계 편의 메서드로 양쪽을 함께 갱신한다. 양방향은 필요할 때만 만든다.
- `cascade`, `orphanRemoval`은 생명주기가 완전히 종속된 경우에만 쓴다. 이유를 주석으로 남긴다.
- 컬렉션 필드는 초기화하고, 외부에는 불변 뷰로 노출한다.
- 시간·감사 필드는 공통 `BaseEntity`를 상속해 쓴다(`base-entity.md`).
- 테이블·컬럼 이름 규칙: `<<결정>>`. DDL은 마이그레이션 도구로 관리하고 `ddl-auto`는 운영에서 `none`/`validate`: `<<결정>>`.

## 식별자와 동등성
- 식별자 전략: `<<결정: IDENTITY/SEQUENCE 등>>`. IDENTITY는 배치 insert를 막는 점을 고려한다.
- `equals/hashCode`: `<<결정>>`. id 기반으로 만들 때는 저장 전 id가 null인 경우를 처리한다. Lombok `@EqualsAndHashCode`를 전체 필드에 적용하지 않는다.
- `toString`에 연관 엔티티(지연 로딩)를 넣지 않는다.

## 동시성
- 동시 수정 충돌이 가능한 엔티티는 `@Version`으로 낙관적 락을 쓴다(`concurrency.md`).

## 노출
- Entity를 API 응답이나 외부 메시지로 직접 내보내지 않는다.
