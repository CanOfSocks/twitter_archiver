#!/bin/bash
twitterUN="${1}"
outFolder="${2}"

if ! [ -d "${outFolder}/new" ]; then
    mkdir -p "${outFolder}/new"
fi


lastFile=$(ls -t "${outFolder}/media" | head -n 1) #get last file
lastFile="${lastFile#*_(}"   #Remove before _(
lastID="${lastFile%)_*}"    #Remove after )_ to get ID

python3 /app/scripts/twitter_media_downloader.py -o "${outFolder}/new" -f "[%date%]_(%tweet_id%)_%filename%.%ext%" -s large -u "${twitterUN}" --since-id "${lastID}"

newMedia=( $( ls -t "${outFolder}/new" ) )

for m in "${outFolder}/new${newMedia[@]}"; do
  id="${m#*_(}"
  id="${id%)_*}"
  snscrape --jsonl twitter-tweet "${id}" >> "${outFolder}/new/${twitterUN}-likes.json.new" && mv -f "${m}" "${outFolder}/media/"
done

tac "${outFolder}/new/${twitterUN}-likes.json.new" >> "${outFolder}/${twitterUN}-likes.json"

