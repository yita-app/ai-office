#!/usr/bin/env bash
# 讓 Codex 也能用 AI Office 的指令（/hire、/role…）
#
# 做兩件事：
#   1. 記下 AI Office 程式的位置：~/.ai-office/root
#   2. 在 Codex 會找的使用者 skill 資料夾 ~/.agents/skills/ 放捷徑（ai-office-<指令>）
# 已經有的捷徑會更新成這一份，不會動其他 skill。
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$HOME/.ai-office"
DEST="$HOME/.agents/skills"

mkdir -p "$CFG" "$DEST"
chmod 700 "$CFG"
printf '%s\n' "$ROOT" > "$CFG/root"
[ -f "$CFG/settings" ] || printf '# AI Office：這台電腦的設定\n# key_method = 鑰匙放法：local（本機）或 vault（金庫）\nkey_method=local\n' > "$CFG/settings"

for d in "$ROOT"/skills/*/; do
  n="$(basename "$d")"
  link="$DEST/ai-office-$n"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "⚠️  $link 已存在而且不是捷徑，跳過" >&2; continue
  fi
  ln -sfn "${d%/}" "$link"
done

echo "✅ Codex 設定完成"
echo "   程式位置：${ROOT}（記在 ~/.ai-office/root）"
echo "   指令捷徑：$DEST/ai-office-*"
ls -1 "$DEST" | grep '^ai-office-' | sed 's/^/     /'
echo "   請完全關掉 Codex 再重開，指令才會出現。"
