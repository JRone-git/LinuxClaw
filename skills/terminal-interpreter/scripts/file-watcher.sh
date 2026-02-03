#!/bin/bash
# File watcher for OpenClaw - monitor file changes in real-time
# Usage: file-watcher.sh <file> [lines]
# Example: file-watcher.sh /var/log/syslog 100

set -euo pipefail

FILE="${1:-}"
LINES="${2:-50}"

if [[ -z "$FILE" ]]; then
    echo "Usage: file-watcher.sh <file> [lines]"
    echo "Example: file-watcher.sh /var/log/nginx/access.log 100"
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo "Error: File '$FILE' not found"
    exit 1
fi

if [[ ! -r "$FILE" ]]; then
    echo "Error: Cannot read '$FILE' (permission denied)"
    exit 1
fi

# Check if inotifywait is available
if command -v inotifywait &>/dev/null; then
    # Use inotify for efficient watching
    {
        # Show current content
        echo "=== Initial content (last $LINES lines) ==="
        tail -n "$LINES" "$FILE"
        echo ""
        echo "=== Watching for changes (Ctrl+C to stop) ==="
        
        # Watch for modifications
        while inotifywait -q -e modify "$FILE" 2>/dev/null; do
            echo "--- $(date '+%Y-%m-%d %H:%M:%S') ---"
            tail -n "$LINES" "$FILE"
            echo ""
        done
    }
else
    # Fallback to polling with tail -f
    echo "=== Watching $FILE (last $LINES lines, Ctrl+C to stop) ==="
    tail -n "$LINES" -f "$FILE"
fi