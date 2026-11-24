#!/usr/bin/env bash
# UserPromptSubmit:言葉のルール(terms.md)を毎ターン context に入れる。止めない(常に exit 0)。
cat "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/terms.md" 2>/dev/null
exit 0
