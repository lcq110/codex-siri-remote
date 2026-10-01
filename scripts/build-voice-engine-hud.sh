#!/bin/zsh
set -e

script_dir=${0:A:h}
config_dir="$HOME/.config/siriremote"
mkdir -p "$config_dir"
swiftc -parse-as-library -O "$script_dir/VoiceEngineHUD.swift" \
  -framework AppKit -o "$config_dir/voice-engine-hud"
