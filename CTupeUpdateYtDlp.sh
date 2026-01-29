#!/bin/sh
# HELP: CTupe
# ICON: CTupe

. /opt/muos/script/var/func.sh

if [ -d "CTupeData" ]; then
  rm -r "CTupeData"
fi

. /opt/muos/script/var/func.sh

wget -P "CTupeData/" https://github.com/yt-dlp/yt-dlp-master-builds/releases/latest/download/yt-dlp_linux_aarch64
cp "CTupeData/yt-dlp_linux_aarch64" "usr/bin/yt-dlp"
chmod a+rx /usr/bin/yt-dlp

echo "-----------------------------------"
echo "|Author     : CuongNV             |"
echo "|Complete!                        |"
echo "|Thanks!                          |"
echo "-----------------------------------"
sleep 3

exit 0