#!/usr/bin/env bash
# git push の前に、現在 branch の upstream(無ければ origin/main)が手元より進んでいたら止める。exit 2 = block。
set -u
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cmds=$(python3 "$H/git-cmds.py") || exit 0
echo "$cmds" | grep -Eq '^git\s+push\b' || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
git fetch -q origin 2>/dev/null || exit 0
base=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo origin/main)
git rev-parse --verify -q "$base" >/dev/null 2>&1 || exit 0
behind=$(git rev-list --count HEAD.."$base" 2>/dev/null || echo 0)
if [ "${behind:-0}" -gt 0 ]; then
  echo "tdd: $base が手元より $behind commit 進んでいる。rebase か merge してから push する。" >&2; exit 2
fi
exit 0
