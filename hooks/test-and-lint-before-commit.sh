#!/usr/bin/env bash
# git commit の前に、package.json に test / lint があれば流す。落ちたら止める。exit 2 = block。
set -u
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cmds=$(python3 "$H/git-cmds.py") || exit 0
echo "$cmds" | grep -Eq '^git\s+commit\b' || exit 0
[ -f package.json ] || exit 0
has() { python3 -c 'import json,sys;print("1" if sys.argv[1] in json.load(open("package.json")).get("scripts",{}) else "")' "$1"; }
if [ -n "$(has test)" ]; then
  npm test --silent >/tmp/tdd-test.log 2>&1 || { echo "tdd: テストが落ちている。commit の前に直す(ログ /tmp/tdd-test.log)。" >&2; tail -30 /tmp/tdd-test.log >&2; exit 2; }
fi
if [ -n "$(has lint)" ]; then
  npm run lint --silent >/tmp/tdd-lint.log 2>&1 || { echo "tdd: lint が落ちている。commit の前に直す(ログ /tmp/tdd-lint.log)。" >&2; tail -30 /tmp/tdd-lint.log >&2; exit 2; }
fi
exit 0
