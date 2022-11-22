#!/bin/bash
#If no interval set, default to 60s
if [[ -z "${interval}" ]]; then
  interval=60
fi

#If all API requirements exist, make file, otherwise attempt removal of any auth present
#if [[ -n "${apiKey}" ]] \
# && [[ -n "${apiSec}" ]] \
# && [[ -n "${accessToken}" ]] \
# && [[ -n "${accessSec}" ]]; then
#  (echo "{" > /app/scripts/twitter_media_downloader/.oauth.json \
#  && echo '    "consumer_key": "'${apiKey}'",' >> /app/scripts/twitter_media_downloader/.oauth.json \
#  && echo '    "consumer_secret": "'${apiSec}'",' >> /app/scripts/twitter_media_downloader/.oauth.json \
#  && echo '    "access_token": "'${accessToken}'",' >> /app/scripts/twitter_media_downloader/.oauth.json \
#  && echo '    "access_token_secret": "'${accessSec}'",' >> /app/scripts/twitter_media_downloader/.oauth.json \
#  && echo "}" >> /app/scripts/twitter_media_downloader/.oauth.json) || rm /app/scripts/twitter_media_downloader/.oauth.json 2> /dev/null
#else
#  rm /app/scripts/twitter_media_downloader/.oauth.json 2> /dev/null
#fi

unameA=($usernames)

for u in ${unameA[@]}; do
  bash /app/scripts/updateJson.sh "${u}" "/app/output" $interval &
  PIDs+=$!
done

wait

echo "All scripts ended, exitting in 10 seconds"
sleep 10

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
