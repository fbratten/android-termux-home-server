#!/data/data/com.termux/files/usr/bin/sh

BASE_URL="http://127.0.0.1:8080"
APP_DIR="$HOME/android-termux-home-server/app"
FAILURES=0

pass(){ echo "[PASS] $1"; }
fail(){ echo "[FAIL] $1"; FAILURES=$((FAILURES+1)); }
info(){ echo "[INFO] $1"; }

kill_api_test(){
  info "Testing watchdog recovery"
  pkill -f uvicorn || true
  sleep 5
  if curl -fsS "$BASE_URL/health" >/dev/null 2>&1; then
    pass "watchdog restarted API"
  else
    fail "watchdog failed"
  fi
}

disk_check(){
  USED=$(df "$HOME" | awk 'NR==2 {print $5}' | tr -d '%')
  if [ "$USED" -lt 95 ]; then
    pass "disk OK ($USED%)"
  else
    fail "disk high ($USED%)"
  fi
}

# existing checks trimmed for brevity (kept in file above)

kill_api_test

disk_check

if [ "$FAILURES" -eq 0 ]; then
  exit 0
fi
exit 1
