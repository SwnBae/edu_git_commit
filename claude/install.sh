#!/usr/bin/env bash
# 킷을 대상 프로젝트의 .claude/ 로 설치한다.
# 선택형 규칙(options)은 그룹마다 하나만 복사한다. 스킬은 카테고리 폴더 없이 .claude/skills/<이름>/ 으로 펼친다.
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET=""; PKG=""; SVC=""; RES=""; MSA=0; FORCE=0; DRY=0; SPRING=1

usage() {
  cat <<USAGE
사용법: install.sh --target <프로젝트 경로> [옵션]

  --package-structure <layered|domain-first|hexagonal>
  --service-layering  <one-way-dependency|type-isolation>
  --result-creation   <query-repository|service-converts>
  --msa               MSA 보강 규칙 추가 설치
  --no-spring-boot    common 만 설치
  --force             이미 있는 파일을 덮어쓴다
  --dry-run           복사하지 않고 목록만 출력

spring-boot 를 설치할 때는 위 세 선택을 모두 지정해야 한다. 장단점은 spring-boot/rules/options/README.md 참조.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2;;
    --package-structure) PKG="$2"; shift 2;;
    --service-layering) SVC="$2"; shift 2;;
    --result-creation) RES="$2"; shift 2;;
    --msa) MSA=1; shift;;
    --no-spring-boot) SPRING=0; shift;;
    --force) FORCE=1; shift;;
    --dry-run) DRY=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "알 수 없는 인자: $1" >&2; usage >&2; exit 2;;
  esac
done

[[ -n "$TARGET" ]] || { echo "--target 이 필요하다" >&2; usage >&2; exit 2; }
[[ -d "$TARGET" ]] || { echo "대상 폴더가 없다: $TARGET" >&2; exit 2; }

OPT="$KIT/spring-boot/rules/options"
check_choice() { # group value
  [[ -n "$2" ]] || { echo "--$1 선택이 필요하다. 가능: $(ls "$OPT/$1" | sed 's/\.md$//' | grep -v msa-overlay | tr '\n' ' ')" >&2; exit 2; }
  [[ -f "$OPT/$1/$2.md" && "$2" != "msa-overlay" ]] || { echo "잘못된 선택: $1=$2" >&2; exit 2; }
}
if [[ $SPRING -eq 1 ]]; then
  check_choice package-structure "$PKG"
  check_choice service-layering "$SVC"
  check_choice result-creation "$RES"
fi

RULES="$TARGET/.claude/rules"
SKILLS="$TARGET/.claude/skills"

copy_file() { # src dst
  if [[ -e "$2" && $FORCE -eq 0 ]]; then echo "건너뜀(이미 있음): $2"; return; fi
  echo "복사: $2"
  if [[ $DRY -eq 0 ]]; then mkdir -p "$(dirname "$2")"; cp "$1" "$2"; fi
}

install_group() { # 분류 이름 (common|spring-boot)
  local base="$KIT/$1"
  for f in "$base"/rules/*.md; do [[ -e "$f" ]] && copy_file "$f" "$RULES/$(basename "$f")"; done
  for d in "$base"/skills/*/; do
    [[ -d "$d" ]] || continue
    local name; name="$(basename "$d")"
    for f in "$d"*; do copy_file "$f" "$SKILLS/$name/$(basename "$f")"; done
  done
}

install_group common
if [[ $SPRING -eq 1 ]]; then
  install_group spring-boot
  copy_file "$OPT/package-structure/$PKG.md" "$RULES/package-structure.md"
  copy_file "$OPT/service-layering/$SVC.md" "$RULES/service-layering.md"
  copy_file "$OPT/result-creation/$RES.md" "$RULES/result-creation.md"
  [[ $MSA -eq 1 ]] && copy_file "$OPT/package-structure/msa-overlay.md" "$RULES/package-structure-msa.md"
fi
echo "완료. 설치 확인: Claude Code 에서 /memory 로 로드된 규칙을 확인한다."
