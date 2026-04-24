#!/data/data/com.termux/files/usr/bin/sh

cd /data/data/com.termux/files/home/android-termux-home-server/app

for file in logs/*.log collector.log
 do
  if [ -f "$file" ]; then
    tail -n 500 "$file" > "$file.tmp"
    mv "$file.tmp" "$file"
  fi
 done

echo "logs trimmed"
