---
paths:
  - "src/main/**"
---

# 검증 (Validation)

검증은 두 종류로 나누고, 위치를 섞지 않는다.

| 종류 | 예 | 위치 | 방법 |
|---|---|---|---|
| 입력 형식 | 필수값, 길이, 범위, 형식 | Request | Bean Validation (`@NotBlank`, `@Size`, `@Pattern` ...) |
| 업무 규칙 | 중복 여부, 상태 전이 가능 여부, 권한, 재고 | Service(또는 Entity) | 코드로 확인 후 업무 예외 던지기 |

## 규칙
- Bean Validation 어노테이션은 Request(와 설정 Properties)에만 쓴다. Command, Query, Result, Response, Entity에는 쓰지 않는다.
- Controller는 `@Valid`/`@Validated`로 검증을 활성화한다. 중첩 객체는 필드에 `@Valid`를 붙인다. 단일 `@PathVariable`/`@RequestParam` 검증은 Controller 클래스에 `@Validated`를 둔다.
- 검증 메시지는 `<<결정: 한글 고정 문구 / 메시지 소스>>`. 사용자에게 보여줄 문구에 내부 구현 정보를 넣지 않는다.
- 여러 Request가 같은 형식 규칙을 반복하면 커스텀 제약 어노테이션으로 뽑는다.
- 상태 전이처럼 엔티티 자신의 불변식은 Entity 메서드 안에서 지킨다(`jpa-entity.md`).
- 중복 방지는 DB 유니크 제약을 최종 방어선으로 두고, Service에서 사전 확인은 사용자 친화 메시지를 위해 추가한다. 둘 중 하나만 믿지 않는다(경쟁 상황은 `concurrency.md`).
- 검증 실패 응답 형식은 `exception-handling.md`를 따른다.
