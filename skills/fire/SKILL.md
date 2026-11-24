---
name: fire
description: 解僱 AI Office 的員工：預設把他的名片和日記移到離職區保留（之後可以回聘），使用者明確要求才永久刪除。使用者說「解僱／開除／請他離職／fire」時使用。用法：/fire 名字
---

# 解僱員工

`ROOT`＝AI Office 程式的位置：本 skill 的 Base directory（SKILL.md 所在資料夾）往上兩層；如果那裡沒有 `scripts/team.sh`（例如在 Codex），改用 `cat ~/.ai-office/root` 印出的路徑。要在辦公室根目錄執行；辦公室根目錄＝`bash "ROOT/scripts/find-office.sh"` 印出的路徑。

## 1. 確認是誰
- 沒給名字、或說「全部」：讀 `team.md` 列出員工，問要請誰離開（可以多選）。
- 對方正在另一個視窗上班（ListAgents 看得到他的名牌在線上）：提醒使用者先在那個視窗 `/off`，或確定要直接解僱。

## 2. 問一次怎麼處理他的資料
用一句話問，選項：
- **移到離職區（建議）**：名片、日記、工作紀錄都保留，之後想讓他回來，打 `/hire 名字` 就能回聘。
- **永久刪除**：資料全部刪掉，救不回來。

一次解僱好幾位時，問一次就好，全部套用。

## 3. 執行
- 移到離職區：
  ```bash
  bash "ROOT/scripts/team.sh" fire <名字>
  ```
- 永久刪除：先再確認一次「刪掉就救不回來，確定嗎？」得到明確同意才做：
  ```bash
  rm -rf "team/<名字>"
  ```
  再把 `team.md` 裡他那一行拿掉。

⛔ 不要動 `projects/`、`shared/`、`docs/` 裡的東西：那些是辦公室的資料，不是個人的。

## 4. 存檔與回報
- 照 `ROOT/skills/sync/SKILL.md` 存檔推上去（commit 訊息例：「Max 離職（資料移到離職區）」）。
- 用一兩句話告訴使用者結果；移到離職區的話，提一句「想讓他回來，打 `/hire 名字` 就好」。
