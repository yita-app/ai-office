---
name: sync
description: 把 AI Office 辦公室的變動存檔並推到 GitHub（檢查 → commit → pull → push）；這個環境不能用 Git 時，檔案留在電腦上就算存好。使用者說「同步／存檔／推上去／sync」時使用。
---

# 同步到 GitHub

`ROOT`＝AI Office 程式的位置：本 skill 的 Base directory（SKILL.md 所在資料夾）往上兩層；如果那裡沒有 `scripts/team.sh`（例如在 Codex），改用 `cat ~/.ai-office/root` 印出的路徑。先 `cd` 到辦公室根目錄。辦公室根目錄＝`bash "ROOT/scripts/find-office.sh"` 印出的路徑（只認 `.ai-office` 檔案，不會誤認 `~/.ai-office` 設定資料夾；沒印東西＝不在辦公室裡）。

🧭 **原則：檔案寫進辦公室資料夾就已經存好了**（在電腦上，不會不見）。Git 只是再存一份歷史、推上雲端。
能用 Git 就做到底；不能用（例如 Codex 沙盒擋 `.git`、沒有網路、核准被拒）就停在能做到的那一步，⛔ 不要硬試、不要繞路、不要把錯誤訊息整段丟給使用者。

## 1. 檢查
```bash
bash "ROOT/scripts/sync-check.sh"
```
- 退出碼 3（疑似鑰匙）：⛔ 停下來，把檔案列給使用者看，請他確認；是鑰匙就從檔案移除，改用 `/key` 存。
- 退出碼 1（名片或 AGENTS.md 太大）：提醒使用者，建議把長內容搬到 `docs/`；使用者說先推也可以，繼續。
- 沒有變更：告訴使用者「沒有新變更」，但仍執行第 3 步確認有沒有遠端的新東西要拉。

## 2. Commit
看 `git status` 與 `git diff --stat`，用一句繁體中文寫 commit 訊息，說明這次主要改了什麼（例：「mia：新增小紅書貼文草稿；dex：更新部署紀錄」）。
```bash
git add -A && git commit -m "<訊息>"
```

## 3. 拉＋推
```bash
git pull --rebase && git push
```
- 還沒設定 GitHub：照 `/office-init` 第 3 步的方式帶使用者接上（要他同意才開 repo）。
- 有衝突：自己看衝突內容合併；日記（log.md）兩邊都保留、照時間排。合不了才問使用者。

## Git 不能用的時候
- `git add`／`git commit` 被擋（例：`.git/index.lock` Operation not permitted、`.git` 唯讀）→ 停在這裡，回報：「檔案都存在電腦上了。這裡不能用 Git，下次在可以用 Git 的地方（例如 Claude Code）打 `/sync` 就會一起推上去。」
- commit 成功、但 pull／push 連不到網路或被擋 → 回報：「已在電腦上存好一個版本（commit 編號），還沒推上 GitHub；下次在有網路的地方打 `/sync` 會一起推。」
- 這個環境可以向使用者申請核准 → 照環境的方式申請一次，使用者拒絕就照上面兩種回報。

## 4. 回報
一行：做到哪一步就報哪一步（電腦上／本機版本／已推上 GitHub）。有成功 commit 才附 commit 訊息；有成功 push 才附 GitHub 網址。
