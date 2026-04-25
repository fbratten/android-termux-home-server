#!/data/data/com.termux/files/usr/bin/sh
set -eu

REPO_DIR="$HOME/android-termux-home-server"
APP_DIR="$REPO_DIR/app"
SERVICE_DIR="$PREFIX/var/service"

printf '%s\n' "[1/8] Updating packages..."
pkg update -y
pkg install -y openssh python nano curl termux-services termux-api

printf '%s\n' "[2/8] Creating app folders and executable permissions..."
mkdir -p "$APP_DIR/actions" "$APP_DIR/logs" "$APP_DIR/backups"
chmod +x "$APP_DIR"/actions/*.sh 2>/dev/null || true
chmod +x "$REPO_DIR"/scripts/*.sh 2>/dev/null || true

printf '%s\n' "[3/8] Creating Python venv..."
cd "$APP_DIR"
python -m venv .venv
. .venv/bin/activate

printf '%s\n' "[4/8] Installing Python dependencies..."
pip install --upgrade pip
if [ -f "$APP_DIR/requirements.txt" ]; then
  pip install -r "$APP_DIR/requirements.txt"
else
  pip install fastapi uvicorn
fi

printf '%s\n' "[5/8] Creating token if missing..."
if [ ! -f "$APP_DIR/.action_token" ]; then
  python - <<'PY'
import secrets
from pathlib import Path
Path('.action_token').write_text(secrets.token_urlsafe(32), encoding='utf-8')
PY
  chmod 600 "$APP_DIR/.action_token"
fi

printf '%s\n' "[6/8] Creating services..."

mkdir -p "$SERVICE_DIR/phone-api"
cat > "$SERVICE_DIR/phone-api/run" <<'EOF'
#!/data/data/com.termux/files/usr/bin/sh
cd /data/data/com.termux/files/home/android-termux-home-server/app
exec .venv/bin/uvicorn main:app --host 0.0.0.0 --port 8080
EOF
chmod +x "$SERVICE_DIR/phone-api/run"

mkdir -p "$SERVICE_DIR/status-collector"
cat > "$SERVICE_DIR/status-collector/run" <<'EOF'
#!/data/data/com.termux/files/usr/bin/sh
cd /data/data/com.termux/files/home/android-termux-home-server/app
while true
 do
  .venv/bin/python collect_status.py >> collector.log 2>&1
  sleep 300
 done
EOF
chmod +x "$SERVICE_DIR/status-collector/run"

mkdir -p "$SERVICE_DIR/phone-watchdog"
cat > "$SERVICE_DIR/phone-watchdog/run" <<'EOF'
#!/data/data/com.termux/files/usr/bin/sh
cd /data/data/com.termux/files/home/android-termux-home-server/app
while true
 do
  .venv/bin/python healthcheck.py >> logs/watchdog-service.log 2>&1
  sleep 60
 done
EOF
chmod +x "$SERVICE_DIR/phone-watchdog/run"

printf '%s\n' "[7/8] Creating boot script..."
mkdir -p "$HOME/.termux/boot"
cat > "$HOME/.termux/boot/start-services" <<'EOF'
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sv up sshd
sv up phone-api
sv up status-collector
sv up phone-watchdog
EOF
chmod +x "$HOME/.termux/boot/start-services"

printf '%s\n' "[8/8] Starting services..."
sv-enable sshd || true
sv up sshd || true
sv up phone-api || true
sv up status-collector || true
sv up phone-watchdog || true

printf '\nDone.\n\nToken:\n'
cat "$APP_DIR/.action_token"
printf '\n\nVerify:\n'
printf '%s\n' '  sv status sshd'
printf '%s\n' '  sv status phone-api'
printf '%s\n' '  sv status status-collector'
printf '%s\n' '  sv status phone-watchdog'
printf '%s\n' '  curl http://127.0.0.1:8080/health'
printf '%s\n' '  bash scripts/validate_local.sh'
