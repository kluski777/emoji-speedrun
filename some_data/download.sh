#!/bin/bash
#
#
# 1) Set the input file and output directory
infile="links.txt"

# 3) Read file.txt line by line
#    IFS=, makes read split the line at the FIRST comma into two vars: url and title
#    -r prevents backslash escapes
while IFS=, read -r url title; do
  # 4) Trim spaces around url and title (remove leading/trailing spaces)
  url="$(echo "$url"   | sed -E 's/^ *| *$//g')"
  title="$(echo "$title" | sed -E 's/^ *| *$//g')"

  # 5) Skip empty lines (or lines with no URL)
  [[ -z "$url" ]] && continue

  # 6) Build a safe filename from the title:
  #    - lowercase
  #    - spaces -> underscores
  #    - keep only letters, digits, dot, underscore, hyphen
  fn="$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_.-')"

  # 7) If title is empty after sanitizing, fall back to using the URL’s basename
  #    (e.g., .../image.png -> image.png)
  if [[ -z "$fn" ]]; then
    fn="$(basename "$url")"
  fi

  # 8) If the filename has no extension, default to .png
  if [[ "$fn" != *.* ]]; then
    fn="${fn}.png"
  fi

  # 9) Show what we’re doing
  echo "Downloading: $url"
  echo "Saving as  : $fn"

  # 10) Download:
  #     -L follow redirects
  #     --fail fail on HTTP errors
  #     -o output path
  curl -L --fail -o "$fn" "$url" || {
    echo "Failed to download: $url" >&2
  }

done < "$infile"

mogrify -resize 256x256^ -gravity center -extent 256x256 *.png
