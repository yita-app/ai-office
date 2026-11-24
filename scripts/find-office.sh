#!/usr/bin/env bash
# 印出辦公室根目錄：從目前目錄（或第 1 個參數）往上找「.ai-office 檔案」。
# ⚠️ 只認檔案：~/.ai-office 是這台電腦的設定「資料夾」，不是辦公室。
# 找不到 → 什麼都不印、退出 1。
d="${1:-$PWD}"
while [ -n "$d" ] && [ "$d" != "/" ]; do
  if [ -f "$d/.ai-office" ]; then echo "$d"; exit 0; fi
  d="$(dirname "$d")"
done
exit 1
