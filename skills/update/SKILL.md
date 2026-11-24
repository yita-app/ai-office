---
name: update
description: 把 AI Office 外掛更新到最新版，並告訴使用者這次改了什麼。使用者說「更新／更新外掛／升級／update」時使用。用法：/update
---

# 更新 AI Office

`ROOT`＝AI Office 程式的位置：本 skill 的 Base directory（SKILL.md 所在資料夾）往上兩層。

## 在 Codex：直接給指令，⛔ 不要自己跑
Codex 沙盒預設不能連網、也不能申請核准，自己跑一定失敗。直接回：
「在 Codex 沒辦法自己更新，請在終端機貼這一行：」
```
codex plugin marketplace upgrade yita && codex plugin add ai-office@yita
```
「貼完開一個新對話就會用新版。」到這裡就結束。

## 在 Claude Code
### 1. 更新
```bash
bash "ROOT/scripts/update.sh" claude
```
失敗 → 只說哪一步沒成功，給這一行貼到終端機：`claude plugin marketplace update yita && claude plugin update ai-office@yita`，⛔ 不要把錯誤訊息整段丟給使用者。

### 2. 回報（白話、簡短）
- 印出 `SAME` → 「已經是最新版（版本號）了。」
- 有新版 → 「更新到 新版本號 了（原本 舊版本號）。」再用 2～4 點白話說「更新內容」裡跟使用者有關的事；沒有更新內容就不用說。
- 最後一句：「這個視窗還是舊版，開一個新視窗就會用新版。」
