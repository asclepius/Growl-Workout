#!/bin/bash

# gworkout.sh
#
# Copyright 2011 Paul Kulyk

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

GROWL_ID=1337

IMAGE1="./chainring_big.png"
IMAGE2="./chainring_big_red.png"

if [ $# -ne '1' ]
then
  echo "usage $0 <filename>"
  echo "The file needs to be formatted as follow:"
  echo "<time of interval> <min heart rate> <max heart rate> <notes on interval>"
  exit 1
fi

cat $1 | while read line
do
  INTERVAL_TIME=`echo $line | awk '{print $1}'`
  MIN_HR=`echo $line | awk '{print $2}'`
  MAX_HR=`echo $line | awk '{print $3}'`
  DETAILS=`echo $line | cut -d ' ' -f 4-`
  START=`date +%s`
  NOW=`date +%s`
  HR=`hr | awk '{print $4}'` 
  while [ $(( $NOW - $START )) -le $INTERVAL_TIME ]
  do
    sleep 1 &
    SLEEP_PID=$!
    TIME_REMAINING=$(( $INTERVAL_TIME - $NOW + $START ))
    TIMER=`date -v1970y -v1d -v0H -v0M -v0S -v +${TIME_REMAINING}S +%M:%S`
    if [ $HR == "port" ]; then HR=""; fi
    TOP_STRING=`printf "%-70s%15s" "HR: $HR ($MIN_HR - $MAX_HR)" "$TIMER"`
    BOTTOM_STRING=`printf "%-125s%15s" "$DETAILS" ""`
    IMAGE=$IMAGE1
    if [ `echo $TIMER | cut -d : -f 1` -lt '1' ]; then
      if [ `echo $TIMER | cut -d : -f 2` -le '5' ]; then
        if [ $(( `echo $TIMER | cut -d : -f 2` % 2 )) -eq '1' ]; then
          IMAGE=$IMAGE2
        fi
      fi
    fi
    growlnotify -n "gworkout.sh" --image=$IMAGE -d $GROWL_ID -t "$TOP_STRING" -m "$BOTTOM_STRING" &
    GNOT_PID=$!
    NOW=`date +%s`
    HR=`hr | awk '{print $4}'`
    HR_PID=$!
    wait $SLEEP_PID
    kill $HR_PID &> /dev/null &
    kill $GNOT_PID &> /dev/null &

  done
done
