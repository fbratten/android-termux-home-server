#!/data/data/com.termux/files/usr/bin/sh

APP_DIR="/data/data/com.termux/files/home/android-termux-home-server/app"
BASE_URL="http://127.0.0.1:8080"

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1"; }
info() { echo "[INFO] $1"; }

check_file() {
  if [ -f "$APP_DIR/$1" ]; then pass "File exists: $1"; else fail "Missing file: $1"; fi
}

check_dir() {
  if [ -d "$APP_DIR/$1" ]; then pass "Directory exists: $1"; else fail "Missing directory: $1"; fi
}

check_service() {
  if sv status "$1" >/dev/null 2>&1; then
    STATUS="$(sv status "$1")"
    echo "$STATUS" | grep -q "run:" && pass "Service running: $1" || fail "Service not running: $1"
  else
    fail "Service unavailable: $1"
  fi
}

check_endpoint() {
  if curl -fsS "$BASE_URL/$1" >/dev/null 2>&1; then pass "Endpoint OK: /$1"; else fail "Endpoint failed: /$1"; fi
}

echo "=== Android Termux Home Server Diagnostics ==="
date
echo ""

info "Checking project files..."
check_file "main.py"
check_file "collect_status.py"
check_file "healthcheck.py"
check_file "config.json"
check_file "requirements.txt"
check_file "VERSION"
check_file ".action_token"
check_dir "actions"
check_dir "logs"
check_dir "backups"

echo ""
info "Checking services..."
check_service "sshd"
check_service "phone-api"
check_service "status-collector"
check_service "phone-watchdog"

echo ""
info "Checking API endpoints..."
check_endpoint "health"
check_endpoint "status"
check_endpoint "info"
check_endpoint "dashboard"

echo ""
info "Checking status artifacts..."
check_file "status.json"

if [ -f "$APP_DIR/logs/events.jsonl" ]; then
  pass "Event log exists"
else
  info "Event log does not exist yet; this is OK before first webhook event."
fi

echo ""
info "Recent watchdog log:"
tail -n 5 "$APP_DIR/logs/watchdog.log" 2>/dev/null || echo "No watchdog log yet."

echo ""
info "Recent collector log:"
tail -n 5 "$APP_DIR/collector.log" 2>/dev/null || echo "No collector log yet."

echo ""
echo "Diagnostics complete."
