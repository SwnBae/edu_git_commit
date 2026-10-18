---
paths:
  - "src/main/**"
---

# 패키지 구조 — 계층 우선 (layered)

선택 기준: 작은 규모. 도메인이 적고(`<<결정: 기준>>`), 한 팀이 전체를 안다.

## 구조
```
{base-package}/
├── controller/      {Domain}Controller
├── service/         {Domain}Service (interface)
│   └── impl/        {Domain}ServiceImpl
├── repository/      {Domain}Repository
├── model/           JPA Entity (Entity만)
├── dto/
│   ├── request/  command/  query/  result/  response/
├── client/          외부 시스템 연동 (external-client 규칙)
├── config/          설정 클래스, @ConfigurationProperties
├── exception/       예외 클래스, ExceptionCode, 전역 예외 처리기
└── common/          공통 응답, 유틸
```
- DTO 접미사와 하위 패키지는 일치해야 한다(`OrderCreateRequest`는 `dto/request/`).
- 한 계층 폴더의 클래스가 `<<결정: 개수>>`를 넘으면 도메인별 하위 폴더로 나눈다(`controller/order/`). 그 시점이 domain-first로 옮기는 신호다.

## 의존 규칙
- `controller → service → repository → model` 방향으로만 의존한다. 역방향 의존 금지.
- controller는 repository, model을 import하지 않는다.
- 다른 도메인의 repository를 직접 쓰지 않는다. 그 도메인의 service를 통한다.
- `client`는 service에서만 호출한다.

## 검증 (ArchUnit 제안)
- `layeredArchitecture()`로 위 방향을 강제한다. 기존 위반이 있으면 `FreezingArchRule.freeze`로 고정하고 점진 해소한다.
