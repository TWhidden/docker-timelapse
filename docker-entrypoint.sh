#!/bin/bash
set -e

DAYS_BACK=0
FORMAT="mp4"
RESOLUTION=720

while getopts ":p:d:f:r:" opt; do
  case $opt in
    p)
      PATTERN=$OPTARG
      ;;
    d)
      DAYS_BACK=$OPTARG
      ;;
    f)
      FORMAT=$OPTARG
      ;;
    r)
      RESOLUTION=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ -z $PATTERN ]]; then
    echo "No file pattern supplied."
    exit 1
fi

DATE_FORMATTED=$(date +%Y%m%d --date '-'$DAYS_BACK' day')

if [ $FORMAT = "mp4" ]; then
    ffmpeg -r 24 -pattern_type glob -i '/input/'$PATTERN'-'$DATE_FORMATTED'-*.jpg' -vf scale=$RESOLUTION:-2 -vcodec libx264 -y /output/$DATE_FORMATTED.$FORMAT
elif [ $FORMAT = "gif" ]; then
    # create a mp4 first and palette based on this secondly, this results in significant improved output
    ffmpeg -r 15 -pattern_type glob -i '/input/'$PATTERN'-'$DATE_FORMATTED'-*.jpg' -vf scale=$RESOLUTION:-2 -vcodec libx264 -y /tmp/$DATE_FORMATTED.mp4
    ffmpeg -i /tmp/$DATE_FORMATTED.mp4 -vf "fps=15,scale=$RESOLUTION:-2:flags=lanczos,palettegen" -y /tmp/palette.png
    ffmpeg -i /tmp/$DATE_FORMATTED.mp4 -i /tmp/palette.png -lavfi "fps=15,scale=$RESOLUTION:-2:flags=lanczos [x]; [x][1:v] paletteuse" -y /output/$DATE_FORMATTED.$FORMAT
    rm /tmp/$DATE_FORMATTED.mp4 /tmp/palette.png
else
    echo "Invalid output specified, only mp4 and gif are supported."
fi


