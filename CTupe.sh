#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

SUDO=""
if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

LIB_IPOSE="libinterpose.aarch64.so"
$SUDO ln -sf "$controlfolder/$LIB_IPOSE" "/usr/lib/$LIB_IPOSE" >/dev/null 2>&1

GAMEDIR="/$directory/ports/CTupe"
GPTOKEYB="$GAMEDIR/bin/gptokeyb2"
BINDIR="$GAMEDIR/bin"

HAS_FFPLAY=0
HAS_MPV=0
if command -v ffplay >/dev/null 2>&1; then
  HAS_FFPLAY=1
fi

if command -v mpv >/dev/null 2>&1; then
  HAS_MPV=1
fi

if [ "$HAS_FFPLAY" -eq 0 ] && [ "$HAS_MPV" -eq 0 ]; then
  echo "ffplay or mpv is not found!." > /tmp/ctupe_log
  exit 1
fi

echo "FFPLAY: $HAS_FFPLAY, MPV: $HAS_MPV" > /tmp/ctupe_log

if [ -f "$GAMEDIR/data/MEDIA_TYPE" ]; then
  PlayerType=$(cat "$GAMEDIR/data/MEDIA_TYPE")
else
  PlayerType=1
fi

if [ "$PlayerType" -eq 1 ] && [ "$HAS_FFPLAY" -eq 0 ]; then
  PlayerType=2
fi

echo "$GAMEDIR" > /tmp/ctupe_dir
echo "$PlayerType" > /tmp/ctupe_player

export LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"

# Launcher
cd "$GAMEDIR" || exit

# Run Application
$GPTOKEYB "love" &
./bin/love .

kill -9 "$(pidof gptokeyb2)"