# 鑰匙放法：vault（金庫）

鑰匙存在雲端金庫，用 `vault-get`／`vault-put`／`vault-list` 這三個指令存取。
每台電腦要先有自己的金庫裝置卡，這三個指令才能用（裝置卡怎麼辦，問金庫管理員）。

AI Office 只用金庫裡的一個分類，預設是 `ai-office`（可在 `~/.ai-office/settings` 用 `vault_prefix=` 改）。
金庫裡的名稱是 `分類/名稱`，例 `ai-office/NOTION_TOKEN`；開工時會把這個分類底下的每一把都帶進環境變數，變數名稱就是 `/` 後面那段。

## 存一把
值一律從 stdin 給，不要放在命令列參數：
```bash
vault-put ai-office/名稱 - ai-office <<'EOF'
鑰匙的值
EOF
```

## 列出有哪些（只有名稱）
```bash
vault-list | python3 -c 'import json,sys;[print(s["name"].split("/",1)[1]) for s in json.load(sys.stdin)["secrets"] if s["name"].startswith("ai-office/")]'
```

## 存好後這次 session 馬上要用
```bash
export 名稱="$(vault-get ai-office/名稱)"; 你的指令
```
下次開 session 就會自動帶上。

## 金庫裡已經有、但不在 ai-office 分類的鑰匙
不用搬。需要時直接 `vault-get 原本的完整名稱` 取用即可。
