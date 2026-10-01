#!/bin/zsh
set -e

config_dir="$HOME/.config/siriremote"
current=$(cat "$config_dir/voice-engine")
case "$current" in
  vocotype) next=wetype ;;
  wetype) next=vocotype ;;
  *) print -u2 "Unknown voice engine: $current"; exit 1 ;;
esac

cp "$config_dir/config-$next.jsonc" "$config_dir/config.next.jsonc"
mv -f "$config_dir/config.next.jsonc" "$config_dir/config.jsonc"
print -r -- "$next" > "$config_dir/voice-engine"
"$config_dir/voice-engine-hud" "$next" >/tmp/siriremote-voice-hud.log 2>&1 &
