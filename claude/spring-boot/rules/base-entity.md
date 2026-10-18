---
paths:
  - "src/main/**"
---

# 공통 엔티티 (`BaseEntity`)와 JPA Auditing

모든 엔티티가 상속하는 생성·수정 시각 공통 클래스다. `preview` 프로젝트의 `global/common/BaseEntity.java`, `global/config/JpaConfig.java`를 기준으로 한 규약이다. `<<결정>>`은 프로젝트가 채운다.

## 구성 (둘이 한 쌍)
- 위치: `{base-package}.global.common.BaseEntity`
  ```java
  @Getter
  @MappedSuperclass
  @EntityListeners(AuditingEntityListener.class)
  public abstract class BaseEntity {
      @CreatedDate
      @Column(updatable = false)
      private LocalDateTime createdAt;

      @LastModifiedDate
      private LocalDateTime updatedAt;
  }
  ```
- 위치: `{base-package}.global.config.JpaConfig` — `@Configuration` + `@EnableJpaAuditing`. 이 설정이 없으면 `createdAt`/`updatedAt` 값이 채워지지 않는다. 이식할 때 두 클래스를 같이 옮긴다.
- 현재는 `@EnableJpaAuditing`을 메인 애플리케이션 클래스가 아니라 별도 설정 클래스에 둔다. 이 배치를 유지한다.

## 규칙
- 모든 엔티티는 `BaseEntity`를 상속한다. 예외(상속하지 않는 엔티티)를 허용하는 조건: `<<결정>>`.
- `BaseEntity`에는 시각 두 필드만 둔다. `id`는 각 엔티티에서 선언한다(식별자 전략은 `jpa-entity.md`).
- `createdAt`은 수정 불가(`updatable = false`)다. 감사 필드에 setter를 만들지 않고, 서비스·테스트 코드에서 직접 값을 넣지 않는다.
- 시각 타입은 `LocalDateTime`(시간대 정보 없음)이다. 시간대 정책(DB, 서버, JDBC URL): `<<결정>>`.
- 생성자/수정자(`createdBy`, `updatedBy`), 소프트 삭제, 낙관적 락 `@Version`은 현재 `BaseEntity`에 없다. 필요하면 추가 여부와 방식을 `<<결정>>`한다(낙관적 락은 `concurrency.md`).
- 엔티티 작성 규칙의 나머지는 `jpa-entity.md`를 따른다.

## 검증
- 저장 후 `createdAt`이 채워지고, 수정 후 `updatedAt`이 바뀌는지 `@DataJpaTest` 등으로 확인한다. 슬라이스 테스트에서 Auditing 설정이 적용되는지는 프로젝트에서 테스트로 확인한다(`test-strategy.md`).
