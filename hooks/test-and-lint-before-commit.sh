#!/usr/bin/env bash
# git commit の前に、package.json に test / lint があれば流す。落ちたら止める。exit 2 = block。
set -u
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cmds=$(python3 "$H/git-cmds.py") || exit 0
echo "$cmds" | grep -Eq '^git\s+commit\b' || exit 0
[ -f package.json ] || exit 0
# PR ごとの CI(.github/workflows に pull_request で走る workflow)がある repo は、全件を CI に任せて通す。
#   全件を commit ごとに手元で回すと CI と同じものの 2 回目になり、大きい repo ではセッションごと落ちる(vitest 30,000 本・10 分超)。
top=$(git rev-parse --show-toplevel 2>/dev/null) || top=.
if python3 "$H/has-pr-ci.py" "$top"; then
  echo "tdd: PR の CI がある repo なので、全件のテストと lint は CI に任せる(変更したファイルのテストは自分で回す)。" >&2
  exit 0
fi
has() { python3 -c 'import json,sys;print("1" if sys.argv[1] in json.load(open("package.json")).get("scripts",{}) else "")' "$1"; }
if [ -n "$(has test)" ]; then
  npm test --silent >/tmp/tdd-test.log 2>&1 || { echo "tdd: テストが落ちている。commit の前に直す(ログ /tmp/tdd-test.log)。" >&2; tail -30 /tmp/tdd-test.log >&2; exit 2; }
fi
if [ -n "$(has lint)" ]; then
  npm run lint --silent >/tmp/tdd-lint.log 2>&1 || { echo "tdd: lint が落ちている。commit の前に直す(ログ /tmp/tdd-lint.log)。" >&2; tail -30 /tmp/tdd-lint.log >&2; exit 2; }
fi
exit 0
