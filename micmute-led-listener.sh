#!/bin/bash

update_mic_led() {
    # Ask PipeWire if the default input (microphone) is muted
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
        brightnessctl --device='platform::micmute' set 1 > /dev/null 2>&1
    else
        brightnessctl --device='platform::micmute' set 0 > /dev/null 2>&1
    fi
}

# Run once on startup
update_mic_led 

# Force pactl to English and listen ONLY to the main source (note the space after source)
LC_ALL=C pactl subscribe | grep --line-buffered "Event 'change' on source " | while read -r line; do
    update_mic_led
done
