---
paths:
  - "src/main/**"
  - "src/main/resources/**"
---

# 설정(Config)과 yml 연동

`<<결정>>`은 프로젝트가 채운다. 속성 이름과 동작은 대상 Boot 버전 문서로 확인한다.

## 원칙
- 설정값은 `@ConfigurationProperties`로 타입 있는 객체에 바인딩해 쓴다. 업무 클래스(controller, service, entity)에서 `@Value`로 흩어 읽지 않는다. `@Value`는 설정 클래스 안의 단발 값에만 `<<결정: 허용 범위>>`.
- 설정 클래스는 `config` 패키지(또는 해당 외부 연동 패키지)에 둔다.

## 작성 방법
- 불변 바인딩을 쓴다: record 또는 생성자 바인딩 클래스. setter를 열지 않는다.
- 기본값은 `@DefaultValue`나 yml 기본값으로 정한다. 코드 곳곳의 하드코딩 기본값을 두지 않는다.
- 필수 값은 `@Validated` + Bean Validation(`@NotBlank`, `@NotNull`, `@Positive` 등)으로 기동 시점에 검증한다. 값이 없거나 잘못되면 애플리케이션이 기동 단계에서 실패해야 한다(fail-fast).
- 활성화는 `@ConfigurationPropertiesScan` 또는 `@EnableConfigurationProperties`로 한다: `<<결정>>`. `@Component`와 함께 붙이는 방식은 혼용하지 않는다.
- prefix는 소문자 kebab-case로 `<<결정: 예) app.외부시스템이름>>`. 외부 시스템별로 묶는다.

```java
@ConfigurationProperties(prefix = "app.payment-api")
@Validated
public record PaymentApiProperties(
    @NotBlank String baseUrl,
    @NotNull Duration connectTimeout,
    @NotNull Duration readTimeout,
    @DefaultValue("0") int maxRetry
) {}
```
```yaml
app:
  payment-api:
    base-url: ${PAYMENT_API_BASE_URL}
    connect-timeout: <<결정>>
    read-timeout: <<결정>>
```

## yml 관리
- 공통값은 `application.yaml`, 환경별 차이는 프로필 파일(`application-<profile>.yaml`)에 둔다.
- 비밀 값(비밀번호, 키, 토큰)은 yml에 평문으로 쓰지 않는다. `${ENV_NAME}`로 환경변수를 참조한다. 로컬 개발용 값은 커밋하지 않는 파일에 둔다: `<<결정>>`
- 기본 프로필에서 운영 값으로 동작하지 않게 한다. 운영 프로필은 명시적으로 지정한다.
- 시간·크기 값은 단위 있는 타입(`Duration`, `DataSize`)을 쓴다. 숫자만 쓰고 단위를 주석으로 설명하지 않는다.
- 설정 키 이름 규칙(kebab-case)과 계층 구조를 유지한다. 같은 의미의 키를 여러 곳에 중복 정의하지 않는다.

## 검증
- 설정 바인딩 테스트: 필수 값 누락 시 기동 실패하는지, 기본값이 적용되는지. 테스트는 `test-strategy.md`를 따른다.
- `@Value` 사용처 점검: `grep -rn "@Value" src/main` 결과가 허용 범위 안인지.
