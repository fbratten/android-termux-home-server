#!/data/data/com.termux/files/usr/bin/sh

BASE_URL="http://127.0.0.1:8080"
APP_DIR="$HOME/android-termux-home-server/app"
FAILURES=0

pass() {
  echo "[PASS] $1"
}

fail() {
  echo "[FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

info() {
  echo "[INFO] $1"
}

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "command available: $1"
  else
    fail "command missing: $1"
  fi
}

check_file() {
  if [ -f "$1" ]; then
    pass "file exists: $1"
  else
    fail "file missing: $1"
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    pass "directory exists: $1"
  else
    fail "directory missing: $1"
  fi
}

check_service() {
  if sv status "$1" >/dev/null 2>&1; then
    STATUS="$(sv status "$1")"
    echo "$STATUS" | grep -q "run:" && pass "service running: $1" || fail "service not running: $1"
  else
    fail "service unavailable: $1"
  fi
}

check_endpoint() {
  if curl -fsS "$BASE_URL/$1" >/dev/null 2>&1; then
    pass "endpoint OK: /$1"
  else
    fail "endpoint failed: /$1"
  fi
}

check_endpoint_blocked_without_token() {
  HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/$1" || true)"
  if [ "$HTTP_CODE" = "403" ] || [ "$HTTP_CODE" = "422" ] || [ "$HTTP_CODE" = "500" ]; then
    pass "token required: /$1 returned $HTTP_CODE"
  else
    fail "token check unexpected for /$1: HTTP $HTTP_CODE"
  fi
}

check_json_contains() {
  URL="$1"
  NEEDLE="$2"
  if curl -fsS "$URL" | grep -q "$NEEDLE"; then
    pass "response contains: $NEEDLE"
  else
    fail "response missing: $NEEDLE"
  fi
}

disk_check() {
  USED="$(df "$HOME" | awk 'NR==2 {print $5}' | tr -d '%')"
  if [ -z "$USED" ]; then
    fail "disk usage check returned empty value"
    return
  fi

  if [ "$USED" -lt 95 ]; then
    pass "disk usage safe ($USED%)"
  else
    fail "disk usage critical ($USED%)"
  fi
}

watchdog_recovery_check() {
  info "Checking watchdog recovery"

  if ! sv status phone-watchdog >/dev/null 2>&1; then
    fail "cannot test watchdog recovery: phone-watchdog service unavailable"
    return
  fi

  pkill -f 'uvicorn main:app' >/dev/null 2>&1 || true
  sleep 12

  if curl -fsS "$BASE_URL/health" >/dev/null 2>&1; then
    pass "watchdog recovered phone-api after uvicorn kill"
  else
    fail "watchdog did not recover phone-api after uvicorn kill"
  fi
}

printf '%s\n' "=== Android Termux Home Server Local Validation Runner ==="
date
printf '\n'

info "Checking commands"
check_command curl
check_command sv
check_command python

printf '\n'
info "Checking project structure"
check_dir "$APP_DIR"
check_file "$APP_DIR/main.py"
check_file "$APP_DIR/collect_status.py"
check_file "$APP_DIR/healthcheck.py"
check_file "$APP_DIR/config.json"
check_file "$APP_DIR/requirements.txt"
check_file "$APP_DIR/VERSION"
check_dir "$APP_DIR/actions"
check_dir "$APP_DIR/logs"

printf '\n'
info "Checking services"
check_service sshd
check_service phone-api
check_service status-collector
check_service phone-watchdog

printf '\n'
info "Checking open endpoints"
check_endpoint health
check_endpoint info
check_endpoint status
check_endpoint dashboard
check_json_contains "$BASE_URL/health" '"ok":true'

printf '\n'
info "Checking token-protected endpoints"
if [ -f "$APP_DIR/.action_token" ]; then
  TOKEN="$(cat "$APP_DIR/.action_token" | tr -d '\n')"
  pass "token file exists"

  if curl -fsS "$BASE_URL/actions?token=$TOKEN" >/dev/null 2>&1; then
    pass "actions endpoint accepts valid token"
  else
    fail "actions endpoint rejects valid token"
  fi

  check_endpoint_blocked_without_token actions

  if curl -fsS "$BASE_URL/actions/collect-status?token=$TOKEN" >/dev/null 2>&1; then
    pass "collect-status action executed"
  else
    fail "collect-status action failed"
  fi

  REBOOT_RESPONSE="$(curl -fsS "$BASE_URL/actions/reboot?token=$TOKEN" 2>/dev/null || true)"
  echo "$REBOOT_RESPONSE" | grep -q "Action not allowed" && pass "non-whitelisted action rejected" || fail "non-whitelisted action response unexpected"

  EVENT_PAYLOAD='{"source":"validate_local","event_type":"validation","message":"webhook roundtrip"}'
  if curl -fsS -X POST "$BASE_URL/webhook?token=$TOKEN" -H "Content-Type: application/json" -d "$EVENT_PAYLOAD" >/dev/null 2>&1; then
    pass "webhook accepted validation event"
  else
    fail "webhook validation event failed"
  fi

  if curl -fsS "$BASE_URL/events?token=$TOKEN" | grep -q "validate_local"; then
    pass "events endpoint returned validation event"
  else
    fail "events endpoint missing validation event"
  fi
else
  fail "missing token file: $APP_DIR/.action_token"
fi

printf '\n'
info "Checking runtime artifacts"
check_file "$APP_DIR/status.json"

if [ -f "$APP_DIR/logs/events.jsonl" ]; then
  pass "event log exists"
else
  info "event log missing before webhook; acceptable only before webhook test"
fi

printf '\n'
info "Checking Termux:API battery command"
if command -v termux-battery-status >/dev/null 2>&1; then
  if termux-battery-status >/dev/null 2>&1; then
    pass "termux-battery-status works"
  else
    fail "termux-battery-status command failed"
  fi
else
  fail "termux-battery-status command missing"
fi

printf '\n'
info "Checking disk usage"
disk_check

printf '\n'
watchdog_recovery_check

printf '\n'
printf '%s\n' "=== Validation Summary ==="
if [ "$FAILURES" -eq 0 ]; then
  pass "all validation checks passed"
  exit 0
fi

fail "$FAILURES validation check(s) failed"
exit 1
