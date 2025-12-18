#!/bin/sh
# ICON: CTupe

if [ -d "CTupeData" ]; then
  rm -r "CTupeData"
fi

wget -P "CTupeData/" https://github.com/nvcuong1312/YtMuos/archive/refs/heads/master.zip
wget -P "CTupeData/" https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
if unzip -o "CTupeData/master.zip" -d "CTupeData/UnzipData/"; then

	if [ -e "usr/bin/youtube-dl" ]; then
		rm -r "usr/bin/youtube-dl"
	fi

	cp "CTupeData/yt-dlp" "usr/bin/yt-dlp"
	chmod a+rx /usr/bin/yt-dlp
	ln -fs /usr/bin/yt-dlp /usr/bin/youtube-dl

	if [ -e "opt/muos/default/MUOS/theme/active/glyph/muxapp/CTupe.png" ]; then
		rm -r "opt/muos/default/MUOS/theme/active/glyph/muxapp/CTupe.png"
	fi

	cp "CTupeData/UnzipData/YtMuos-master/.ctupe/Assets/ctupe_logo.png" "opt/muos/default/MUOS/theme/active/glyph/muxapp/CTupe.png"
	
	if [ -e "opt/muos/default/MUOS/theme/active/glyph/muxtask/CTupe.png" ]; then
		rm -r "opt/muos/default/MUOS/theme/active/glyph/muxtask/CTupe.png"
	fi

	cp "CTupeData/UnzipData/YtMuos-master/.ctupe/Assets/ctupe_logo.png" "opt/muos/default/MUOS/theme/active/glyph/muxtask/CTupe.png"
	
	if [ -d "mnt/mmc/MUOS/application/CTupe" ]; then
	  rm -r "mnt/mmc/MUOS/application/CTupe"
	fi

	mv "CTupeData/UnzipData/YtMuos-master/.ctupe" "mnt/mmc/MUOS/application/CTupe"
	
	rm -r "mnt/mmc/MUOS/application/CTupe/config.lua"
	mv "mnt/mmc/MUOS/application/CTupe/config_goose.lua" "mnt/mmc/MUOS/application/CTupe/config.lua"
	
	if [ -e "opt/muos/share/task/CTupeLoader_Goose.sh" ]; then
		rm -r "opt/muos/share/task/CTupeLoader_Goose.sh"
	fi
	
	cp "CTupeData/UnzipData/YtMuos-master/CTupeLoader_Goose.sh" "opt/muos/share/task/CTupeLoader_Goose.sh"
	
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

