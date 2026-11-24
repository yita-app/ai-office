---
name: office-init
description: 開一間新的 AI Office 辦公室：取名字就好，自動建資料夾（Claude 會帶使用者接私人 GitHub repo 並把 session 移過去；Codex 給一行指令貼到終端機）。使用者說「開辦公室／建立 AI Office／office init」時使用。
---

# 開一間新辦公室

`ROOT`＝AI Office 程式的位置：本 skill 的 Base directory（SKILL.md 所在資料夾）往上兩層；如果那裡沒有 `scripts/team.sh`，改用 `cat ~/.ai-office/root` 印出的路徑。

使用者只需要取名字，⛔ 不要叫他自己建資料夾、選位置。

## 1. 問名字
- 只問一件事：辦公室名稱（例：「好事辦公室」）。
- 位置自動決定：`~/英文短名`（從名稱想一個小寫英文短名，例「好事辦公室」→ `~/haoshi-office`）。已經存在就加 `-2`。跟使用者說一句會放在哪就好，不用等他確認。
- 如果目前就在一間辦公室裡（`bash "ROOT/scripts/find-office.sh"` 有印出路徑），先告訴使用者，確認真的要再開一間。

## 2. 建辦公室

### 在 Claude Code
```bash
bash "ROOT/scripts/office-init.sh" "<目錄>" "<辦公室名稱>"
```
失敗就照錯誤訊息處理。成功 → 第 3 步。

### 在 Codex
Codex 桌面版不能在目前資料夾以外建檔案，也不能把對話換到別的資料夾，所以**給使用者一行指令**貼到終端機（把 ROOT 換成實際路徑、目錄和名稱填好）：
```bash
bash "ROOT/scripts/office-init.sh" "<目錄>" "<辦公室名稱>" && codex app "<目錄>"
```
跟使用者說：
> 請把這行貼到終端機執行。它會建好辦公室，並用 Codex 打開它。打開後開一個新對話，打 `$hire` 雇第一位員工。
> 第一次如果問要不要信任 AI Office 的開工設定，按「信任」。

（如果這個 Codex 對話其實有權限、直接跑 office-init.sh 成功了，就只給 `codex app "<目錄>"` 那一段。）
Codex 到這裡就結束，⛔ 不做第 3、4 步。

## 3. 接上 GitHub（只在 Claude，私人 repo）
先看這台電腦有沒有登入 GitHub：
```bash
gh auth status
```
- **已登入**：告訴使用者會在他的帳號開一個**私人** repo，名稱用目錄名，**等他同意**後：
  ```bash
  cd "<目錄>" && gh repo create "<repo 名稱>" --private --source . --push
  ```
- **沒有 `gh` 指令**：請使用者在終端機自己跑 `brew install gh`（Mac），裝好再繼續。
- **有 `gh` 但沒登入**：請使用者在終端機自己跑 `gh auth login`，照畫面選 GitHub.com → HTTPS → 用瀏覽器登入。⛔ 不要替他輸入密碼或驗證碼。登入好再繼續。
- **不想用 `gh`**：請他到 github.com 按 New repository，選 **Private**，不要勾任何初始檔案，建好把網址給你，然後：
  ```bash
  cd "<目錄>" && git remote add origin "<網址>" && git push -u origin main
  ```

使用者也可以選擇先不接 GitHub，之後 `/sync` 時再接。

## 4. 把 session 移過去（只在 Claude）
- 有 `change_directory` 工具（桌面 App）：用它移到新目錄。
- 沒有（終端機）：請使用者跑 `cd "<目錄>" && claude`。

## 5. 收尾
用三行告訴使用者：
- 辦公室在哪、GitHub 網址（如果有）
- 鑰匙放法（看 `~/.ai-office/settings`）
- 下一步：打 `/hire` 雇第一位員工
