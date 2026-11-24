#!/usr/bin/env bash
# 開一間新辦公室：office-init.sh <目錄> <辦公室名稱>
# 建目錄 → 放範本 → git init → 第一次 commit → 確認這台電腦的設定卡與鑰匙抽屜
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="${1:?用法: office-init.sh <目錄> <辦公室名稱>}"
NAME="${2:?用法: office-init.sh <目錄> <辦公室名稱>}"
DIR="${DIR/#\~/$HOME}"

if [ -e "$DIR" ] && [ -n "$(ls -A "$DIR" 2>/dev/null)" ]; then
  echo "🔴 $DIR 已經存在而且不是空的，請換一個位置。" >&2; exit 1
fi

mkdir -p "$DIR/team" "$DIR/shared" "$DIR/docs" "$DIR/projects"
printf 'name=%s\n' "$NAME" > "$DIR/.ai-office"
sed "s/{{OFFICE_NAME}}/$(printf '%s' "$NAME" | sed 's/[&/\]/\\&/g')/" "$ROOT/templates/office/AGENTS.md" > "$DIR/AGENTS.md"
cp "$ROOT/templates/office/CLAUDE.md" "$DIR/CLAUDE.md"
cp "$ROOT/templates/office/team.md" "$DIR/team.md"
cp "$ROOT/templates/office/gitignore" "$DIR/.gitignore"
touch "$DIR/team/.gitkeep" "$DIR/shared/.gitkeep" "$DIR/docs/.gitkeep" "$DIR/projects/.gitkeep"

# 這台電腦的設定卡＋鑰匙抽屜（已經有就不動；寫不進去（例如 Codex 桌面版）就跳過，開工設定會補建）
CFG="$HOME/.ai-office"
{
  mkdir -p "$CFG" && chmod 700 "$CFG" &&
  { [ -f "$CFG/settings" ] || printf '# AI Office：這台電腦的設定\n# key_method = 鑰匙放法：local（本機）或 vault（金庫）\nkey_method=local\n' > "$CFG/settings"; } &&
  { [ -f "$CFG/keys.env" ] || { : > "$CFG/keys.env"; chmod 600 "$CFG/keys.env"; }; }
} 2>/dev/null || CFG_SKIPPED=1

cd "$DIR"
if git init -q -b main 2>/dev/null && git add -A 2>/dev/null && git commit -q -m "開辦公室：${NAME}" 2>/dev/null; then
  GIT_NOTE="已建 Git"
else
  GIT_NOTE="這裡不能用 Git，沒關係，檔案都存在電腦上"
fi
echo "✅ 辦公室已建好：${DIR}（${GIT_NOTE}）"
if [ -n "${CFG_SKIPPED:-}" ]; then
  echo "   這台電腦的設定卡等下次開工會自動建好"
else
  echo "   鑰匙放法：$(grep -m1 '^key_method=' "$CFG/settings" | cut -d= -f2-)"
fi
