#!/bin/bash
#If no interval set, default to 60s
if [[ -z "${interval}" ]]; then
  interval=60
fi

#If all API requirements exist, make file, otherwise attempt removal of any auth present
if [[ -n "${apiKey}" ]] \
 && [[ -n "${apiSec}" ]] \
 && [[ -n "${accessToken}" ]] \
 && [[ -n "${accessSec}" ]]; then
  (echo "{" > /app/scripts/.oauth.json \
  && echo '    "consumer_key": "'${apiKey}'",' >> /app/scripts/.oauth.json \
  && echo '    "consumer_secret": "'${apiSed}'",' >> /app/scripts/.oauth.json \
  && echo '    "access_token": "'${accessToken}'",' >> /app/scripts/.oauth.json \
  && echo '    "access_key": "'${accessSec}'",' >> /app/scripts/.oauth.json \
  && echo "}" >> /app/scripts/.oauth.json) || rm /app/scripts/.oauth.json 2> /dev/null
else
  rm /app/scripts/.oauth.json 2> /dev/null
fi

unameA=($usernames)

for u in ${unameA[@]}; do
  bash /app/scripts/updateJson.sh "${u}" "/app/output" $interval &
  PIDs+=$!
done

wait

echo "All scripts ended, exitting in 10 seconds"
sleep 10

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
