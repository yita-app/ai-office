#!/usr/bin/env bash
# 員工管理（在辦公室根目錄執行）
#   team.sh hire   <名字> [職位]
#   team.sh rename <舊名字> <新名字>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f .ai-office ] || { echo "🔴 請在辦公室根目錄執行（找不到 .ai-office）" >&2; exit 1; }

valid() {
  # 只能用英文字母（可用 - 連接），不能有數字
  [[ "$1" =~ ^[a-z]([a-z-]*[a-z])?$ ]] || {
    echo "🔴 名字「$1」不合格：只能用英文字母（可以用 - 連接），不能有數字" >&2; exit 1; }
}
display() { python3 -c 'import sys;n=sys.argv[1];print(n[:1].upper()+n[1:])' "$1"; }
today() { date '+%Y-%m-%d %H:%M'; }

case "${1:-}" in
  roles)
    # 列出候選職位：編號｜職位｜做什麼
    python3 - "$ROOT/roles" <<'PY'
import sys,os,re
d=sys.argv[1]
for f in sorted(os.listdir(d), key=lambda x:int(x.split("-")[0]) if x.split("-")[0].isdigit() else 999):
    if not f.endswith(".md"): continue
    t=open(os.path.join(d,f),encoding="utf-8").read()
    m=dict(re.findall(r"^(title|summary):\s*(.+)$", t.split("---")[1], re.M)) if t.startswith("---") else {}
    print(f"{f.split('-')[0]}｜{m.get('title','?')}｜{m.get('summary','')}")
PY
    ;;
  hire)
    N="${2:?用法: team.sh hire <名字> [職位] ｜ team.sh hire <名字> --role <編號>}"
    valid "$N"
    [ ! -e "team/$N" ] || { echo "🔴 team/$N 已經存在" >&2; exit 1; }
    ! { [ -e "alumni/$N" ] || ls -d "alumni/$N"-* >/dev/null 2>&1; } || { echo "🔴 $N 以前在這裡工作過（在離職區）：要讓他回來用 team.sh rehire ${N}，要雇新人請換個名字" >&2; exit 1; }
    D="$(display "$N")"
    if [ "${3:-}" = "--role" ]; then
      R="${4:?請給職位編號，例：--role 2（先用 team.sh roles 看名單）}"
      RF="$(ls "$ROOT/roles/$R"-*.md 2>/dev/null | head -1 || true)"
      [ -n "$RF" ] || { echo "🔴 找不到職位編號 ${R}（用 team.sh roles 看名單）" >&2; exit 1; }
      mkdir -p "team/$N"
      T="$(python3 - "$RF" "team/$N/card.md" "$D" <<'PY'
import sys,re
src,dst,name=sys.argv[1:]
t=open(src,encoding="utf-8").read()
_,fm,body=t.split("---",2)
m=dict(re.findall(r"^(title|summary):\s*(.+)$", fm, re.M))
open(dst,"w",encoding="utf-8").write(f"# {name}｜{m['title']}\n\n"+body.lstrip())
print(m["title"]+"\t"+m.get("summary",""))
PY
)"
      S="${T#*$'\t'}"; T="${T%%$'\t'*}"
    else
      T="${3:-待定}"; S=""
      mkdir -p "team/$N"
      python3 - "$ROOT/templates/card.md" "team/$N/card.md" "$D" "$T" <<'PY'
import sys
src,dst,name,title=sys.argv[1:]
open(dst,"w",encoding="utf-8").write(open(src,encoding="utf-8").read().replace("{{NAME}}",name).replace("{{TITLE}}",title))
PY
    fi
    printf '# %s 的工作日記\n\n## %s｜系統\n- 到職，職位：%s。\n' "$D" "$(today)" "$T" > "team/$N/log.md"
    printf '| %s | %s | %s |\n' "$N" "$T" "$S" >> team.md
    echo "✅ 已雇用 ${D}（${T}）：team/$N/card.md、team/$N/log.md，名單已更新"
    ;;
  rename)
    O="${2:?用法: team.sh rename <舊> <新>}"; N="${3:?用法: team.sh rename <舊> <新>}"
    valid "$N"
    [ -d "team/$O" ] || { echo "🔴 找不到 team/$O" >&2; exit 1; }
    [ ! -e "team/$N" ] || { echo "🔴 team/$N 已經存在" >&2; exit 1; }
    if git ls-files --error-unmatch "team/$O" >/dev/null 2>&1; then git mv "team/$O" "team/$N"; else mv "team/$O" "team/$N"; fi
    python3 - "$O" "$N" <<'PY'
import sys,re
o,n=sys.argv[1:]
cap=lambda s:s[:1].upper()+s[1:]
# 名單：名字欄
t=open("team.md",encoding="utf-8").read()
t=re.sub(r"^\|\s*"+re.escape(o)+r"\s*\|", "| "+n+" |", t, flags=re.M)
open("team.md","w",encoding="utf-8").write(t)
# 名片：第一行標題
p=f"team/{n}/card.md"
c=open(p,encoding="utf-8").read().split("\n",1)
c[0]=re.sub(r"^#\s*"+re.escape(cap(o))+r"(?=\s*｜|\s*$)", "# "+cap(n), c[0], flags=re.I)
c[0]=re.sub(r"^#\s*"+re.escape(o)+r"(?=\s*｜|\s*$)", "# "+cap(n), c[0], flags=re.I)
open(p,"w",encoding="utf-8").write("\n".join(c))
PY
    printf '\n## %s｜系統\n- 改名：%s → %s（之前的紀錄都在這本日記裡）\n' "$(today)" "$O" "$N" >> "team/$N/log.md"
    echo "✅ 已改名 $O → ${N}（資料夾、名單、名片標題、日記都已更新）"
    ;;
  fire)
    # 解僱＝移到離職區 alumni/<名字>/，從名單拿掉；資料都留著，之後可以回聘
    N="${2:?用法: team.sh fire <名字>}"
    [ -d "team/$N" ] || { echo "🔴 找不到 team/$N" >&2; exit 1; }
    mkdir -p alumni
    DEST="alumni/$N"; [ ! -e "$DEST" ] || DEST="alumni/$N-$(date +%Y%m%d-%H%M)"
    printf '\n## %s｜系統\n- 離職（資料保留在離職區，可以回聘）。\n' "$(today)" >> "team/$N/log.md"
    if git ls-files --error-unmatch "team/$N" >/dev/null 2>&1; then git mv "team/$N" "$DEST"; else mv "team/$N" "$DEST"; fi
    python3 - "$N" "$DEST" <<'PY'
import sys,re
n,dest=sys.argv[1:]
t=open("team.md",encoding="utf-8").read()
row=re.search(r"^\|\s*"+re.escape(n)+r"\s*\|.*$", t, re.M)
t=re.sub(r"^\|\s*"+re.escape(n)+r"\s*\|.*\n?", "", t, flags=re.M)
open("team.md","w",encoding="utf-8").write(t)
if row: open(dest+"/team-row.txt","w",encoding="utf-8").write(row.group(0)+"\n")
PY
    echo "✅ $(display "$N") 已離職：資料移到 $DEST/，名單已拿掉"
    ;;
  rehire)
    # 回聘：從離職區搬回來
    N="${2:?用法: team.sh rehire <名字>}"
    [ ! -e "team/$N" ] || { echo "🔴 team/$N 已經在職" >&2; exit 1; }
    SRC="$(ls -d "alumni/$N" "alumni/$N"-* 2>/dev/null | tail -1 || true)"
    [ -n "$SRC" ] || { echo "🔴 離職區找不到 $N" >&2; exit 1; }
    if git ls-files --error-unmatch "$SRC" >/dev/null 2>&1; then git mv "$SRC" "team/$N"; else mv "$SRC" "team/$N"; fi
    if [ -f "team/$N/team-row.txt" ]; then cat "team/$N/team-row.txt" >> team.md; rm -f "team/$N/team-row.txt"; git rm -q --cached "team/$N/team-row.txt" 2>/dev/null || true
    else printf '| %s | | |\n' "$N" >> team.md; fi
    printf '\n## %s｜系統\n- 回聘，之前的日記都還在。\n' "$(today)" >> "team/$N/log.md"
    echo "✅ $(display "$N") 回來上班了：名片和日記都還在，名單已加回"
    ;;
  alumni)
    ls -1 alumni 2>/dev/null | grep -v '^\.' || echo "（離職區是空的）"
    ;;
  *) echo "用法: team.sh hire <名字> [職位] ｜ rename <舊> <新> ｜ fire <名字> ｜ rehire <名字> ｜ alumni" >&2; exit 2 ;;
esac
