#!/bin/bash
# Niri Vertical Monitor — vertically stacks windows on specified monitors.
# Usage: layout-daemon.sh MONITOR1 MONITOR2 ...
# Example: layout-daemon.sh DP-4 HDMI-A-2

declare -A target_monitors
declare -A processed_windows  # window_id -> workspace_id
declare -A original_widths    # window_id -> column width as % when first seen on non-target monitor

for monitor in "$@"; do
    target_monitors["$monitor"]=1
done

if [ ${#target_monitors[@]} -eq 0 ]; then
    echo "[niri-layout] No monitor specified. Exiting." >&2
    exit 1
fi

echo "[niri-layout] Monitoring: ${!target_monitors[*]}"

# Uses process substitution so the while loop runs in the main shell,
# keeping access to associative arrays between iterations.
while read -r event rest; do

    # --- Window closed: remove from tracking ---
    if [[ "$event" == "close" ]]; then
        wid="$rest"
        unset "processed_windows[$wid]" "original_widths[$wid]"
        continue
    fi

    # --- Window opened or changed ---
    read -r wid wsid <<< "$rest"

    # Invalid workspace (window still being mapped)
    if [[ "$wsid" == "null" || -z "$wsid" ]]; then continue; fi

    was_processed=false
    if [[ -n "${processed_windows[$wid]}" ]]; then
        if [[ "${processed_windows[$wid]}" == "$wsid" ]]; then
            # Same workspace → notification/title changed. Ignore.
            continue
        else
            # Changed workspace → reprocess
            was_processed=true
            unset "processed_windows[$wid]"
        fi
    fi

    # Finds the monitor associated with the workspace
    output=$(niri msg --json workspaces 2>/dev/null | jq -r ".[] | select(.id == $wsid) | .output // empty")
    [[ -z "$output" ]] && continue

    # ── vert -> hori: capture original width when window first appears on widescreen ──
    if [[ -z "${target_monitors[$output]}" && -z "${original_widths[$wid]+x}" ]]; then
        tile_w=$(niri msg --json windows 2>/dev/null | jq -r ".[] | select(.id == $wid) | .layout.tile_size[0] // empty")
        out_w=$(niri msg --json outputs 2>/dev/null | jq -r ".[] | select(.name == \"$output\") | .logical.width // empty")
        if [[ -n "$tile_w" && -n "$out_w" ]]; then
            original_widths[$wid]=$(awk "BEGIN { printf \"%.0f\", ($tile_w / $out_w) * 100 }")
        fi
    fi
    # ── end capture ──

    # Applies only to configured monitors
    if [[ -n "${target_monitors[$output]}" ]]; then
        sleep 0.2
        niri msg action focus-window --id "$wid" 2>/dev/null
        niri msg action consume-or-expel-window-left 2>/dev/null
        niri msg action set-column-width "100%" 2>/dev/null
        processed_windows[$wid]="$wsid"
        echo "[niri-layout] Layout applied: window $wid → $output (workspace $wsid)"

    # ── vert -> hori: resize and reposition window when moving to widescreen ──
    elif [[ "$was_processed" == true ]]; then
        sleep 0.2
        prev_output=$(niri msg --json focused-output 2>/dev/null | jq -r '.name // empty')
        niri msg action focus-window --id "$wid" 2>/dev/null
        niri msg action reset-window-height 2>/dev/null
        # restore original column width as percentage (kept for future round-trips)
        if [[ -n "${original_widths[$wid]}" ]]; then
            niri msg action set-column-width "${original_widths[$wid]}%" 2>/dev/null
        else
            niri msg action set-column-width "33%" 2>/dev/null
        fi
        niri msg action focus-column-left 2>/dev/null
        if [[ -n "$prev_output" ]]; then
            niri msg action focus-monitor "$prev_output" 2>/dev/null
        fi
        echo "[niri-layout] Reset applied: window $wid → $output (workspace $wsid)"
    # ── end vert -> hori ──
    fi

done < <(niri msg --json event-stream 2>/dev/null | jq --unbuffered -r '
    if .WindowOpenedOrChanged != null then
        "open \(.WindowOpenedOrChanged.window.id) \(.WindowOpenedOrChanged.window.workspace_id // "null")"
    elif .WindowClosed != null then
        "close \(.WindowClosed.id)"
    else empty
    end
')

echo "[niri-layout] Stream ended." >&2
