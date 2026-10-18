---
paths:
  - "src/main/**"
---

# 외부 시스템 연동 (external-client)

외부 API·SDK 호출은 이 규칙의 구조 안에서만 한다. `<<결정>>`은 프로젝트가 채운다.
다른 서비스(MSA)도 외부 시스템으로 취급한다.

## 구조
- 외부 호출 클래스는 `<<결정: 패키지 위치. 예) client>>` 한 곳에만 둔다. controller, service, entity, 일반 component에서 직접 호출하지 않는다.
- 외부 시스템 하나당 클라이언트 클래스 하나, 그 시스템의 외부 DTO, 외부 DTO를 내부 모델로 바꾸는 매퍼로 구성한다.
- 외부 DTO는 이 패키지 안에서 끝낸다. service 이하로는 내부 모델만 넘긴다. Response DTO에 외부 DTO를 노출하지 않는다.
- 클라이언트의 책임은 호출, timeout, 상태 코드 처리, 예외 변환까지다. 저장·계산·재조회 판단 같은 업무 로직은 두지 않는다.
- 캐시 적용 위치는 클라이언트가 아니라 클라이언트를 감싸는 service 쪽이다: `<<결정>>`
- 호출은 서비스 단계의 상위 단계(트랜잭션 밖)에서 한다(`service-layering.md`, `transaction.md`).

## HTTP 클라이언트 구성
- Spring Boot가 제공하는 `RestClient.Builder`(또는 `RestTemplateBuilder`)를 주입받아 만든다. `RestClient.create()`, `new RestTemplate()`처럼 자동 구성을 우회하는 생성은 하지 않는다.
- 외부 시스템마다 별도 클라이언트 인스턴스를 만든다. 서로 다른 시스템이 timeout 설정이 하나뿐인 공용 빈을 공유하지 않는다. 기본 설정에서 갈라낼 때는 builder를 clone한다.
- 선언형 인터페이스(`@HttpExchange`)와 직접 호출 중 선택: `<<결정>>`
- 4xx/5xx 처리는 `onStatus`로 한다. `exchange()`를 쓰면 상태 핸들러가 적용되지 않으므로 오류 처리를 직접 한다.
- connect/read timeout은 시스템별 설정에서 읽는다. 값은 코드에 쓰지 않는다. `<<결정: 기본값과 시스템별 값>>`
- WebClient나 `.block()`을 쓰면 timeout을 반드시 지정한다.
- Boot 버전에 따라 클라이언트 자동 구성 속성(`spring.http.clients.*` 등)이 다를 수 있다. 사용 전 대상 버전 문서로 확인한다.

## 설정 연결
- 시스템별 base URL, timeout, 재시도 횟수는 `@ConfigurationProperties`로 받는다(`config-properties.md`). 업무 클래스에서 `@Value`로 직접 읽지 않는다.
- 키·토큰은 환경변수로만 주입한다. 코드, yml, CI 파일에 평문으로 넣지 않는다.

## 장애 대응 (Resilience4j 사용 시)
- retry, circuitbreaker, timelimiter, bulkhead 설정은 yml의 `resilience4j.<모듈>.instances.<이름>`에 둔다. 인스턴스 이름은 외부 시스템과 1:1로 맞춘다. 수치는 `<<결정>>`.
- 공통값은 `configs`와 `baseConfig`로 상속한다.
- retry 대상 예외를 명시한다. 멱등하지 않은 호출(주문 등 쓰기)은 retry에서 제외하거나 멱등키를 확보한다.
- 적용 순서는 Retry가 가장 바깥이 기본이다. 다른 순서가 필요하면 명시한다.

## 예외 변환
- 외부 호출 예외는 클라이언트 안에서 프로젝트의 외부 연동 예외 한 종류로 변환한다. 원인 예외는 cause로 보존하고, 어느 시스템인지와 사유를 메시지에 담는다. 생성자가 메시지를 버리지 않게 한다.
- 외부 시스템의 내부 메시지를 그대로 사용자 응답에 노출하지 않는다(`exception-handling.md`).
- timeout 오류 코드와 일반 연동 실패 코드를 구분한다.

## 근거
- [공식] Boot는 `RestClient.Builder` 주입을 권장하고 `RestClient.create()`는 자동 구성이 적용되지 않는다. `exchange()`에는 상태 핸들러가 적용되지 않는다. Resilience4j는 `instances` 단위 설정과 `baseConfig` 상속을 지원한다.
- 읽은 문서 일부는 Boot 4.1.x 기준이다. 대상 버전(4.0.x)에서 확인한다.

## 검증 (ArchUnit 제안)
- 외부 연동 패키지 밖에서 HTTP 클라이언트 타입을 쓰는 클래스가 없는지.
- 외부 DTO가 Response DTO에 의존하지 않는지.
- 클라이언트 안의 업무 로직 여부는 `/review-rules`로 사람이 확인한다.
