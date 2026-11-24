---
name: key
description: 存、列出或刪除 AI Office 的鑰匙（API key、token）。使用者給你一把鑰匙、或說「存鑰匙／key」時使用。用法：/key 名稱 值、/key list、/key delete 名稱
---

# 鑰匙

`ROOT`＝AI Office 程式的位置：本 skill 的 Base directory（SKILL.md 所在資料夾）往上兩層；如果那裡沒有 `scripts/team.sh`（例如在 Codex），改用 `cat ~/.ai-office/root` 印出的路徑。

## 1. 看這台電腦用哪種放法
```bash
grep '^key_method=' ~/.ai-office/settings 2>/dev/null || echo key_method=local
```
然後讀 `ROOT/key-methods/<放法>.md`，照裡面的做法操作。
找不到那份說明 → 告訴使用者這台電腦設定的放法不認得，請他確認 `~/.ai-office/settings`。

## 2. 名稱
- 用大寫英文＋底線，例 `NOTION_TOKEN`、`CLOUDFLARE_API_TOKEN`。
- 使用者沒給名稱：依服務幫他取一個，告訴他取了什麼。

## 3. 存
- 照放法說明存，值一律從 stdin 給。
- ⛔ 存完不要把值印出來、不要寫進辦公室裡的任何檔案、不要重複貼在回覆裡。
- 回報：「已存好 `名稱`，下次開 session 會自動帶上」。

## 4. 列出／刪除
- `list`：只列名稱。
- `delete`：先跟使用者確認名稱再刪。
