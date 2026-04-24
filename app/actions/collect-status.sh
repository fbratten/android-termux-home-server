#!/data/data/com.termux/files/usr/bin/sh

cd /data/data/com.termux/files/home/android-termux-home-server/app
mkdir -p logs
.venv/bin/python collect_status.py >> logs/actions.log 2>&1
echo "ok"
