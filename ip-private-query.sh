#!/bin/bash

for ip in `ip -br -o -4 addr list | grep UP | awk '{$1=""; $2=""; print $0}' | sed -e 's/\/[0-9]*//g'`
do

  echo "checking ${ip}"

 ipcalc -n -b ${ip} | grep "Private\|Loopback" 1> /dev/null

  if [[ $? == 0 ]]
  then
    echo "${ip} is private"
  fi

done
