---
name: tdd
description: >
  コードを書く作業(新機能・修正・リファクタ)で default として守る小さな規律。project-bootstrap(退役・ADR 0027)から、
  一か月の transcript で実際に効いていた物だけを残した: Red → Green → Refactor / commit の前にテストと lint /
  既存を読んでから書く / 1 PR = 1 責務 / 共有の git 操作を壊さない。実装を始める前・commit や push を頼まれた時に読む。
  `/tdd` で明示的にも呼べる。
---

# tdd — 残した規律(advisory)

project-bootstrap の 22 gate のうち、2026-09-15〜10-16 の transcript で**実際に止めていた**物だけを文にした。
数字(一か月):テストが落ちたままの commit 68 / lint が落ちたままの commit 71 / 古い checkout からの trunk push 56 / `reset --hard` 23 / protected への直 push 13 / `push --force` 3。
これらは Fable 5.1 の session でも起きた。だから skill として読むだけでは足りない所は、このプラグインの hook 3 本が止める。

## 1. 書く前に読む
- 触る対象のコードと、呼び出し元を `Read` で見る。存在しない API・フィールドを想像で書かない。
- 既存のパターン(命名・層・エラーの扱い)に合わせる。新しいパターンは持ち込まない。
- 改名の履歴を確かめる(`git log -S<旧名>`)。旧名で書き続けない・同じ概念に 2 つ目の名前を作らない。

## 2. Red → Green → Refactor
1. **Red**:先に落ちるテストを書く。順序は 正常系の最小 → 境界(空・null・最小・最大)→ 失敗パス。
2. **Green**:テストを通す最小の実装。fallback・try/except・retry で症状を隠さない(fail-fast)。
3. **Refactor**:緑のまま整える。
- 実装ファイルを触ったら、対応するテストが無い状態で終えない。
- 「テストが全部 通る」を安心の材料にしない。一度わざと壊して落ちるかを見る(落ちないテストは無いのと同じ)。

## 3. commit の前
- テストと lint を**自分で流して**から commit する。落ちているなら直す。スキップ・`--no-verify`・テストの削除で通さない。
- PR ごとの CI がある repo は、手元で流すのは変更したファイルのテストと lint だけ。全件は CI に任せ、push 後に CI の緑を見る(全件を手元で回し直さない)。
- `git add -A` / `git commit -a` / 引数なしの `git stash` は使わない。自分が触ったファイルだけを stage する。
- 1 PR = 1 責務。依頼に無い「ついでの改善」は別 PR。

## 4. push の前
- `git fetch` して、trunk が進んでいたら rebase か merge してから push する(古い checkout から押さない)。
- `push --force`・`reset --hard`・protected branch への直 push は、人が明示したときだけ。

## 5. やらない事
- regex / filter / 集計範囲を広げる修正で「網羅性」を増やさない(対象が意図より広がる)。
- 「無い / 不可能」を grep の不一致で断定しない(設定・資格情報・外部リソース経由を見る)。
- ルールを射程外まで一般化しない。

## hook(このプラグインが入っていれば自動で効く)
`hooks/hooks.json` の PreToolUse(Bash)3 本が 3・4 を決定的に止める:`block-dangerous-git.sh` / `block-stale-push.sh` / `test-and-lint-before-commit.sh`。skill は読む側、hook は止める側。両方で一組。
