#!/usr/bin/env bash
# /sync 的前置檢查（在辦公室根目錄執行）：大小上限、疑似鑰匙、列出變更
set -uo pipefail
[ -f .ai-office ] || { echo "🔴 請在辦公室根目錄執行（找不到 .ai-office）" >&2; exit 1; }
WARN=0

# 1. 名片與辦公室規則的大小上限（開工會讀的東西不能變胖）
size() { wc -c < "$1" | tr -d ' '; }
if [ -f AGENTS.md ] && [ "$(size AGENTS.md)" -gt 4000 ]; then
  echo "⚠️  AGENTS.md 有 $(size AGENTS.md) bytes，超過上限 4000：請把長內容搬到 docs/"; WARN=1
fi
for c in team/*/card.md; do
  [ -f "$c" ] || continue
  if [ "$(size "$c")" -gt 3000 ]; then echo "⚠️  $c 有 $(size "$c") bytes，超過上限 3000：請把長內容搬到 docs/"; WARN=1; fi
done

# 2. 疑似鑰匙（常見格式），出現就擋
HITS="$(git ls-files -mo --exclude-standard -z | xargs -0 grep -I -l -E \
  'sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|gho_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|AIza[0-9A-Za-z_-]{35}' 2>/dev/null)"
if [ -n "$HITS" ]; then
  echo "🔴 這些檔案裡疑似有鑰匙，先不要推："; echo "$HITS" | sed 's/^/   /'; exit 3
fi

# 3. 列出變更
echo "── 變更 ──"
git status --short
[ -n "$(git status --porcelain)" ] || echo "（沒有變更）"
echo "── 遠端 ──"
git remote -v | head -2
[ -n "$(git remote)" ] || echo "（還沒有設定 GitHub）"
exit $WARN
