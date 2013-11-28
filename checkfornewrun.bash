#!/bin/bash
#
RAWBASE=/home/clinical/RUNS/
UNABASE=/home/clinical/DEMUX/
runs=$(ls /home/clinical/RUNS/)
for run in ${runs[@]}; do
  NOW=$(date +"%Y%m%d%H%M%S")
  if [ -f ${RAWBASE}${run}/RTAComplete.txt ]; then
    if [ -d ${UNABASE}${run}/Unaligned ]; then
      echo [${NOW}] ${run} is finished and demultiplexing has already started 
    else
      echo [${NOW}] ${run} is finished but demultiplexing has not started
      /home/clinical/SCRIPTS/demux.bash ${RAWBASE}${run} &
    fi
  else
    echo [${NOW}] ${run} is not finished yet
  fi
done


