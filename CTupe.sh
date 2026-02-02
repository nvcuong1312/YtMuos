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

LIB_IPOSE="libinterpose.aarch64.so"
ln -sf "$controlfolder/$LIB_IPOSE" "/usr/lib/$LIB_IPOSE" >/dev/null 2>&1

# Set variables
GAMEDIR="/$directory/ports/CTupe"
GPTOKEYB="$GAMEDIR/bin/gptokeyb2"
BINDIR="$GAMEDIR/bin"

export LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"

if [ ! -f "/tmp/gptokeyb3" ]; then
  cp "$GAMEDIR/bin/gptokeyb3" "/tmp/gptokeyb3"
fi

if [ ! -f "/tmp/general_ffplay.gptk" ]; then
  cp "$GAMEDIR/data/general_ffplay.gptk" "/tmp/general_ffplay.gptk"
fi

if [ ! -f "/tmp/general.gptk" ]; then
  cp "$GAMEDIR/data/general.gptk" "/tmp/general.gptk"
fi

if [ ! -f "/usr/bin/deno" ]; then
  cp "$GAMEDIR/bin/deno" "/usr/bin/deno"
fi

# Launcher
cd "$GAMEDIR" || exit

# Run Application
$GPTOKEYB "love" &
./bin/love .

kill -9 "$(pidof gptokeyb2)"