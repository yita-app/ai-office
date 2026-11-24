# 鑰匙放法：local（本機）

鑰匙存在這台電腦的 `~/.ai-office/keys.env`（只有自己讀得到，權限 600）。
這個檔案在辦公室資料夾**外面**，所以 `/sync` 永遠不會把它推上 GitHub。

下面的 `ROOT` 是 AI Office plugin 的根目錄。

## 存一把
值一律從 stdin 給，不要放在命令列參數：
```bash
python3 "ROOT/scripts/key-local.py" set 名稱 <<'EOF'
鑰匙的值
EOF
```

## 列出有哪些（只有名稱）
```bash
python3 "ROOT/scripts/key-local.py" list
```

## 刪除
```bash
python3 "ROOT/scripts/key-local.py" delete 名稱
```

## 存好後這次 session 馬上要用
開工時自動帶入的只有「當時」抽屜裡的鑰匙。剛存的這把，在同一個指令裡先載入：
```bash
set -a; . ~/.ai-office/keys.env; set +a; 你的指令
```
下次開 session 就會自動帶上。
