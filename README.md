# tdd-guards

**project-bootstrap の後継。**22 本の gate と 11 本の skill を、**skill 1 本と hook 3 本**に縮めた Claude Code プラグイン。

残したのは、2026-09-15〜10-16 の transcript(51 プロジェクト・3.5 GB)で **実際に止めていた物だけ**(一か月の件数):

| hook | 止める物 | 一か月の実績 |
|---|---|---|
| `test-and-lint-before-commit.sh` | `git commit` の前に `npm test` / `npm run lint`(package.json にあれば)。落ちたら止める | テスト 68・lint 71 |
| `block-stale-push.sh` | `git push` の前に fetch し、upstream が進んでいたら止める | 56 |
| `block-dangerous-git.sh` | `push --force` / `reset --hard` / main・master・production への直 push | 23+13+3 |

skill `tdd` は読む側:書く前に読む / Red → Green → Refactor / commit・push の前の手順 / やらない事。

**残さなかった物**:複数 Claude の並走・lane・docs-owner・作業指示書(WO)の発注〜検収・sprint 分解・SessionStart の監査。理由は `docs/decisions/0001-inherits-from-project-bootstrap.md`(と project-bootstrap の ADR 0027)。「モデルが進化したから」ではない。Fable 5.1 の session でも、テストを落としたままの commit は毎週 起きていた。

## 入れ方

```
/plugin marketplace add RintaroYamaoka/claude-plugins
/plugin install tdd-guards@rintaro-yamaoka
```

手元で直接 使うなら `~/.claude/settings.json` の `hooks.PreToolUse` に `hooks/hooks.json` の 3 本を写し(`${CLAUDE_PLUGIN_ROOT}` をこの repo の絶対パスに)、`~/.claude/skills/tdd` に `skills/tdd` を symlink する。

## 設計の線

- hook は **stdin の JSON(`tool_input.command`)を読み、止める時だけ exit 2**。それ以外は exit 0 で何も言わない。音を出すのは止める時だけ。
- 判断を持つ hook は無い(dispatcher・marker・設定ファイル なし)。各スクリプトは 30 行以内。
- test/lint は `package.json` に script がある repo でだけ走る。無ければ黙って通す。
- 止めた物は Claude Code の tool_result に理由が出る。人が明示した時は、その場で人が打つ(hook は Claude の Bash だけに効く)。

## テスト

```
bash tests/hooks.test.bash
```
