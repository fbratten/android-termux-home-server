from __future__ import annotations

from datetime import datetime
from pathlib import Path
import json
import subprocess
import urllib.request

BASE_DIR = Path(__file__).resolve().parent
BASE_URL = "http://127.0.0.1:8080"
LOG_FILE = BASE_DIR / "logs" / "watchdog.log"


def log(message: str) -> None:
    LOG_FILE.parent.mkdir(exist_ok=True)
    timestamp = datetime.now().isoformat(timespec="seconds")
    with LOG_FILE.open("a", encoding="utf-8") as file:
        file.write(f"{timestamp} {message}\n")


def api_is_healthy() -> bool:
    try:
        with urllib.request.urlopen(f"{BASE_URL}/health", timeout=5) as response:
            body = response.read().decode("utf-8")
            data = json.loads(body)
            return response.status == 200 and data.get("ok") is True
    except Exception as exc:
        log(f"healthcheck failed: {exc}")
        return False


def restart_api() -> None:
    log("restarting phone-api")
    subprocess.run(["sv", "restart", "phone-api"], check=False)


def main() -> None:
    if api_is_healthy():
        log("phone-api healthy")
        return
    restart_api()


if __name__ == "__main__":
    main()
