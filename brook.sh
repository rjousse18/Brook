#!/bin/bash

# Brook - M3U Playlist Validator
# Author: Rémi Joussé
# Date: 30/12/2025
# Prerequisites: ffmpeg

# Default values
OUTPUT_OK="working_channels.txt"
OUTPUT_KO="broken_channels.txt"
PLAYLIST_OK="validated_playlist.m3u"
TIMEOUT=10

# Display help
show_help() {
    cat << EOF
Brook - M3U Playlist Validator

USAGE:
    brook.sh [OPTIONS] <playlist.m3u>

DESCRIPTION:
    Brook validates M3U playlist URLs using ffmpeg and creates a new playlist
    containing only working channels.

OPTIONS:
    -o, --output-ok FILE      File to store working channels (default: working_channels.txt)
    -k, --output-ko FILE      File to store broken channels (default: broken_channels.txt)
    -p, --playlist FILE       Output playlist with working channels (default: validated_playlist.m3u)
    -t, --timeout SECONDS     Timeout for each channel test (default: 10)
    -h, --help                Display this help message

EXAMPLES:
    brook.sh my_playlist.m3u
    brook.sh -t 15 -p clean_playlist.m3u my_playlist.m3u
    brook.sh --output-ok good.txt --output-ko bad.txt playlist.m3u

REQUIREMENTS:
    - ffmpeg must be installed

EOF
    exit 0
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -o|--output-ok)
                OUTPUT_OK="$2"
                shift 2
                ;;
            -k|--output-ko)
                OUTPUT_KO="$2"
                shift 2
                ;;
            -p|--playlist)
                PLAYLIST_OK="$2"
                shift 2
                ;;
            -t|--timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            -*)
                echo "Error: Unknown option $1"
                echo "Use --help for usage information"
                exit 1
                ;;
            *)
                M3U_FILE="$1"
                shift
                ;;
        esac
    done
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg must be installed to run this script."
    echo "Install it with: sudo apt install ffmpeg (Debian/Ubuntu) or brew install ffmpeg (macOS)"
    exit 1
fi

# Parse arguments
parse_arguments "$@"

# Check if input file is provided
if [ -z "$M3U_FILE" ]; then
    echo "Error: No input file specified"
    echo "Usage: $0 [OPTIONS] <playlist.m3u>"
    echo "Use --help for more information"
    exit 1
fi

# Check if input file exists
if [ ! -f "$M3U_FILE" ]; then
    echo "Error: File '$M3U_FILE' not found"
    exit 1
fi

# Clear output files if they exist
> "$OUTPUT_OK"
> "$OUTPUT_KO"
> "$PLAYLIST_OK"

# Write M3U header
echo "#EXTM3U" > "$PLAYLIST_OK"

# Function to test a stream with ffmpeg and timeout
test_stream() {
    local url="$1"
    local channel_name="$2"

    echo "Testing channel: $channel_name ($url)"

    # Execute ffmpeg with timeout and capture errors
    if timeout "$TIMEOUT" ffmpeg -v error -i "$url" -f null - 2>&1 | grep -E -q "Input/output error|Error opening input|Invalid data found|decode_slice_header error|no frame!"; then
        echo "$channel_name ($url)" >> "$OUTPUT_KO"
        echo "  → BROKEN"
    else
        echo "$channel_name ($url)" >> "$OUTPUT_OK"
        echo "#$channel_name" >> "$PLAYLIST_OK"
        echo "$url" >> "$PLAYLIST_OK"
        echo "  → WORKING"
    fi
}

# Read M3U file
while IFS= read -r line; do
    # Skip empty lines and comments
    if [[ -n "$line" && "$line" != \#* ]]; then
        channel_name=$(grep -B1 "$line" "$M3U_FILE" | grep "^#" | sed 's/^#//' | head -n 1)
        test_stream "$line" "$channel_name"
    fi
done < "$M3U_FILE"

# Display results
echo -e "\n=== Results ==="
echo "Working channels:"
cat "$OUTPUT_OK"
echo -e "\nBroken channels:"
cat "$OUTPUT_KO"
echo -e "\nValidated playlist created: $PLAYLIST_OK"
