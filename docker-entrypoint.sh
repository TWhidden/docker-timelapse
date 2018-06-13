#!/bin/bash
set -e

if [[ -z $1 ]]; then
    echo "No file pattern supplied"
    exit 1
fi

CURRENT_DATE=$(date +%Y%m%d)

ffmpeg -r 24 -pattern_type glob -i '/input/'$1'-'$CURRENT_DATE'-*.jpg' -s hd720 -vcodec libx264 -y /output/$CURRENT_DATE.mp4