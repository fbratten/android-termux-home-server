from __future__ import annotations

from datetime import datetime
from pathlib import Path
import json
import platform
import socket
import subprocess

BASE_DIR = Path(__file__).resolve().parent
STATUS_FILE = BASE_DIR / "status.json"


def run_command(command: list[str], timeout: int = 5) -> dict:
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=timeout, check=False)
        return {"ok": result.returncode == 0, "stdout": result.stdout.strip(), "stderr": result.stderr.strip(), "returncode": result.returncode}
    except Exception as exc:
        return {"ok": False, "stdout": "", "stderr": str(exc), "returncode": -1}


def get_battery() -> dict:
    result = run_command(["termux-battery-status"], timeout=5)
    if not result["ok"] or not result["stdout"]:
        return {"available": False, "error": result["stderr"] or "No battery output"}
    try:
        data = json.loads(result["stdout"])
        data["available"] = True
        return data
    except json.JSONDecodeError:
        return {"available": False, "error": "Invalid JSON from termux-battery-status", "raw": result["stdout"]}


def get_storage() -> dict:
    result = run_command(["df", "-h", str(BASE_DIR)], timeout=5)
    return {"available": result["ok"], "raw": result["stdout"] if result["ok"] else result["stderr"]}


def get_ip() -> str:
    result = run_command(["ip", "-4", "addr", "show", "wlan0"], timeout=5)
    if result["ok"]:
        return result["stdout"]
    return "unknown"


def collect() -> dict:
    return {
        "collected_at": datetime.now().isoformat(),
        "node": "android-termux-home-server",
        "hostname": socket.gethostname(),
        "platform": platform.platform(),
        "python": platform.python_version(),
        "battery": get_battery(),
        "storage": get_storage(),
        "network": {"wlan0": get_ip()},
    }


def main() -> None:
    status = collect()
    STATUS_FILE.write_text(json.dumps(status, indent=2), encoding="utf-8")
    print(f"Wrote {STATUS_FILE}")


if __name__ == "__main__":
    main()
