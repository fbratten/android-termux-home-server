from __future__ import annotations

from datetime import datetime
from pathlib import Path
import json
import platform
import socket
import subprocess

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse

app = FastAPI(title="Android Termux Home Server")

START_TIME = datetime.now()
BASE_DIR = Path(__file__).resolve().parent
CONFIG_FILE = BASE_DIR / "config.json"
VERSION_FILE = BASE_DIR / "VERSION"
ACTION_TOKEN_FILE = BASE_DIR / ".action_token"
STATUS_FILE = BASE_DIR / "status.json"
EVENT_LOG_FILE = BASE_DIR / "logs" / "events.jsonl"
MAX_EVENTS_RETURNED = 50

ACTIONS = {
    "heartbeat": "actions/heartbeat.sh",
    "collect-status": "actions/collect-status.sh",
    "list-logs": "actions/list-logs.sh",
    "trim-logs": "actions/trim-logs.sh",
    "backup": "actions/backup.sh",
    "diagnose": "scripts/diagnose.sh",
}


def load_config() -> dict:
    default_config = {
        "node_name": "android-termux-home-server",
        "host": "0.0.0.0",
        "port": 8080,
        "collector_interval_seconds": 300,
        "watchdog_interval_seconds": 60,
        "max_events_returned": 50,
    }

    if not CONFIG_FILE.exists():
        return default_config

    try:
        user_config = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
        return {**default_config, **user_config}
    except json.JSONDecodeError:
        return default_config


def get_version() -> str:
    if VERSION_FILE.exists():
        return VERSION_FILE.read_text(encoding="utf-8").strip()
    return "unknown"


def run_command(command: list[str], timeout: int = 5) -> dict:
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
            cwd=BASE_DIR,
        )
        return {
            "ok": result.returncode == 0,
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip(),
            "returncode": result.returncode,
        }
    except Exception as exc:
        return {
            "ok": False,
            "stdout": "",
            "stderr": str(exc),
            "returncode": -1,
        }


def get_action_token() -> str:
    if not ACTION_TOKEN_FILE.exists():
        return ""
    return ACTION_TOKEN_FILE.read_text(encoding="utf-8").strip()


def require_action_token(token: str | None) -> None:
    expected_token = get_action_token()

    if not expected_token:
        raise HTTPException(status_code=500, detail="Action token is not configured.")

    if token != expected_token:
        raise HTTPException(status_code=403, detail="Invalid or missing action token.")


def get_ip_address() -> str:
    try:
        hostname = socket.gethostname()
        return socket.gethostbyname(hostname)
    except Exception:
        return "unknown"


def get_battery_status() -> dict:
    result = run_command(["termux-battery-status"], timeout=5)

    if not result["ok"] or not result["stdout"]:
        return {"available": False, "error": result["stderr"] or "No battery data returned"}

    try:
        data = json.loads(result["stdout"])
        data["available"] = True
        return data
    except json.JSONDecodeError:
        return {"available": False, "error": "Battery output was not valid JSON", "raw": result["stdout"]}


def get_storage_status() -> dict:
    result = run_command(["df", "-h", str(BASE_DIR)], timeout=5)
    return {"available": result["ok"], "raw": result["stdout"] if result["ok"] else result["stderr"]}


def get_uptime_seconds() -> int:
    return int((datetime.now() - START_TIME).total_seconds())


def run_action(action_name: str) -> dict:
    if action_name not in ACTIONS:
        return {"ok": False, "error": "Action not allowed", "allowed_actions": list(ACTIONS.keys())}

    script_path = BASE_DIR / ACTIONS[action_name]

    if not script_path.exists():
        return {"ok": False, "error": f"Script missing: {script_path}"}

    result = run_command([str(script_path)], timeout=30)
    return {
        "ok": result["ok"],
        "action": action_name,
        "stdout": result["stdout"],
        "stderr": result["stderr"],
        "returncode": result["returncode"],
    }


def append_event(event: dict) -> None:
    EVENT_LOG_FILE.parent.mkdir(exist_ok=True)
    record = {"received_at": datetime.now().isoformat(), "event": event}
    with EVENT_LOG_FILE.open("a", encoding="utf-8") as file:
        file.write(json.dumps(record) + "\n")


def read_recent_events(limit: int = MAX_EVENTS_RETURNED) -> list[dict]:
    if not EVENT_LOG_FILE.exists():
        return []

    lines = EVENT_LOG_FILE.read_text(encoding="utf-8").splitlines()
    recent_lines = lines[-limit:]
    events = []

    for line in recent_lines:
        try:
            events.append(json.loads(line))
        except json.JSONDecodeError:
            events.append({"error": "invalid event log line", "raw": line})

    return events


@app.get("/")
def root():
    return {
        "status": "online",
        "service": "android-termux-home-server",
        "dashboard": "/dashboard",
        "health": "/health",
        "status_endpoint": "/status",
    }


@app.get("/health")
def health():
    return {"ok": True, "time": datetime.now().isoformat()}


@app.get("/info")
def info():
    return {
        "name": load_config().get("node_name"),
        "version": get_version(),
        "service": "android-termux-home-server",
        "routes": ["/", "/health", "/status", "/dashboard", "/collected-status", "/actions", "/webhook", "/events", "/info"],
    }


@app.get("/heartbeat")
def heartbeat():
    heartbeat_file = BASE_DIR / "heartbeat.log"
    heartbeat_file.write_text(f"Last heartbeat: {datetime.now().isoformat()}\n", encoding="utf-8")
    return {"ok": True, "message": "Heartbeat updated", "file": str(heartbeat_file)}


@app.get("/status")
def status():
    heartbeat_text = None
    heartbeat_file = BASE_DIR / "heartbeat.log"

    if heartbeat_file.exists():
        heartbeat_text = heartbeat_file.read_text(encoding="utf-8").strip()

    return {
        "status": "online",
        "time": datetime.now().isoformat(),
        "uptime_seconds": get_uptime_seconds(),
        "hostname": socket.gethostname(),
        "ip_guess": get_ip_address(),
        "platform": platform.platform(),
        "python": platform.python_version(),
        "battery": get_battery_status(),
        "storage": get_storage_status(),
        "heartbeat": heartbeat_text,
    }


@app.get("/collected-status")
def collected_status():
    if not STATUS_FILE.exists():
        return {"available": False, "message": "No collected status yet."}

    try:
        return json.loads(STATUS_FILE.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {"available": False, "message": "status.json exists but contains invalid JSON."}


@app.get("/actions")
def list_actions(token: str | None = None):
    require_action_token(token)
    return {"allowed_actions": list(ACTIONS.keys())}


@app.post("/actions/{action_name}")
def trigger_action(action_name: str, token: str | None = None):
    require_action_token(token)
    return run_action(action_name)


@app.get("/actions/{action_name}")
def trigger_action_from_browser(action_name: str, token: str | None = None):
    require_action_token(token)
    return run_action(action_name)


@app.post("/webhook")
async def receive_webhook(request: Request, token: str | None = None):
    require_action_token(token)

    try:
        payload = await request.json()
    except Exception:
        payload = {"raw_body": (await request.body()).decode("utf-8", errors="replace")}

    append_event(payload)
    return {"ok": True, "message": "Event received"}


@app.get("/events")
def get_events(token: str | None = None, limit: int = MAX_EVENTS_RETURNED):
    require_action_token(token)
    safe_limit = max(1, min(limit, 200))
    events = read_recent_events(safe_limit)
    return {"ok": True, "count": len(events), "events": events}


@app.get("/dashboard", response_class=HTMLResponse)
def dashboard():
    current_status = status()
    recent_events = read_recent_events(10)

    battery = current_status["battery"]
    battery_text = "Unavailable"

    if battery.get("available"):
        percentage = battery.get("percentage", "unknown")
        charging_status = battery.get("status", "unknown")
        health = battery.get("health", "unknown")
        temperature = battery.get("temperature", "unknown")
        battery_text = f"{percentage}% / {charging_status} / {health} / {temperature}°C"

    storage_text = current_status["storage"].get("raw", "Unavailable")

    if recent_events:
        event_items = ""
        for item in reversed(recent_events):
            event_items += f"""
            <div class="event">
                <pre>{json.dumps(item, indent=2)}</pre>
            </div>
            """
    else:
        event_items = "<p>No events received yet.</p>"

    html = f"""
    <!doctype html>
    <html>
    <head>
        <title>Android Home Server</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body {{ font-family: system-ui, sans-serif; background: #111827; color: #f9fafb; margin: 0; padding: 2rem; }}
            .card {{ background: #1f2937; border-radius: 16px; padding: 1rem 1.25rem; margin-bottom: 1rem; box-shadow: 0 8px 24px rgba(0,0,0,0.25); }}
            h1 {{ margin-top: 0; }}
            code, pre {{ background: #030712; color: #d1d5db; padding: 0.75rem; border-radius: 12px; overflow-x: auto; display: block; }}
            a {{ color: #93c5fd; }}
            .event {{ border-left: 4px solid #93c5fd; padding-left: 0.75rem; margin-bottom: 0.75rem; }}
        </style>
    </head>
    <body>
        <h1>Android Termux Home Server</h1>
        <div class="card"><h2>Status</h2><p><strong>State:</strong> {current_status["status"]}</p><p><strong>Time:</strong> {current_status["time"]}</p><p><strong>Uptime:</strong> {current_status["uptime_seconds"]} seconds</p></div>
        <div class="card"><h2>Device</h2><p><strong>Hostname:</strong> {current_status["hostname"]}</p><p><strong>IP guess:</strong> {current_status["ip_guess"]}</p><p><strong>Platform:</strong> {current_status["platform"]}</p><p><strong>Python:</strong> {current_status["python"]}</p></div>
        <div class="card"><h2>Battery</h2><p>{battery_text}</p></div>
        <div class="card"><h2>Storage</h2><pre>{storage_text}</pre></div>
        <div class="card"><h2>Heartbeat</h2><p>{current_status["heartbeat"] or "No heartbeat yet."}</p><p><a href="/heartbeat">Trigger heartbeat</a></p></div>
        <div class="card"><h2>Recent Events</h2>{event_items}</div>
        <div class="card"><h2>API</h2><p><a href="/health">/health</a></p><p><a href="/status">/status</a></p><p><a href="/info">/info</a></p></div>
    </body>
    </html>
    """

    return HTMLResponse(content=html)
