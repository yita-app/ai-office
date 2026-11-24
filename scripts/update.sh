#!/bin/bash
# 更新 AI Office 外掛到最新版，印出新舊版本和這次改了什麼。
# 用法：bash update.sh claude|codex
set -u
APP="${1:-}"
case "$APP" in
  claude) MP="$HOME/.claude/plugins/marketplaces/yita" ;;
  codex)  MP="$HOME/.codex/.tmp/marketplaces/yita" ;;
  *) echo "用法：update.sh claude|codex" >&2; exit 2 ;;
esac

ver() { sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$MP/.claude-plugin/plugin.json" 2>/dev/null | head -1; }
OLD="$(ver)"

if [ "$APP" = claude ]; then
  claude plugin marketplace update yita && claude plugin update ai-office@yita || exit 1
else
  codex plugin marketplace upgrade yita && codex plugin add ai-office@yita || exit 1
fi

NEW="$(ver)"
echo "OLD=$OLD"
echo "NEW=$NEW"
if [ -n "$OLD" ] && [ "$OLD" = "$NEW" ]; then
  echo "SAME"
  exit 0
fi
# 印出比舊版新的更新內容
if [ -f "$MP/CHANGELOG.md" ]; then
  echo "--- 更新內容 ---"
  awk -v old="$OLD" '/^## /{ if ($2==old) exit; p=1 } p' "$MP/CHANGELOG.md"
fi
