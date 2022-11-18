#!/bin/bash
#If no interval set, default to 60s
if [[ -z "${interval}" ]]; then
  interval=60
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
