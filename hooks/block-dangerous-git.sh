#!/usr/bin/env bash
# 強制 push / reset --hard / protected(main|master|production) への直 push を止める。exit 2 = block。
# 見るのは git-cmds.py が抜き出した git のコマンド片だけ(heredoc・引用の中の文字列では止めない)。
set -u
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cmds=$(python3 "$H/git-cmds.py") || exit 0
[ -n "$cmds" ] || exit 0
while IFS= read -r c; do
  [ -n "$c" ] || continue
  if echo "$c" | grep -Eq '^git\s+push\b' && echo "$c" | grep -Eq -- '(^|\s)(--force|-f|--force-with-lease)(\s|$)'; then
    echo "tdd: 強制 push は人が明示した時だけ。[$c]" >&2; exit 2; fi
  if echo "$c" | grep -Eq '^git\s+reset\s+.*--hard'; then
    echo "tdd: git reset --hard は人が明示した時だけ(未 commit の変更が消える)。[$c]" >&2; exit 2; fi
  if echo "$c" | grep -Eq '^git\s+push\s+(\S+\s+)*(origin|upstream)\s+(main|master|production)(\s|$)'; then
    echo "tdd: protected branch への直 push。PR を通す。[$c]" >&2; exit 2; fi
done <<< "$cmds"
exit 0
