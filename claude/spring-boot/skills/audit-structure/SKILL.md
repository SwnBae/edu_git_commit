---
name: audit-structure
description: 프로젝트의 패키지 구조와 계층 의존, DTO 규칙, 트랜잭션 자기 호출을 설치된 규칙 기준으로 점검하고 위반을 보고한다. 읽기 전용.
---

# /audit-structure — 구조 점검

읽기 전용이다. 파일을 수정하지 않는다.

1. `.claude/rules/`에서 `package-structure.md`, `service-layering.md`, `dto-layer.md`, `layer-architecture.md`, `transaction.md`, `external-client.md`를 읽고 점검 항목을 뽑는다. 설치되지 않은 규칙의 항목은 건너뛰고 건너뛴 사실을 보고한다.
2. `src/main`의 패키지 트리를 확인한다.
3. 코드에서 확인한다(검색 또는 import 분석). 아래는 기본 항목이며 설치된 옵션에 따라 가감한다.
   - 계층·도메인 간 import 방향 위반
   - Controller의 Repository/Entity/Result 참조, Service의 Request 참조
   - DTO 접미어와 패키지 불일치, `dto/` 아래 Entity
   - `@Transactional`이 인터페이스에 붙었는지, 같은 클래스 내부 호출(self-invocation)
   - 트랜잭션 메서드 안의 외부 클라이언트 호출
   - 외부 HTTP 클라이언트 타입이 연동 패키지 밖에서 쓰이는지
   - 업무 클래스의 `@Value` 사용
4. 보고 형식

   | 규칙 | 위치(파일:줄) | 위반 내용 |
   |---|---|---|

   - 코드에서 확인한 것만 적는다. 확인하지 못한 항목은 "미확인"으로 따로 적는다.
5. ArchUnit 테스트가 없으면, 위 항목을 테스트로 옮기는 것을 제안만 한다. 만들지 않는다.
