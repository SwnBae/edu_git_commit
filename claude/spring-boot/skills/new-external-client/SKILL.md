---
name: new-external-client
description: 외부 시스템 연동 클라이언트(전용 패키지, 설정 Properties, 외부 DTO, 예외 변환, 테스트)를 규칙에 맞게 생성한다.
---

# /new-external-client — 외부 클라이언트 생성

인자(`$ARGUMENTS`)는 외부 시스템 이름과 호출할 API 목록이다.

1. `.claude/rules/`의 `external-client.md`, `config-properties.md`, `exception-handling.md`, `transaction.md`를 읽는다.
2. 아래를 확인한다. 모르는 것은 추측하지 않고 사용자에게 묻는다.
   - 대상 API 문서(주소, 인증 방식, 요청/응답 형식)
   - 호출이 멱등한지(재시도 가능 여부)
   - timeout·재시도 값(`<<결정>>` 자리면 사용자가 정한다)
3. 생성 계획을 보여주고 승인받는다.
4. 만든다.
   - `@ConfigurationProperties` 클래스와 yml 키(비밀 값은 `${ENV}` 참조만)
   - 클라이언트 클래스(`RestClient.Builder` 주입, 시스템 전용 인스턴스, `onStatus` 처리)
   - 외부 DTO와 내부 모델 매퍼(외부 DTO는 이 패키지 밖으로 나가지 않는다)
   - 예외 변환(cause 보존, timeout 코드 구분)
   - (Resilience4j 사용 시) 인스턴스 설정
   - 테스트(실제 호출 없이 대역 서버/스텁)
5. 컴파일·테스트를 실행하고 결과를 보고한다.
6. 호출 지점은 트랜잭션 밖(상위 서비스 단계)에 두라고 안내한다. 호출 코드를 서비스에 연결하는 일은 요청받은 경우에만 한다.
