#!/usr/bin/env bash
# hook の smoke。止めるべき物が exit 2・通すべき物が exit 0 かを見る。
set -u; H="$(cd "$(dirname "$0")/.." && pwd)/hooks"; fail=0
t() { # t <期待 exit> <command文字列> <hook>
  local want=$1 cmd=$2 hook=$3; local got
  printf '{"tool_input":{"command":%s}}' "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$cmd")" | bash "$H/$hook" >/dev/null 2>&1; got=$?
  if [ "$got" = "$want" ]; then echo "ok   $hook  [${cmd%%$'\n'*}] -> $got"; else echo "FAIL $hook  [${cmd%%$'\n'*}] -> $got (want $want)"; fail=1; fi
}
# 止める
t 2 "git push --force origin feat" block-dangerous-git.sh
t 2 "git push -f origin feat" block-dangerous-git.sh
t 2 "git push --force-with-lease origin feat" block-dangerous-git.sh
t 2 "git reset --hard HEAD~1" block-dangerous-git.sh
t 2 "git push origin main" block-dangerous-git.sh
t 2 "cd repo && git push --force origin feat" block-dangerous-git.sh
t 2 "GIT_SSH_COMMAND=ssh git push origin master" block-dangerous-git.sh
# 通す
t 0 "git push origin feat/x" block-dangerous-git.sh
t 0 "git status" block-dangerous-git.sh
t 0 "git log --oneline" block-stale-push.sh
# 偽陽性:heredoc・引用・説明文の中の文字列では止めない
t 0 "cat > x.md <<'EOF'
push --force は禁止
git reset --hard も禁止
EOF
git add x.md" block-dangerous-git.sh
t 0 "echo 'git push --force' > note.txt" block-dangerous-git.sh
t 0 "python3 - <<'EOF'
print('git push origin main')
EOF" block-dangerous-git.sh
t 0 "echo 'git commit -m x' > a.txt" test-and-lint-before-commit.sh
# test-and-lint:package.json の test が落ちる一時 repo で止まる / 無い repo で通る
tmp=$(mktemp -d); pushd "$tmp" >/dev/null
t 0 "git commit -m x" test-and-lint-before-commit.sh
printf '{"scripts":{"test":"exit 1"}}' > package.json
t 2 "git commit -m x" test-and-lint-before-commit.sh
printf '{"scripts":{"test":"exit 0"}}' > package.json
t 0 "git commit -m x" test-and-lint-before-commit.sh
# PR の CI がある repo は落ちるテストでも通す(全件は CI)。push だけの workflow では通さない
git init -q .
printf '{"scripts":{"test":"exit 1"}}' > package.json
mkdir -p .github/workflows
printf 'on:\n  push:\n    branches: [main]\n' > .github/workflows/deploy.yml
t 2 "git commit -m x" test-and-lint-before-commit.sh
printf 'name: ci\non:\n  pull_request:\n  push:\n' > .github/workflows/ci.yml
t 0 "git commit -m x" test-and-lint-before-commit.sh
rm .github/workflows/ci.yml; printf 'on: [push, pull_request]\n' > .github/workflows/ci.yaml
t 0 "git commit -m x" test-and-lint-before-commit.sh
# merge 後だけ走る workflow(types: [closed])は CI に数えない
rm .github/workflows/ci.yaml; printf 'on:\n  pull_request:\n    types: [closed]\n' > .github/workflows/deploy-on-merge.yml
t 2 "git commit -m x" test-and-lint-before-commit.sh
popd >/dev/null; rm -rf "$tmp"
[ $fail = 0 ] && echo "all ok" || { echo "some failed"; exit 1; }
