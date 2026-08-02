{pkgs, ...}: let
  powermenu = pkgs.writeShellScriptBin "hypr-powermenu" ''
    shutdown="󰐥 Shutdown"
    reboot="󰜉 Reboot"
    suspend="󰤄 Suspend"
    lock="󰌾 Lock"
    logout="󰍃 Logout"

    chosen=$(printf '%s\n' "$shutdown" "$reboot" "$suspend" "$lock" "$logout" \
      | ${pkgs.rofi}/bin/rofi -dmenu -i -p "⏻" \
          -theme-str 'window {width: 220px;}' \
          -theme-str 'listview {lines: 5;}')

    case "$chosen" in
      "$shutdown") systemctl poweroff ;;
      "$reboot")   systemctl reboot ;;
      "$suspend")  systemctl suspend ;;
      "$lock")     ${pkgs.hyprlock}/bin/hyprlock ;;
      "$logout")   hyprctl dispatch exit ;;
    esac
  '';

  keybindings = pkgs.writeShellScriptBin "hypr-keybindings" ''
    config="$HOME/.config/hypr/hyprland.conf"
    mainmod=$(grep -m1 'mainMod = ' "$config" | awk '{print $NF}')

    grep -E '^bind' "$config" \
      | sed 's/^bind[meld]* = //' \
      | awk -v mod="$mainmod" '{gsub(/\$mainMod/, mod); print}' \
      | ${pkgs.rofi}/bin/rofi -dmenu -i -p "󰌌 Keybinds" -no-custom
  '';

  gif-record = pkgs.writeShellScriptBin "hypr-gif-record" ''
    PID_FILE="/tmp/hypr-gif.pid"
    VIDEO_FILE="/tmp/hypr-recording.mp4"
    OUT="$HOME/Videos/recording_$(date +%Y-%m-%d_%H-%M-%S).gif"

    if [ -f "$PID_FILE" ]; then
      PID=$(cat "$PID_FILE")
      kill -SIGINT "$PID"
      while kill -0 "$PID" 2>/dev/null; do sleep 0.1; done
      rm "$PID_FILE"

      ${pkgs.libnotify}/bin/notify-send "GIF Recorder" "Converting..."
      ${pkgs.ffmpeg}/bin/ffmpeg -y -i "$VIDEO_FILE" \
        -vf "fps=15,scale=720:-2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
        "$OUT" \
        && ${pkgs.libnotify}/bin/notify-send "GIF Recorder" "Saved: $OUT" \
        || ${pkgs.libnotify}/bin/notify-send -u critical "GIF Recorder" "Conversion failed"
      rm -f "$VIDEO_FILE"
    else
      GEOMETRY=$(${pkgs.slurp}/bin/slurp) || exit 0
      mkdir -p "$HOME/Videos"
      ${pkgs.libnotify}/bin/notify-send "GIF Recorder" "Recording... (shortcut again to stop)"
      ${pkgs.wf-recorder}/bin/wf-recorder -g "$GEOMETRY" -f "$VIDEO_FILE" &
      echo $! > "$PID_FILE"
    fi
  '';
in {
  home.packages = [powermenu keybindings gif-record];
}
