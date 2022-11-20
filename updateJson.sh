#!/bin/bash
twitterUN="${1}"
outFolder="${2}/${1}"
interval=${3}
spacesPath="${outFolder}/spaces"
COOKIES_PATH="${2}/cookies.txt"
echo "$outFolder"

#If downloading media was interrupted, reget new media
if [ -s "${outFolder}/${twitterUN}-tweets.json.new" ]; then
  /app/scripts/getMedia.sh "${outFolder}/${twitterUN}-tweets.json.new" "${outFolder}"
  mv -f "${outFolder}/${twitterUN}-tweets.json.new" "${outFolder}/${twitterUN}-tweets.json"
  if [ -f  "${outFolder}/${twitterUN}-tweets.json.bkup" ]; then
    cat "${outFolder}/${twitterUN}-tweets.json.bkup" >> "${outFolder}/${twitterUN}-tweets.json"
  fi
fi


while true
do
  #Make output folder if not existing
  if ! [ -d "${outFolder}" ]; then
    mkdir -p "${outFolder}"
  fi

  #Start download of any available spaces
  if [ ! -f "$COOKIES_PATH" ]; then
    echo "Starting without cookies"
    twspace_dl -U "https://twitter.com/${twitterUN}" --write-url "${spacesPath}/master_urls.txt" -m -p -o "${spacesPath}/[%(creator_screen_name)s]-%(title)s|%(start_date)s"
  else
    twspace_dl -U "https://twitter.com/${twitterUN}" --write-url "${spacesPath}/master_urls.txt" --input-cookie-file "$COOKIES_PATH" -o "${spacesPath}/[%(creator_screen_name)s]-%(title)s|%(start_date)s"
  fi

  #Archive tweets
  if ! [ -f "${outFolder}/${twitterUN}-tweets.json" ]; then
    #if no existing archive
    snscrape --jsonl twitter-profile "${twitterUN}" > "${outFolder}/${twitterUN}-tweets.json.new"
    /app/scripts/getMedia.sh "${outFolder}/${twitterUN}-tweets.json.new" "${outFolder}"
    mv -f "${outFolder}/${twitterUN}-tweets.json.new" "${outFolder}/${twitterUN}-tweets.json"
  else
    #If existing, only grab after latest date
    dateOne=$(jq -r '[.date] | @tsv' <<< $(sed -n '1{p;q;}' "${outFolder}/${twitterUN}-tweets.json"))
    dateTwo=$(jq -r '[.date] | @tsv' <<< $(sed -n '2{p;q;}' "${outFolder}/${twitterUN}-tweets.json"))
#    echo "Date one: $dateOne"
#    echo "Date one: $dateTwo"
    dateA=$(date -d "$dateOne" +"%s")
    dateB=$(date -d "$dateTwo" +"%s")
    dateSince=0
    if [ "$dateA" -ge "$dateB" ]; then
      dateSince=$dateA
    else
      dateSince=$dateB
    fi
    dateSince=$(date -d @$(($dateSince)) +"%Y-%m-%d %H:%M:%S %z")
    snscrape --since "${dateSince}" --jsonl twitter-profile "${twitterUN}" > "${outFolder}/${twitterUN}-tweets.json.new"

    if [ -s "${outFolder}/${twitterUN}-tweets.json.new" ]; then
#      lineCount=$(wc -l < "${outFolder}/${twitterUN}-tweets.json.new")
#      lineOneNew=$(sed -n '1{p;q;}' "${outFolder}/${twitterUN}-tweets.json.new")
#      lineOneSource=$(sed -n '1{p;q;}' "${outFolder}/${twitterUN}-tweets.json")
      if [[ $(wc -l < "${outFolder}/${twitterUN}-tweets.json.new") -eq 1 ]] \
       && [[ $(jq -r '[.url] | @tsv' <<< $(head -1 "${outFolder}/${twitterUN}-tweets.json.new")) = $(jq -r '[.url] | @tsv' <<< $(head -1 "${outFolder}/${twitterUN}-tweets.json")) ]]; then
        echo "Duplicate tweet downloaded - not saving to file"
      else
        cp -f "${outFolder}/${twitterUN}-tweets.json" "${outFolder}/${twitterUN}-tweets.json.bkup"
        /app/scripts/getMedia.sh "${outFolder}/${twitterUN}-tweets.json.new" "${outFolder}"
        mv -f "${outFolder}/${twitterUN}-tweets.json.new" "${outFolder}/${twitterUN}-tweets.json"
        cat "${outFolder}/${twitterUN}-tweets.json.bkup" >> "${outFolder}/${twitterUN}-tweets.json"
      fi
    fi
  fi
  /app/scripts/getLikes.sh gawrgura "${outFolder}/likes"
  sleep $(($interval))
done
