#!/usr/bin/env bash
# push --force / reset --hard / protected(main|master|production) への直 push を止める。exit 2 = block。
set -u
cmd=$(python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null) || exit 0
case "$cmd" in
  *"push --force"*|*"push -f "*|*"push -f"|*"--force-with-lease"*) echo "tdd: git push --force は人が明示した時だけ。" >&2; exit 2;;
  *"reset --hard"*) echo "tdd: git reset --hard は人が明示した時だけ(並走の作業・未 commit の変更が消える)。" >&2; exit 2;;
esac
if echo "$cmd" | grep -Eq 'git push( [^ ]+)* (origin|upstream) (main|master|production)( |$)'; then
  echo "tdd: protected branch への直 push。PR を通す。" >&2; exit 2
fi
exit 0
