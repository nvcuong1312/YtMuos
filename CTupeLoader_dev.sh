#!/bin/sh
# ICON: ctupe

if [ -d "CTupeData" ]; then
  rm -r "CTupeData"
fi

wget -P "CTupeData/" https://github.com/nvcuong1312/YtMuos/archive/refs/heads/dev.zip
if unzip -o "CTupeData/dev.zip" -d "CTupeData/UnzipData/"; then
	if [ -e "mnt/mmc/MUOS/application/CTupe.sh" ]; then
		rm -r "mnt/mmc/MUOS/application/CTupe.sh"
	fi

	cp "CTupeData/UnzipData/YtMuos-dev/CTupe.sh" "mnt/mmc/MUOS/application/CTupe.sh"

	if [ -e "usr/bin/youtube-dl" ]; then
		rm -r "usr/bin/youtube-dl"
	fi

	cp "CTupeData/UnzipData/YtMuos-dev/.ctupe/bin/yt-dlp" "usr/bin/yt-dlp"
	chmod a+rx /usr/bin/yt-dlp
	ln -fs /usr/bin/yt-dlp /usr/bin/youtube-dl

	# if [ -e "opt/muos/script/launch/ext-mpv-ctupe.sh" ]; then
		# rm -r "opt/muos/script/launch/ext-mpv-ctupe.sh"
	# fi

	# cp "CTupeData/UnzipData/YtMuos-dev/.ctupe/data/ext-mpv-ctupe.sh" "opt/muos/script/launch/ext-mpv-ctupe.sh"

	APIKEY="YOUR_API_KEY_HERE"
	if [ -e "mnt/mmc/MUOS/application/.ctupe/data/API" ]; then
		APIKEY=$(cat mnt/mmc/MUOS/application/.ctupe/data/API)
	fi

	if [ -d "mnt/mmc/MUOS/application/.ctupe" ]; then
	  rm -r "mnt/mmc/MUOS/application/.ctupe"
	fi

	mv "CTupeData/UnzipData/YtMuos-dev/.ctupe" "mnt/mmc/MUOS/application/"

	echo "$APIKEY" > "mnt/mmc/MUOS/application/.ctupe/data/API"
	
	if [ -e "mnt/mmc/MUOS/task/CTupeLoader_dev.sh" ]; then
		rm -r "mnt/mmc/MUOS/task/CTupeLoader_dev.sh"
	fi
	
	cp "CTupeData/UnzipData/YtMuos-dev/CTupeLoader_dev.sh" "mnt/mmc/MUOS/task/CTupeLoader_dev.sh"
	
	echo "Done!"
else
	echo "Error!"
fi

echo "-----------------------------------"
echo "|Author     : CuongNV             |"
echo "|Complete!                        |"
echo "|Thanks!                          |"
echo "-----------------------------------"
sleep 3

