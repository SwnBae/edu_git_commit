# Claude Code 킷 (rules + skills)

Spring Boot 백엔드 프로젝트에 적용하는 Claude Code 규칙과 스킬 모음이다.

```
claude/
├── common/                      언어·프레임워크 무관
│   ├── rules/                   git-convention, clean-code, logging, test-given-when-then
│   └── skills/                  task, done, pr, review-rules
├── spring-boot/
│   ├── rules/                   dto-layer, dto-create, layer-architecture, transaction, external-client,
│   │                            config-properties, exception-handling, validation, common-api-response, base-entity, global-package, jpa-entity, jpa-query,
│   │                            messaging-outbox, concurrency, test-strategy
│   │   └── options/             선택형 규칙 (그룹마다 하나만 설치) + README(장단점)
│   │       ├── package-structure/   layered | domain-first | hexagonal | msa-overlay(추가)
│   │       ├── service-layering/    one-way-dependency | type-isolation
│   │       └── result-creation/     query-repository | service-converts
│   └── skills/                  test, new-domain, new-external-client, audit-structure
└── install.sh                   .claude/ 로 설치
```

## 설치
Git Bash 등 bash 환경에서 실행한다.
```bash
./claude/install.sh --target . \
  --package-structure layered \
  --service-layering one-way-dependency \
  --result-creation service-converts
# MSA 보강: --msa 추가, common 만: --no-spring-boot, 미리보기: --dry-run, 덮어쓰기: --force
```
- 규칙은 `.claude/rules/`로, 스킬은 `.claude/skills/<이름>/SKILL.md`로 복사된다(스킬은 카테고리 폴더 없이 펼친다).
- 선택형 규칙은 설치되면 그룹 이름 파일(`package-structure.md` 등)이 된다. 선택을 바꾸려면 `--force`로 다시 설치한다.
- 이 폴더(`claude/`)는 Claude Code가 자동으로 읽지 않는다. 설치해야 적용된다.

## 규칙 파일 읽는 법
- `<<결정: …>>` 표시는 프로젝트가 값이나 선택을 채우는 자리다. 수치와 버전은 일부러 고정하지 않았다.
- 규칙 끝의 `근거`/`검증` 항목은 출처 표시와 점검 방법이다. `[공식]` 공식 문서, `[자료]` 블로그·글, `제안`은 킷 작성자의 판단이다.
- 읽은 공식 문서 일부는 최신 버전(Spring Boot 4.1.x, Framework 7.0.x) 기준이다. 이 킷을 만든 프로젝트는 Boot 4.0.8이므로 속성 이름과 동작은 사용 전에 대상 버전 문서로 확인한다.

## 알려진 미확정 사항
- MSA 계약 공유 방식과 서비스 분리 절차: 조사 전이다(`package-structure-msa.md`).
- `service-layering`의 두 선택지는 "윗단계에서 아래 정보를 가져올 수 없다"를 두 가지로 해석한 것이다.
- `/task`의 절차는 작성자가 정한 기본안이다.
- 커밋 트레일러(Co-Authored-By) 사용 여부는 `git-convention.md`의 `<<결정>>`이다.
- ArchUnit 검증은 규칙에 항목만 제안했고 테스트 코드는 아직 없다.
