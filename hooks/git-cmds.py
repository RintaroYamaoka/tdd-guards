#!/usr/bin/env python3
"""stdin の hook JSON から tool_input.command を取り、heredoc の本文と引用の中身を落として、
`git ...` で始まるコマンド片だけを 1 行ずつ出す。hook はこの出力だけを見る
(説明文や heredoc の中の "push --force" の様な文字列では止めない)。"""
import json
import re
import sys

try:
    cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "") or ""
except Exception:
    sys.exit(0)

out = []
lines = cmd.split("\n")
term = None
for line in lines:
    if term is not None:  # heredoc の本文は飛ばす
        if line.strip() == term:
            term = None
        continue
    m = re.search(r"<<-?\s*['\"]?([A-Za-z_][A-Za-z0-9_]*)['\"]?", line)
    if m:
        term = m.group(1)
    stripped = re.sub(r"'[^']*'", "''", line)  # 引用の中身を落とす(簡易)
    stripped = re.sub(r'"[^"]*"', '""', stripped)
    for seg in re.split(r"\s*(?:&&|\|\||;|\|)\s*", stripped):
        seg = re.sub(r"^[\s(]+", "", seg.strip())
        if re.match(r"(?:[A-Za-z_][A-Za-z0-9_]*=\S*\s+)*git\s", seg):
            out.append(re.sub(r"^(?:[A-Za-z_][A-Za-z0-9_]*=\S*\s+)*", "", seg))
print("\n".join(out))
