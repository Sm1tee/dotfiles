#!/bin/bash

input="$1"
output="${input%.*}_faded.${input##*.}"

duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$input")
fade_out_start=$(awk "BEGIN {print $duration - 10}")

ffmpeg -i "$input" -c:v copy -c:a aac -af "afade=t=in:st=0:d=10,afade=t=out:st=$fade_out_start:d=10" -y "$output"

if [ -f "$output" ]; then
    notify-send "Готово" "$(basename "$output")"
fi