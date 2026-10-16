#!/usr/bin/env bash
# hook の smoke。止めるべき物が exit 2・通すべき物が exit 0 かを見る。
set -u; H="$(cd "$(dirname "$0")/.." && pwd)/hooks"; fail=0
t() { # t <期待 exit> <command文字列> <hook>
  local want=$1 cmd=$2 hook=$3; local got
  printf '{"tool_input":{"command":%s}}' "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$cmd")" | bash "$H/$hook" >/dev/null 2>&1; got=$?
  if [ "$got" = "$want" ]; then echo "ok   $hook  [$cmd] -> $got"; else echo "FAIL $hook  [$cmd] -> $got (want $want)"; fail=1; fi
}
t 2 "git push --force origin feat" block-dangerous-git.sh
t 2 "git push -f origin feat" block-dangerous-git.sh
t 2 "git reset --hard HEAD~1" block-dangerous-git.sh
t 2 "git push origin main" block-dangerous-git.sh
t 0 "git push origin feat/x" block-dangerous-git.sh
t 0 "git status" block-dangerous-git.sh
t 0 "git log --oneline" block-stale-push.sh
# test-and-lint: package.json の test が落ちる一時 repo で止まる / 無い repo で通る
tmp=$(mktemp -d); pushd "$tmp" >/dev/null
t 0 "git commit -m x" test-and-lint-before-commit.sh
printf '{"scripts":{"test":"exit 1"}}' > package.json
t 2 "git commit -m x" test-and-lint-before-commit.sh
printf '{"scripts":{"test":"exit 0"}}' > package.json
t 0 "git commit -m x" test-and-lint-before-commit.sh
popd >/dev/null; rm -rf "$tmp"
[ $fail = 0 ] && echo "all ok" || { echo "some failed"; exit 1; }
