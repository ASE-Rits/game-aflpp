#!/usr/bin/env python3
import subprocess
import asyncio
import sys
import yaml
from pathlib import Path

def run(cmd, check=True):
    """シェルコマンド実行用ラッパ"""
    return subprocess.run(cmd, shell=isinstance(cmd, str), check=check)

def tmux(*args, check=True):
    """tmux コマンド用ラッパ"""
    return subprocess.run(["tmux", *args], check=check)

def tmux_session_exists(session: str) -> bool:
    result = subprocess.run(["tmux", "has-session", "-t", session],
                            stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL)
    return result.returncode == 0

def prepare_scripts():
    scripts = [
        "/game/host/kit/run_instance.sh",
    ]
    for s in scripts:
        if Path(s).exists():
            run(["chmod", "+x", s], check=False)

def ensure_session(session: str):
    """tmux セッションが無ければ作る"""
    if not tmux_session_exists(session):
        # 最初の window 名は "main" にしておく（あとで増やしていく）
        tmux("new-session", "-d", "-s", session, "-n", "main", check=True)

def window_exists(session: str, window_name: str) -> bool:
    """その session 内に指定 window 名があるかチェック"""
    result = subprocess.run(
        ["tmux", "list-windows", "-F", "#{window_name}", "-t", session],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    if result.returncode != 0:
        return False
    names = result.stdout.strip().splitlines()
    return window_name in names

def ensure_window(session: str, window_name: str):
    """指定 window が無ければ作成"""
    if not window_exists(session, window_name):
        tmux("new-window", "-t", session, "-n", window_name)

async def run_job(session: str, job: dict):
    name = job.get("name", "noname")
    window = job.get("window", name)
    delay = int(job.get("delay_sec", 0))
    cmd = job["cmd"]

    print(f"[{name}] wait {delay} sec, then run on window '{window}': {cmd}")
    await asyncio.sleep(delay)

    # window を用意
    ensure_window(session, window)

    # コマンド投入
    # bash -lc を挟むと PATH やエイリアスの有効化などがしやすい
    tmux(
        "send-keys",
        "-t",
        f"{session}:{window}",
        f"echo '[{name}] start: {cmd}'",  # ログ用
        "C-m",
    )
    tmux(
        "send-keys",
        "-t",
        f"{session}:{window}",
        f"bash -lc '{cmd}'",
        "C-m",
    )

    print(f"[{name}] started")

async def main(config_path: str):
    data = yaml.safe_load(Path(config_path).read_text())
    session = data.get("session", "jobsession")
    jobs = data.get("jobs", [])

    if not jobs:
        print("jobs が定義されていません")
        return

    # スクリプトの実行権限を確認
    prepare_scripts()

    # tmux セッションを準備
    ensure_session(session)
    print(f"tmux session '{session}' ready")

    # ジョブを並列にスケジューリング
    tasks = [run_job(session, job) for job in jobs]
    await asyncio.gather(*tasks)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: job_runner.py jobs.yaml")
        sys.exit(1)
    asyncio.run(main(sys.argv[1]))
