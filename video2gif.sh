#!/usr/bin/env bash

set -Eeuo pipefail

VERSION="1.0.0"

usage() {
    cat <<EOF
video2gif - v${VERSION}

Convert and optimize video into looping GIF.

Usage:
  video2gif -i <input> -o <output>

Options:
  -i FILE    Input video file
  -o FILE    Output GIF file
  -h         Show this help message
  -v         Show version

Example:
  video2gif -i input.mp4 -o output.gif
EOF
}

input=""
output=""

while getopts ":i:o:hv" opt; do
    case "$opt" in
        i) input="$OPTARG" ;;
        o) output="$OPTARG" ;;
        h)
            usage
            exit 0
            ;;
        v)
            echo "video2gif v${VERSION}"
            exit 0
            ;;
        :)
            echo "[!] Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        \?)
            echo "[!] Unknown option: -$OPTARG" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ -z "$input" || -z "$output" ]]; then
    echo "[!] Input and output are required." >&2
    usage >&2
    exit 1
fi

if [[ ! -f "$input" || ! -r "$input" ]]; then
    echo "[!] Input file does not exist or is not readable: $input" >&2
    exit 1
fi

for cmd in ffmpeg gifsicle mktemp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[!] Required dependency not found: $cmd" >&2
        exit 1
    fi
done

if [[ "${output,,}" != *.gif ]]; then
    echo "[!] Output filename must have a .gif extension." >&2
    exit 1
fi

output_dir="$(dirname -- "$output")"

if [[ ! -d "$output_dir" ]]; then
    echo "[!] Output directory does not exist: $output_dir" >&2
    exit 1
fi

tmpdir="$(mktemp -d "${output_dir}/.video2gif.XXXXXX")"

cleanup() {
    rm -rf -- "$tmpdir"
}

trap cleanup EXIT

temp_gif="${tmpdir}/temp.gif"
final_gif="${tmpdir}/output.gif"

echo "[*] Converting video to GIF..."

ffmpeg -hide_banner -i "$input" \
-filter_complex "[0:v]fps=8,scale=340:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=112:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
-an -loop 0 -y "$temp_gif"

echo "[*] Optimizing GIF..."

gifsicle -O3 --no-comments --no-names "$temp_gif" -o "$final_gif"

mv -f -- "$final_gif" "$output"

echo "[+] Conversion completed successfully!"
echo "[+] Output: $output"

if command -v du >/dev/null 2>&1; then
    echo "[+] File size: $(du -h -- "$output" | cut -f1)"
fi
