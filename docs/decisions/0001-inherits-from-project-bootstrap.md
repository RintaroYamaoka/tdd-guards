# ADR 0001: project-bootstrap から何を継ぎ、何を継がないか

- 日付: 2026-10-16
- 状態: 採択

## 文脈
project-bootstrap(22 gate・11 skill)は 2026-10-16 に退役した(同 repo ADR 0027)。退役の前に、手元の transcript(2026-09-15〜10-16)で「gate が実際に止めた物」を数えた。結果、止めた物の約 6 割は 並走・lane・docs-owner・WO という**運用の方針**の番で、その方針は使われなくなっていた。残り約 4 割は モデルの世代に関係なく毎週 起きる **AI の癖と事故の芽** だった(テストを落としたままの commit 68・lint 71・古い checkout からの push 56・reset --hard 23・protected 直 push 13・force 3)。

## 決定
- 継ぐ:後者だけ。hook 3 本+skill 1 本。
- 継がない:並走の安全網(`checkout --`・`branch -D`・`add -A` の拒否・lane 外の編集の拒否)・docs-owner・WO の発注〜検収・sprint 分解・SessionStart 監査・UserPromptSubmit の割り込み。**並走運用に戻す時は project-bootstrap の gate を読み直す。**
- `git add -A` の拒否は hook にしない(一人の作業では正当な場面が多い)。skill の文で「自分が触った物だけ stage」と置く。

## 帰結
- 失点のうち、hook が無いと見えなくなる物(落ちたテストでの commit)は hook で残したので、見え続ける。
- 判断する hook・marker・設定ファイルは持たない。壊れ方が単純(各スクリプト 30 行以内・exit 2 だけ)。
- 退役の理由を「モデルの進化」と書かなかったこと自体が、この repo の最初の規律:**外す前に数える。**
