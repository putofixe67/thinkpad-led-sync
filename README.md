# ThinkPad LED Sync for PipeWire

A modern, lightweight bash solution to synchronize ThinkPad F1 (Speaker) and F4 (Microphone) mute LEDs with global system audio.

If you use Linux on a ThinkPad, you likely know the struggle: the built-in F1/F4 mute LEDs only track the internal sound card. If you plug in a USB DAC, Bluetooth headphones, or an external microphone, the lights stop working. 

This project provides two lightweight background services that listen to your modern PipeWire audio server and force the hardware LEDs to stay perfectly synced with your global Master Volume and Microphone status, regardless of what audio device you are using.

## ✨ Why this script? (Features)

Most existing scripts for this issue are either outdated (relying on PulseAudio/acpid), written in heavy languages (C++/Python), or completely break if your system language isn't set to English. 

* **Modern Audio Native:** Uses `wpctl` and `pactl` specifically for modern PipeWire setups (Linux Mint 22, Ubuntu 24.04, Fedora, etc.).
* **Universal Language Support:** Bypasses localization bugs using `LC_ALL=C`. `pactl` often translates system events into your local language (e.g., Portuguese, French, German), which breaks older scripts. This script forces a POSIX-standard read, meaning it works out-of-the-box on *any* system in *any* language.
* **Notification Filtered:** Specifically filters out application sounds (`sink-input`), preventing your F1 LED from flickering every time a system notification "bloop" plays.
* **Safe Permissions:** Uses `brightnessctl` instead of dangerous `chmod 666` root permission hacks to control the hardware LEDs safely as a standard user.
* **DAC & Bluetooth Friendly:** Because it monitors the global audio sink rather than the internal hardware, it works flawlessly with external USB DACs and Bluetooth headsets.

---

## 🛠️ Prerequisites

You only need one external utility installed to handle the hardware permissions safely: `brightnessctl`.

**For Debian/Ubuntu/Linux Mint:**
```bash
sudo apt update && sudo apt install brightnessctl
```
*(Note: You may need to reboot your computer once after installing `brightnessctl` for your user account to be granted the correct permissions).*

---

## 🚀 Quick Install

To install both the speaker and microphone sync services automatically, run this single command in your terminal:

```bash
sh -c "$(curl -fsSL [https://raw.githubusercontent.com/putofixe67/thinkpad-led-sync/main/install.sh](https://raw.githubusercontent.com/putofixe67/thinkpad-led-sync/main/install.sh))"
```

You can also install the scripts manually for the Speakers (F1), the Microphone (F4), or both below. 

---

## 🚀 Manual Installation

### 1. Create the necessary directories
Open your terminal and ensure your local script and systemd folders exist:
```bash
mkdir -p ~/.local/bin
mkdir -p ~/.config/systemd/user/
```

### 2. Install the Speaker Sync (F1 Key)

Create the listener script:
```bash
cat << 'EOF' > ~/.local/bin/mute-led-listener.sh
#!/bin/bash

update_led() {
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
        brightnessctl --device='platform::mute' set 1 > /dev/null 2>&1
    else
        brightnessctl --device='platform::mute' set 0 > /dev/null 2>&1
    fi
}

update_led 

LC_ALL=C pactl subscribe | grep --line-buffered "Event 'change' on sink " | while read -r line; do
    update_led
done
EOF
```
Make it executable:
```bash
chmod +x ~/.local/bin/mute-led-listener.sh
```

Create the systemd background service:
```bash
cat << 'EOF' > ~/.config/systemd/user/mute-led-listener.service
[Unit]
Description=Sync ThinkPad Mute LED using Brightnessctl
After=pipewire.service

[Service]
ExecStart=%h/.local/bin/mute-led-listener.sh
Restart=on-failure

[Install]
WantedBy=default.target
EOF
```

### 3. Install the Microphone Sync (F4 Key)

Create the listener script:
```bash
cat << 'EOF' > ~/.local/bin/micmute-led-listener.sh
#!/bin/bash

update_mic_led() {
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
        brightnessctl --device='platform::micmute' set 1 > /dev/null 2>&1
    else
        brightnessctl --device='platform::micmute' set 0 > /dev/null 2>&1
    fi
}

update_mic_led 

LC_ALL=C pactl subscribe | grep --line-buffered "Event 'change' on source " | while read -r line; do
    update_mic_led
done
EOF
```
Make it executable:
```bash
chmod +x ~/.local/bin/micmute-led-listener.sh
```

Create the systemd background service:
```bash
cat << 'EOF' > ~/.config/systemd/user/micmute-led-listener.service
[Unit]
Description=Sync ThinkPad Mic Mute LED using Brightnessctl
After=pipewire.service

[Service]
ExecStart=%h/.local/bin/micmute-led-listener.sh
Restart=on-failure

[Install]
WantedBy=default.target
EOF
```

### 4. Enable and Start the Services
Tell your system to scan for the new files and start running them automatically in the background:

```bash
systemctl --user daemon-reload

# Start the Speaker sync
systemctl --user enable --now mute-led-listener.service

# Start the Microphone sync
systemctl --user enable --now micmute-led-listener.service
```

You are done! Your LEDs should now instantly track your global audio state.

---

## 🛑 Troubleshooting

**The script is running, but the LED isn't turning on.**
Test `brightnessctl` manually by running `brightnessctl --device='platform::mute' set 1`. If you get a "Permission Denied" error, simply reboot your computer. Your user account needs a fresh login to recognize the `brightnessctl` groups.

**My system uses PulseAudio instead of PipeWire.**
These scripts use `wpctl` (WirePlumber) to check the mute status, which is standard on modern PipeWire setups. If you are on an older system using pure PulseAudio, you will need to replace the `wpctl get-volume` check with a `pactl get-sink-mute` equivalent. 

---

## 🤖 Acknowledgments
Please note that I am not the original author of the code logic. I worked alongside an AI (Google Gemini) to troubleshoot and generate these scripts to fix the LED issue on my own ThinkPad. Since it solved my problem perfectly, I wanted to share it here to help anyone else in the Linux community facing the exact same struggle!

## License
MIT
