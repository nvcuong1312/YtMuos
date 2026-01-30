local Config = {}

Config.GRID_PAGE_ITEM = 5
Config.MPV_PATH = "/opt/muos/script/launch/ext-mpv-ctupe.sh"
Config.API_KEY_PATH = "data/api"

Config.PATH_SEPARATOR  = package.config:sub(1, 1)

Config.SEARCH_RESUTL_JSON = "data/result.json"
Config.SEARCH_RESUTL_CR_JSON = "data/result_cr.json"
Config.SEARCH_TYPE = "data/TYPE"


-- Change this to your own path
Config.SAVE_PATH = "/mnt/mmc/ctupedata/"


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
RESOLUTION="%s"

echo app >/tmp/act_go

GPTOKEYB="/mnt/mmc/MUOS/application/CTupe/bin/gptokeyb3"

APP_DIR="/mnt/mmc/MUOS/application/CTupe/data"

HOME="$(GET_VAR "device" "board/home")"
export HOME

SETUP_SDL_ENVIRONMENT

SET_VAR "system" "foreground_process" "ffplay"

$GPTOKEYB "ffplay" -c "$APP_DIR/general_ffplay.gptk" &
yt-dlp --quiet --no-warnings --js-runtimes "deno:/mnt/mmc/MUOS/application/CTupe/bin/deno" -S "$RESOLUTION" "$URL" -o - | /usr/bin/ffplay -fs - -autoexit -loglevel quiet > /dev/null 2>&1

kill -9 "$(pidof gptokeyb3)"
]]

Config.PLAY_FFPLAY_OFFLINE_CMD =
[[
#!/bin/sh

. /opt/muos/script/var/func.sh

URL="%s"

GPTOKEYB="/mnt/mmc/MUOS/application/CTupe/bin/gptokeyb3"
APP_DIR="/mnt/mmc/MUOS/application/CTupe/data"

HOME="$(GET_VAR "device" "board/home")"
export HOME

SETUP_SDL_ENVIRONMENT

SET_VAR "system" "foreground_process" "ffplay"

$GPTOKEYB "ffplay" -c "$APP_DIR/general_ffplay.gptk" &
/usr/bin/ffplay -fs "$URL" -autoexit -loglevel quiet

kill -9 "$(pidof gptokeyb3)"
]]

Config.PLAY_MPV_CMD =
[[
#!/bin/sh

. /opt/muos/script/var/func.sh

URL="%s"

GPTOKEYB="/mnt/mmc/MUOS/application/CTupe/bin/gptokeyb3"
APP_DIR="/mnt/mmc/MUOS/application/CTupe/data"

HOME="$(GET_VAR "device" "board/home")"
export HOME

SETUP_SDL_ENVIRONMENT

SET_VAR "system" "foreground_process" "mpv"

$GPTOKEYB "mpv" -c "$APP_DIR/general.gptk" &
/usr/bin/mpv "$URL"

kill -9 "$(pidof gptokeyb3)"
]]

return Config