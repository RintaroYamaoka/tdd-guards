#!/usr/bin/env bash
# git commit の前に、package.json に test / lint があれば流す。落ちたら止める。exit 2 = block。
set -u
cmd=$(python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null) || exit 0
echo "$cmd" | grep -Eq '(^|[;&| ])git commit' || exit 0
[ -f package.json ] || exit 0
has() { python3 -c 'import json,sys;print("1" if sys.argv[1] in json.load(open("package.json")).get("scripts",{}) else "")' "$1"; }
if [ -n "$(has test)" ]; then
  npm test --silent >/tmp/tdd-test.log 2>&1 || { echo "tdd: テストが落ちている。commit の前に直す(ログ /tmp/tdd-test.log)。" >&2; tail -30 /tmp/tdd-test.log >&2; exit 2; }
fi
if [ -n "$(has lint)" ]; then
  npm run lint --silent >/tmp/tdd-lint.log 2>&1 || { echo "tdd: lint が落ちている。commit の前に直す(ログ /tmp/tdd-lint.log)。" >&2; tail -30 /tmp/tdd-lint.log >&2; exit 2; }
fi
exit 0
