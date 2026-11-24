---
name: rename-staff
description: 幫 AI Office 的員工改名字（資料夾、名單、名片、日記一起改）。使用者說「改名／rename」時使用。用法：/rename-staff 舊名字 新名字
---

# 員工改名

`ROOT`＝AI Office 程式的位置：本 skill 的 Base directory（SKILL.md 所在資料夾）往上兩層；如果那裡沒有 `scripts/team.sh`（例如在 Codex），改用 `cat ~/.ai-office/root` 印出的路徑。要在辦公室根目錄執行；辦公室根目錄＝`bash "ROOT/scripts/find-office.sh"` 印出的路徑（只認 `.ai-office` 檔案，不會誤認 `~/.ai-office` 設定資料夾；沒印東西＝不在辦公室裡）。

1. 新名字規則同 `/hire`：小寫英文開頭，可含數字和 `-`，不能用數字結尾。
2. 執行：
   ```bash
   bash "ROOT/scripts/team.sh" rename <舊名字> <新名字>
   ```
3. 看一眼 `team/<新名字>/card.md` 內文，如果還有提到舊名字，改成新名字。
4. 告訴使用者：
   - 已改好；舊的日記都還在。
   - 目前還開著的視窗標題不會自己變，請在那些視窗重新打 `/role <新名字>`，或直接開新的。
