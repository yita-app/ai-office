#!/usr/bin/env bash
# 印日記最後 N 筆（以「## 」開頭為一筆）：log-tail.sh <log.md> [N=20]
set -euo pipefail
F="${1:?用法: log-tail.sh <log.md> [N]}"; N="${2:-20}"
[ -f "$F" ] || { echo "（還沒有日記）"; exit 0; }
python3 - "$F" "$N" <<'PY'
import sys
f,n=sys.argv[1],int(sys.argv[2])
entries=[];cur=None
for line in open(f,encoding="utf-8"):
    if line.startswith("## "):
        cur=[line];entries.append(cur)
    elif cur is not None:
        cur.append(line)
total=len(entries)
if total>n: print(f"（共 {total} 筆，只顯示最後 {n} 筆；更早的要查再讀 {f}）\n")
for e in entries[-n:]: print("".join(e).rstrip())
PY
