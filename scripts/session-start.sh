#!/usr/bin/env bash
# AI Office 開工腳本（SessionStart hook）
#
# 只在「辦公室資料夾」裡做事（往上找得到 .ai-office 標記檔）；其他資料夾完全不出聲。
# 做三件事：
#   1. 把共通規則（rules.md）交給這個 session
#   2. 列出團隊名單（只有名字＋職位）
#   3. 把鑰匙放進環境變數，並告訴 session 有哪幾把（只給名字、絕不給值）

set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG_DIR="$HOME/.ai-office"

# hook 從 stdin 收到 JSON，裡面有 cwd；拿不到就用目前目錄
INPUT="$(cat 2>/dev/null || true)"
CWD="$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("cwd",""))
except Exception: print("")' 2>/dev/null)"
[ -n "$CWD" ] || CWD="$PWD"

# 往上找辦公室根目錄
OFFICE=""
d="$CWD"
while [ -n "$d" ] && [ "$d" != "/" ]; do
  if [ -f "$d/.ai-office" ]; then OFFICE="$d"; break; fi
  d="$(dirname "$d")"
done
[ -n "$OFFICE" ] || exit 0

OFFICE_NAME="$(grep -m1 '^name=' "$OFFICE/.ai-office" 2>/dev/null | cut -d= -f2-)"
[ -n "$OFFICE_NAME" ] || OFFICE_NAME="$(basename "$OFFICE")"

# ── 這台電腦的設定卡（沒有就建一張，預設「本機」）──
mkdir -p "$CFG_DIR" && chmod 700 "$CFG_DIR"
if [ ! -f "$CFG_DIR/settings" ]; then
  printf '# AI Office：這台電腦的設定\n# key_method = 鑰匙放法：local（本機）或 vault（金庫）\nkey_method=local\n' > "$CFG_DIR/settings"
fi
METHOD="$(grep -m1 '^key_method=' "$CFG_DIR/settings" | cut -d= -f2- | tr -d '[:space:]')"
[ -n "$METHOD" ] || METHOD=local

# ── 鑰匙：放進環境變數 ──
KEY_NAMES=""
KEY_NOTE=""
case "$METHOD" in
  local)
    KEYS="$CFG_DIR/keys.env"
    [ -f "$KEYS" ] || { : > "$KEYS"; chmod 600 "$KEYS"; }
    KEY_NAMES="$(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$KEYS" | cut -d= -f1 | paste -sd'、' -)"
    if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
      printf 'set -a; . "%s"; set +a\n' "$KEYS" >> "$CLAUDE_ENV_FILE"
    else
      KEY_NOTE="（這個環境沒辦法自動帶入；要用時先跑：set -a; . ~/.ai-office/keys.env; set +a）"
    fi
    ;;
  vault)
    PREFIX="$(grep -m1 '^vault_prefix=' "$CFG_DIR/settings" | cut -d= -f2- | tr -d '[:space:]')"
    [ -n "$PREFIX" ] || PREFIX=ai-office
    if command -v vault-list >/dev/null 2>&1 && command -v vault-get >/dev/null 2>&1; then
      NAMES="$(vault-list 2>/dev/null | python3 -c '
import json,sys
p=sys.argv[1]+"/"
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
for s in d.get("secrets",[]):
    n=s.get("name","")
    if n.startswith(p): print(n[len(p):])
' "$PREFIX")"
      OUT=""
      LOADED=""
      while IFS= read -r n; do
        [ -n "$n" ] || continue
        case "$n" in *[!A-Za-z0-9_]*|[0-9]*) continue;; esac
        v="$(vault-get "$PREFIX/$n" 2>/dev/null)" || continue
        OUT="${OUT}export ${n}=$(printf '%s' "$v" | python3 -c 'import shlex,sys;print(shlex.quote(sys.stdin.read()))')"$'\n'
        LOADED="${LOADED:+${LOADED}、}$n"
      done <<< "$NAMES"
      KEY_NAMES="$LOADED"
      if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
        [ -n "$OUT" ] && printf '%s' "$OUT" >> "$CLAUDE_ENV_FILE"
      else
        KEY_NOTE="（這個環境沒辦法自動帶入；要用時跑：export 名稱=\$(vault-get $PREFIX/名稱)）"
      fi
    else
      KEY_NOTE="（設定是金庫，但這台電腦找不到 vault-get／vault-list）"
    fi
    ;;
  *)
    KEY_NOTE="（設定卡寫的鑰匙放法「${METHOD}」，請照 $ROOT/key-methods/$METHOD.md 操作）"
    ;;
esac

# ── 團隊名單（只取名字＋職位兩欄）──
TEAM=""
if [ -f "$OFFICE/team.md" ]; then
  TEAM="$(python3 - "$OFFICE/team.md" <<'PY'
import sys
rows=[]
for line in open(sys.argv[1], encoding="utf-8"):
    c=[x.strip() for x in line.strip().strip("|").split("|")]
    if len(c)>=2 and c[0] and c[0] not in ("名字",) and not set(c[0])<=set("-: "):
        rows.append(f"{c[0]}（{c[1]}）" if c[1] else c[0])
print("、".join(rows))
PY
)"
fi

# ── 交給 session 的開工訊息 ──
echo "【AI Office：${OFFICE_NAME}】辦公室根目錄：$OFFICE"
echo "團隊：${TEAM:-（還沒有員工，用 /hire 名字 雇第一位）}"
echo "可用鑰匙（已放進環境變數，直接用 \$名稱）：${KEY_NAMES:-（沒有）}${KEY_NOTE}"
echo "鑰匙放法：$METHOD"
echo
cat "$ROOT/rules.md"
exit 0
