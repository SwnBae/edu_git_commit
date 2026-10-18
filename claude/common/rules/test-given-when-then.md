---
paths:
  - "src/test/**"
---

# 테스트 작성 형식 (Given-When-Then)

- 테스트 하나는 행동 하나를 검증한다.
- 본문을 `// given`, `// when`, `// then` 세 구역으로 나눈다. 구역이 비면(예: 입력이 없는 경우) 해당 주석을 생략할 수 있다.
- `when`에는 호출 한 번만 둔다.
- `then`에서 검증한다. 결과·상태·예외를 확인하고, 필요한 협력 객체 호출 검증은 꼭 필요한 것만 한다.
- 테스트 안에 조건문·반복문을 넣지 않는다.
- 이름: `<<결정: @DisplayName 한글 문장 / 메서드명 영문 중 택일>>`. 어떤 상황에서 무엇이 되어야 하는지 읽히게 쓴다.
- 단언은 AssertJ를 쓴다: `assertThat(...)`, `assertThatThrownBy(...)`.
- 테스트끼리 순서·상태에 의존하지 않는다. 공유 가변 상태를 쓰지 않는다.
- 현재 시각·난수 같은 비결정 요소는 주입해서 고정한다.
- 테스트 데이터 준비는 테스트 파일 안의 헬퍼나 픽스처 메서드로 모아 중복을 줄이되, given 구역에서 어떤 값이 중요한지는 보이게 둔다.

```java
@Test
@DisplayName("잔액이 부족하면 출금에 실패한다")
void withdraw_insufficientBalance_throws() {
    // given
    Account account = Account.open(1_000L);

    // when & then
    assertThatThrownBy(() -> account.withdraw(2_000L))
        .isInstanceOf(InsufficientBalanceException.class);
}
```
- 테스트 종류별 전략(단위/슬라이스/통합)은 `test-strategy` 규칙을 따른다.
