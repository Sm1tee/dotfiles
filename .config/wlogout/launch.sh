#!/usr/bin/env bash

LAYOUT="$HOME/.config/wlogout/layout"
STYLE="$HOME/.config/wlogout/style.css"

if [[ ! `pidof wlogout` ]]; then
    wlogout --no-span \
        --layout ${LAYOUT} \
        --css ${STYLE} \
        --buttons-per-row 2 \
        --column-spacing 50 \
        --row-spacing 50 \
        --margin-top 450 \
        --margin-bottom 450 \
        --margin-left 850 \
        --margin-right 850

else
    pkill wlogout
fi