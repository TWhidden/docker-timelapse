#!/bin/bash
set -e

if [[ -z $1 ]]; then
    echo "No file pattern supplied"
    exit 1
fi

if [[ -z $2 ]]; then
    USE_DATE=$(date +%Y%m%d)
else
    USE_DATE=$(date +%Y%m%d --date '-'$2' day')
fi

ffmpeg -r 24 -pattern_type glob -i '/input/'$1'-'$USE_DATE'-*.jpg' -s hd720 -vcodec libx264 -y /output/$USE_DATE.mp4