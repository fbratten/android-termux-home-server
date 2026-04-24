#!/data/data/com.termux/files/usr/bin/sh

BASE_URL="http://127.0.0.1:8080"
APP_DIR="$HOME/android-termux-home-server/app"

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1"; }

check_endpoint() {
  if curl -fsS "$BASE_URL/$1" >/dev/null 2>&1; then
    pass "$1"
  else
    fail "$1"
  fi
}

echo "=== Local Validation Runner ==="

# Endpoints
check_endpoint "health"
check_endpoint "info"
check_endpoint "status"

# Token checks
if [ -f "$APP_DIR/.action_token" ]; then
  TOKEN=$(cat "$APP_DIR/.action_token")
  if curl -fsS "$BASE_URL/actions?token=$TOKEN" >/dev/null 2>&1; then
    pass "actions auth"
  else
    fail "actions auth"
  fi
else
  fail "missing token"
fi

# Status file
if [ -f "$APP_DIR/status.json" ]; then
  pass "status.json exists"
else
  fail "status.json missing"
fi

echo "=== Done ==="
