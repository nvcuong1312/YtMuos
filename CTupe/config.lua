local Config = {}

Config.GRID_PAGE_ITEM = 5
Config.API_KEY_PATH = "data/api"

Config.PATH_SEPARATOR  = package.config:sub(1, 1)

Config.SEARCH_RESUTL_JSON = "data/result.json"
Config.SEARCH_RESUTL_CR_JSON = "data/result_cr.json"
Config.SEARCH_TYPE = "data/TYPE"
Config.SEARCH_HISTORY = "data/search_history"

-- Change this to your own path
Config.SAVE_PATH = "/mnt/mmc/ctupedata/"


Config.SAVE_MEDIA_PATH = Config.PATH_SEPARATOR .."MediaData"
Config.SAVE_INFO_PATH = Config.PATH_SEPARATOR .. "InfoData"
Config.SAVE_THUMBNAIL_PATH = Config.PATH_SEPARATOR .. "Thumbnail.jpg"

Config.FONT_PATH = "Assets/Font/Font.ttf"

Config.SEARCH_URL = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=%s&type=video&maxResults=%s&key=%s"
Config.SEARCH_MAX_RESULT = 30

Config.YT_PLAY_URL = "https://www.youtube.com/watch?v=%s"

Config.PLAY_CMD =
[[
#!/bin/bash

URL="%s"
RESOLUTION="%s"

GPTOKEYB="/tmp/gptokeyb3"

rm -f /tmp/yt-dlp.log

directory=$(cat /tmp/ctupe_dir)
player=$(cat /tmp/ctupe_player)

ytdlpCmd="/$directory/bin/yt-dlp --no-warnings --js-runtimes "deno:/$directory/bin/deno" -S "$RESOLUTION" "$URL" -o -"

if [ "$player" -eq 1 ]; then
    $GPTOKEYB "ffplay" -c "/tmp/general_ffplay.gptk" &
    $ytdlpCmd 2> /tmp/yt-dlp.log | $(which ffplay) -fs - -autoexit -loglevel quiet
elif [ "$player" -eq 2 ]; then
    $GPTOKEYB "mpv" -c "/tmp/general.gptk" &
    $ytdlpCmd 2> /tmp/yt-dlp.log | $(which mpv) --no-config --fullscreen --keepaspect=yes --video-zoom=0 --video-align-x=0 --video-align-y=0 -
fi

kill -9 "$(pidof gptokeyb3)"
]]

Config.PLAY_OFFLINE_CMD =
[[
#!/bin/bash

URL="%s"

GPTOKEYB="/tmp/gptokeyb3"

if [ "$(cat /tmp/ctupe_player)" -eq 1 ]; then
    $GPTOKEYB "ffplay" -c "/tmp/general_ffplay.gptk" &
    $(which ffplay) -fs "$URL" -autoexit -loglevel quiet
elif [ "$(cat /tmp/ctupe_player)" -eq 2 ]; then
    $GPTOKEYB "mpv" -c "/tmp/general.gptk" &
    $(which mpv) --no-config --fullscreen --keepaspect=yes --video-zoom=0 --video-align-x=0 --video-align-y=0 "$URL"
fi

kill -9 "$(pidof gptokeyb3)"
]]

return Config