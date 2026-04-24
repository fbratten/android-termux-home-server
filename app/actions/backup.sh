#!/data/data/com.termux/files/usr/bin/sh

cd /data/data/com.termux/files/home/android-termux-home-server/app
mkdir -p backups
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="backups/phone-server-backup-$STAMP.tar.gz"

tar \
  --exclude=".venv" \
  --exclude="__pycache__" \
  --exclude="backups" \
  -czf "$OUT" \
  main.py \
  collect_status.py \
  healthcheck.py \
  actions \
  logs \
  status.json \
  .action_token 2>/dev/null

echo "$OUT"
