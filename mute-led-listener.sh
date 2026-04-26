#!/bin/bash

update_led() {
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
        brightnessctl --device='platform::mute' set 1 > /dev/null 2>&1
    else
        brightnessctl --device='platform::mute' set 0 > /dev/null 2>&1
    fi
}

# Run once on startup
update_led 

# Force pactl to English (LC_ALL=C) and ONLY listen to the main sink (note the space after sink)
LC_ALL=C pactl subscribe | grep --line-buffered "Event 'change' on sink " | while read -r line; do
    update_led
done
