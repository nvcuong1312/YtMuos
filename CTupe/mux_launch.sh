#!/bin/bash
# ICON: CTupe

. /opt/muos/script/var/func.sh

echo app >/tmp/act_go

PM_DIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/PortMaster"
LIB_IPOSE="libinterpose.aarch64.so"
ln -sf "$PM_DIR/$LIB_IPOSE" "/usr/lib/$LIB_IPOSE" >/dev/null 2>&1

GPTOKEYB="/mnt/mmc/MUOS/application/CTupe/bin/gptokeyb2"
LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/CTupe"
BINDIR="$LOVEDIR/bin"

# Export environment variables
SETUP_SDL_ENVIRONMENT

export LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"

# Launcher
cd "$LOVEDIR" || exit
SET_VAR "system" "foreground_process" "love"

# Run Application
$GPTOKEYB "love" &
./bin/love .
kill -9 "$(pidof gptokeyb2)"