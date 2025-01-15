local Config = {}

Config.GRID_PAGE_ITEM = 5
Config.MPV_PATH = "/opt/muos/script/launch/ext-mpv-ctupe.sh"
Config.API_KEY_PATH = "data/api"

Config.PATH_SEPARATOR  = package.config:sub(1, 1)

Config.SEARCH_RESUTL_JSON = "data/result.json"
Config.SEARCH_RESUTL_CR_JSON = "data/result_cr.json"
Config.SEARCH_TYPE = "data/TYPE"
Config.SAVE_PATH = "data/SAVEPATH"
Config.SAVE_MEDIA_PATH = Config.PATH_SEPARATOR .."MediaData"
Config.SAVE_INFO_PATH = Config.PATH_SEPARATOR .. "InfoData"
Config.SAVE_THUMBNAIL_PATH = Config.PATH_SEPARATOR .. "Thumbnail.jpg"

Config.FONT_PATH = "Assets/Font/Font.ttf"

Config.SEARCH_URL = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=%s&type=video&maxResults=%s&key=%s"
Config.SEARCH_MAX_RESULT = 30

Config.YT_PLAY_URL = "https://www.youtube.com/watch?v=%s"

Config.PLAY_FFPLAY_CMD =
[[
#!/bin/sh

. /opt/muos/script/var/func.sh

URL="%s"

GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2"
APP_DIR="/mnt/mmc/MUOS/application/.ctupe/data"

HOME="$(GET_VAR "device" "board/home")"
export HOME

SDL_HQ_SCALER="$(GET_VAR "device" "sdl/scaler")"
SDL_ROTATION="$(GET_VAR "device" "sdl/rotation")"
SDL_BLITTER_DISABLED="$(GET_VAR "device" "sdl/blitter_disabled")"
export SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED

export SDL_GAMECONTROLLERCONFIG_FILE="/usr/lib/gamecontrollerdb.txt"

SET_VAR "system" "foreground_process" "ffplay"

$GPTOKEYB "ffplay" -c "$APP_DIR/general_ffplay.gptk" &
youtube-dl -S "res:640" "$URL" -o - | /usr/bin/ffplay - -autoexit -loglevel quiet

kill -9 "$(pidof gptokeyb2)"

unset SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED
]]

Config.PLAY_FFPLAY_OFFLINE_CMD =
[[
#!/bin/sh

. /opt/muos/script/var/func.sh

URL="%s"

GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2"
APP_DIR="/mnt/mmc/MUOS/application/.ctupe/data"

HOME="$(GET_VAR "device" "board/home")"
export HOME

SDL_HQ_SCALER="$(GET_VAR "device" "sdl/scaler")"
SDL_ROTATION="$(GET_VAR "device" "sdl/rotation")"
SDL_BLITTER_DISABLED="$(GET_VAR "device" "sdl/blitter_disabled")"
export SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED

export SDL_GAMECONTROLLERCONFIG_FILE="/usr/lib/gamecontrollerdb.txt"

SET_VAR "system" "foreground_process" "ffplay"

$GPTOKEYB "ffplay" -c "$APP_DIR/general_ffplay.gptk" &
/usr/bin/ffplay "$URL" -autoexit -loglevel quiet

kill -9 "$(pidof gptokeyb2)"

unset SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED
]]

Config.PLAY_MPV_CMD =
[[
#!/bin/sh

. /opt/muos/script/var/func.sh

URL="%s"

GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2"
APP_DIR="/mnt/mmc/MUOS/application/.ctupe/data"

HOME="$(GET_VAR "device" "board/home")"
export HOME

SDL_HQ_SCALER="$(GET_VAR "device" "sdl/scaler")"
SDL_ROTATION="$(GET_VAR "device" "sdl/rotation")"
SDL_BLITTER_DISABLED="$(GET_VAR "device" "sdl/blitter_disabled")"
export SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED

export SDL_GAMECONTROLLERCONFIG_FILE="/usr/lib/gamecontrollerdb.txt"

SET_VAR "system" "foreground_process" "mpv"

$GPTOKEYB "mpv" -c "$APP_DIR/general.gptk" &
/usr/bin/mpv "$URL"

kill -9 "$(pidof gptokeyb2)"

unset SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED

]]

return Config