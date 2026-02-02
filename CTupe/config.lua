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

Config.PLAY_FFPLAY_CMD =
[[
#!/bin/bash

URL="%s"
RESOLUTION="%s"

GPTOKEYB="/tmp/gptokeyb3"

rm -f /tmp/yt-dlp.log

$GPTOKEYB "ffplay" -c "/tmp/general_ffplay.gptk" &
yt-dlp --no-warnings --js-runtimes "deno:/usr/bin/deno" -S "$RESOLUTION" "$URL" -o - 2> /tmp/yt-dlp.log | /usr/bin/ffplay -fs - -autoexit -loglevel quiet

kill -9 "$(pidof gptokeyb3)"
]]

Config.PLAY_FFPLAY_OFFLINE_CMD =
[[
#!/bin/bash

URL="%s"

GPTOKEYB="/tmp/gptokeyb3"

$GPTOKEYB "ffplay" -c "/tmp/general_ffplay.gptk" & ffplay -fs "$URL" -autoexit -loglevel quiet

kill -9 "$(pidof gptokeyb3)"
]]

Config.PLAY_MPV_CMD =
[[
#!/bin/bash

URL="%s"
RESOLUTION="%s"

GPTOKEYB="/tmp/gptokeyb3"

rm -f /tmp/yt-dlp.log

$GPTOKEYB "mpv" -c "/tmp/general.gptk" &
yt-dlp --no-warnings --js-runtimes "deno:/usr/bin/deno" -S "$RESOLUTION" "$URL" -o - 2> /tmp/yt-dlp.log | /usr/bin/mpv --no-config --fullscreen --keepaspect=yes --video-zoom=0 --video-align-x=0 --video-align-y=0 -

kill -9 "$(pidof gptokeyb3)"
]]

Config.PLAY_MPV_OFFLINE_CMD =
[[
#!/bin/bash

URL="%s"

GPTOKEYB="/tmp/gptokeyb3"

$GPTOKEYB "mpv" -c "/tmp/general.gptk" &
/usr/bin/mpv --no-config --fullscreen --keepaspect=yes --video-zoom=0 --video-align-x=0 --video-align-y=0 "$URL"

kill -9 "$(pidof gptokeyb3)"
]]

return Config