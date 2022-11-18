#!/bin/bash
jsonFile="${1}"
outFolder="${2}"
#echo "Reading from: ${jsonFile}"

pictures=()
videos=()

#while IFS= read -r LINE; do
  pictures+=($(jq -r '.media[].fullUrl' "${jsonFile}"  | tr -d '[],"'))
  videos+=($(jq -r '.media[].variants|sort_by(.bitrate)[-1].url' "${jsonFile}"  | tr -d '[],"'))

#done < "$jsonFile"

for url in ${pictures[@]}
  do
    removeHTTP="${url#*//}"
#    echo "Remove HTTP: $removeHTTP"
    format="${url#*format=}"
    format="${format%&*}"
    removeFormat="${removeHTTP%?format=*}"
#    echo "Remove format: $removeFormat"
    echo "$url - Saving to: ${outFolder}/${removeFormat}.${format}"
    curl "${url}" --create-dirs -o "${outFolder}/${removeFormat}.${format}"
  done

  for url in ${videos[@]}
  do
    removeHTTP="${url#*//}"
    removeTag="${removeHTTP%?tag=*}"
    echo "Writing to destination: ${outFolder}/${removeTag}"
    curl "${url}" --create-dirs -o "${outFolder}/${removeTag}"
  done
