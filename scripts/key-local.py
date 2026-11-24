#!/usr/bin/env python3
"""本機鑰匙抽屜 ~/.ai-office/keys.env

  key-local.py set <名稱>      值從 stdin 讀（不放命令列）
  key-local.py list            只列名稱
  key-local.py delete <名稱>
"""
import os, re, shlex, sys

PATH = os.path.expanduser("~/.ai-office/keys.env")
NAME_RE = re.compile(r"^[A-Z][A-Z0-9_]*$")


def load():
    if not os.path.exists(PATH):
        return []
    return open(PATH, encoding="utf-8").read().splitlines()


def save(lines):
    os.makedirs(os.path.dirname(PATH), mode=0o700, exist_ok=True)
    fd = os.open(PATH, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + ("\n" if lines else ""))
    os.chmod(PATH, 0o600)


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    cmd = sys.argv[1]
    lines = load()
    if cmd == "list":
        names = [l.split("=", 1)[0] for l in lines if "=" in l and not l.startswith("#")]
        print("\n".join(names) if names else "（抽屜是空的）")
        return
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    name = sys.argv[2]
    if not NAME_RE.match(name):
        sys.exit(f"🔴 名稱「{name}」不合格：請用大寫英文、數字、底線，例 NOTION_TOKEN")
    lines = [l for l in lines if not l.startswith(name + "=")]
    if cmd == "set":
        value = sys.stdin.read().strip()
        if not value:
            sys.exit("🔴 沒收到鑰匙的值")
        lines.append(f"{name}={shlex.quote(value)}")
        save(lines)
        print(f"✅ 已存入本機抽屜：{name}")
    elif cmd == "delete":
        save(lines)
        print(f"✅ 已從本機抽屜移除：{name}")
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
