# YITA AI Office

多角色 AI 辦公室：雇員工、上班、互傳訊息、寫日記、存鑰匙、一鍵同步到 GitHub。
由 [YITA](https://yita.app/) 出品；辦公室裡的 YITA 網站員工可以幫你操作自己的 YITA 網站。
適用 Claude Code（桌面 App 的 Code 分頁，或終端機版 `claude`），也可以在 Codex 使用。

## 安裝（一次就好）

在終端機貼這兩行：
```bash
claude plugin marketplace add https://github.com/yita-app/ai-office
```
```bash
claude plugin install ai-office@yita
```

裝好後重開 Claude Code。以後要更新，打 `/update` 就好。

## 開始

1. 開一個 session，打 `/office-init`，取個名字：會自動建辦公室資料夾、建 Git，問你要不要開私人 GitHub repo。
2. 在辦公室裡打 `/hire`：從候選職位（秘書、行銷、廣告投放、業務、財務、網站管理、工程師）挑一位，幫他取名字。名單裡沒有的可以自訂。
3. 開一個新 session，打 `/role mia`：Mia 上班。

## 指令

| 指令 | 做什麼 |
|---|---|
| `/office-init` | 開一間新辦公室 |
| `/hire` | 雇一位員工：從候選職位挑一位（或自訂），幫他取名字 |
| `/rename-staff 舊 新` | 員工改名 |
| `/fire 名字` | 解僱：資料移到離職區保留（可以回聘），也可以選永久刪除 |
| `/role 名字` | 上班，例 `/role mia`（一位員工同一時間只在一個視窗上班） |
| `/key 名稱 值` | 存一把鑰匙（API key、token） |
| `/sync` | 存檔並推到 GitHub |
| `/update` | 把 AI Office 更新到最新版，並說這次改了什麼 |
| `/off` | 下班：自動寫日記＋存檔，再收起視窗（`/off 清空`＝清空對話、視窗留著） |

## 辦公室裡有什麼

```
我的辦公室/
├── .ai-office          ← 標記：這裡是一間辦公室
├── AGENTS.md           ← 整間辦公室自己的規則（正本，Claude 和 Codex 都讀）
├── CLAUDE.md           ← 只有一行 @AGENTS.md，指向正本
├── team.md             ← 員工名單
├── team/
│   └── mia/
│       ├── card.md     ← 名片（角色定義）
│       └── log.md      ← 工作日記
├── alumni/             ← 離職員工（資料保留，可以回聘）
├── projects/           ← 案子：一案一個資料夾
├── shared/             ← 不屬於任何案子的共用東西
└── docs/               ← 長文件，用到才讀
```

## 候選職位

放在 `roles/`，一個職位一份（`編號-英文.md`，開頭寫 `title` 和 `summary`）。雇用時會把內容複製成員工的名片，之後改名片不會影響名單；改名單只影響之後新雇的人。

## 鑰匙放哪

鑰匙**不放在辦公室裡**，所以永遠不會被推上 GitHub。
每台電腦有一張設定卡 `~/.ai-office/settings`，決定鑰匙放法：

| 放法 | 設定 | 鑰匙在哪 |
|---|---|---|
| 本機（預設） | `key_method=local` | `~/.ai-office/keys.env` |
| 金庫 | `key_method=vault` | 雲端金庫（需要 `vault-get`／`vault-put`／`vault-list`） |

每次開 session，鑰匙會自動放進環境變數，員工直接用 `$名稱`。
要新增其他放法：在 `key-methods/` 放一份說明（例 `1password.md`），設定卡改成 `key_method=1password`。

## 在 Codex 使用（試驗中）

辦公室的資料（名單、名片、日記、AGENTS.md）兩邊共用：先裝哪邊都可以，同一間辦公室兩邊都能進。

### 第一次安裝（在終端機打，一次就好）
```bash
codex plugin marketplace add https://github.com/yita-app/ai-office
```
```bash
codex plugin add ai-office@yita
```
要用 YITA 網站的話，到 chatgpt.com 加兩個連接器（Codex 桌面版只認帳號層級的連線）：
1. 打開 chatgpt.com →「外掛程式」→「新增」→「新增自訂 MCP 伺服器」
2. 加 YITA Builder：網址 `https://builder.yita.dev/mcp`，驗證選 OAuth，勾風險說明，建立
3. 加 YITA Desk：網址 `https://builder.yita.dev/desk/mcp`，其他同上
4. 兩個各按一次「連接」，用你在 YITA 登記的 Google 帳號登入，按「繼續」
5. 回 Codex 開新對話，工具才會出現
（終端機找不到 `codex`：它在 `/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex`。）

### 更新到新版
在終端機貼這一行（Codex 沙盒不能自己更新；在 Codex 打 `$update` 也會給你這一行）：
```bash
codex plugin marketplace upgrade yita && codex plugin add ai-office@yita
```

### 之後在桌面版使用
1. 建一個空資料夾，在 Codex 把它開成專案。第一次問要不要信任 AI Office 的開工設定，按信任。
2. 開新對話打 `$office-init` 開辦公室（辦公室就是這個專案資料夾）。
3. `$hire` 雇人、開新對話 `$role 名字` 上班。

### Codex 目前的限制
- Git：桌面版會鎖住 `.git`，所以不建 Git、不推 GitHub，檔案存在電腦上；要備份就在 Claude 或終端機打 `/sync`。
- 員工之間互傳訊息、自動改對話標題：暫時不能用。
- 開工不會自動帶鑰匙，要用時員工會照放法說明去拿。
