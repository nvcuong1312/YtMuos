#!/bin/bash
# ICON: CTupe

. /opt/muos/script/var/func.sh

echo app >/tmp/act_go

GOV_GO="/tmp/gov_go"
[ -e "$GOV_GO" ] && cat "$GOV_GO" >"$(GET_VAR "device" "cpu/governor")"

SETUP_SDL_ENVIRONMENT

# Define paths and commands
LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/CTupe"
GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/PortMaster/gptokeyb2"

BINDIR="$LOVEDIR/bin"

# Export environment variables
export LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"

# Launcher
cd "$LOVEDIR" || exit
SET_VAR "system" "foreground_process" "love"

# Run Application
"${GPTOKEYB}" "$BINDIR/love"
./bin/love .
kill -9 "$(pidof gptokeyb2.armhf)"
