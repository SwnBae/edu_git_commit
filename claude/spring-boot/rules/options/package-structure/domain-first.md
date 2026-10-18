---
paths:
  - "src/main/**"
---

# 패키지 구조 — 도메인 우선 (domain-first)

선택 기준: 큰 규모. 도메인이 여럿이고 팀이 나뉘며, 나중에 모듈·서비스 분리 가능성이 있다.

## 구조
```
{base-package}/
├── {domain}/                    예) order, member, payment
│   ├── controller/
│   ├── service/                 {Domain}Service (interface)
│   │   └── impl/                {Domain}ServiceImpl
│   ├── repository/
│   ├── model/                   JPA Entity (Entity만)
│   └── dto/
│       ├── request/  command/  query/  result/  response/
├── client/                      외부 시스템 연동 (external-client 규칙)
├── global/                      config, exception, 공통 응답, 공용 유틸
```
- `<<결정: 최상위에 api/ 같은 접두 패키지를 둘지>>`
- 도메인 패키지는 직접 하위 패키지 단위로 모듈 경계가 된다(Spring Modulith의 모듈 정의와 같다). 도메인 밖에 공개할 것과 숨길 것을 구분한다.

## 의존 규칙
- 다른 도메인의 `repository`, `model`, `dto`를 import하지 않는다. 다른 도메인이 필요하면 그 도메인의 `service` 인터페이스를 호출한다.
- 도메인 간 순환 의존 금지. `A → B`가 있으면 `B → A`는 없다. 필요하면 이벤트(`messaging-outbox` 규칙)로 끊는다.
- 다른 도메인의 엔티티를 `@ManyToOne` 등으로 직접 참조하는 것은 `<<결정: 허용/금지>>`. 금지하면 id로만 참조한다(분리 시 비용이 가장 낮다).
- `global`은 도메인을 import하지 않는다.

## 검증 (ArchUnit 제안)
- `slices().matching("..{base}.(*)..").should().beFreeOfCycles()`로 도메인 순환을 막는다.
- 도메인 간 접근 허용 목록을 규칙으로 만든다.
- (선택) Spring Modulith `verify()`: `<<결정: 도입 여부>>`
