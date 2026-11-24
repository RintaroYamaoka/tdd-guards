# Changelog

## [0.3.0] - 2026-11-24

### Added
- `say-terms.sh`(UserPromptSubmit)と `hooks/terms.md`:言葉のルールを毎ターン context に入れる。コードにある物はコードの名前で呼ぶ / 初出に一言添える / 名前が無い物は業界の標準用語(比喩や縮めた言葉に置き換えない)/ 同じ物を 2 つの名前で呼ばない。
- ADR 0002(なぜ skill でなく毎ターンの hook か)。`tests/hooks.test.bash` に smoke 2 本。

## [0.2.0] - 2026-10-26

### Changed
- `test-and-lint-before-commit`:PR ごとの CI(`.github/workflows` に `pull_request` で走る workflow)がある repo では、全件のテストと lint を CI に任せて通す。commit ごとの全件は CI と同じものの 2 回目で、大きい repo(vitest 30,000 本・10 分超)ではセッションごと落ちていた。skill `tdd` §3 も同じ形に(手元は変更したファイルのテストだけ)。

## [0.1.0] - 2026-10-16

### Added
- project-bootstrap(退役)から、transcript で実際に効いていた物だけを継承:skill `tdd`・hook 3 本(`block-dangerous-git` / `block-stale-push` / `test-and-lint-before-commit`)。
- `tests/hooks.test.bash`(hook の止める/通すの smoke)。
- ADR 0001(何を継がず、なぜか)。

### Fixed
- 初回の hook は command 文字列全体を見ていたので、heredoc や説明文の中の「push --force」で止まった(最初に止めた相手は、この hook を直す自分の commit だった)。`hooks/git-cmds.py` で heredoc の本文と引用の中身を落とし、`git ...` のコマンド片だけを見る形にした。偽陽性のテスト 4 本を足した(`tests/hooks.test.bash`)。
