# 更新內容
（新的寫在最上面；`/update` 會把比使用者舊版更新的段落念給他聽，所以寫白話。）

## 0.7.0
- 改叫 YITA AI Office，安裝來源搬到公開的 https://github.com/yita-app/ai-office ，不用 GitHub 帳號就能裝。
- 安裝指令變成 `ai-office@yita`；舊的 `ai-office@ai-office` 要換一次（看 README）。
- 拿掉 Codex 用不到的 yita 外掛（YITA 連線改到 chatgpt.com 接）。

## 0.6.5
- Codex 的 `$update` 改成直接給你一行指令貼到終端機（Codex 沙盒不能自己連網更新）。

## 0.6.4
- 新指令 `/update`（Codex 是 `$update`）：一句話更新 AI Office，並告訴你改了什麼。
- Codex 的 YITA 連線改成到 chatgpt.com 加兩個連接器（YITA Builder、YITA Desk）；終端機加的連線在 Codex 對話裡看不到。
- YITA 網站員工在 Codex 看不到工具時，會帶你去 chatgpt.com 連接。

## 0.6.3
