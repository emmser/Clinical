#!/bin/bash
#   usage: demux.bash <absolute-path-to-run-dir>
#   The output i.e. Unaligned dir will be created 
#   under $UNALIGNEDBASE
#
NOW=$(date +"%Y%m%d%H%M%S")
UNALIGNEDBASE=/home/clinical/DEMUX/
BACKUPDIR=/home/clinical/BACKUP/
BASE=$(echo $1 | awk '{if (substr($0,length($0),1) != "/") {print $0"/"} else {print $0}}')
RUN=$(echo ${BASE} | awk 'BEGIN {FS="/"} {print $(NF-1)}')
if [ -f ${BASE}Data/Intensities/BaseCalls/SampleSheet.csv ]; then 
  fcinfile=$(awk 'BEGIN {FS=","} {fc=$1} END {print fc}' ${BASE}Data/Intensities/BaseCalls/SampleSheet.csv)
  runfc=$(echo ${BASE} | awk 'BEGIN {FS="_"} {print substr($4,2,9)}')
#  echo runfc ${runfc} fcinfile ${fcinfile}  
  if [ ! ${runfc} == ${fcinfile} ]; then 
#    echo Flowcell ID is correct, continues . . .
#  else
    echo [${NOW}] [${RUN}] Wrong Flowcell ID in SampleSheet. Exits . . . >> /home/clinical/tmp/demux.log.txt
    exit
  fi
else
  echo [${NOW}] [${RUN}] SampleSheet not found! Exits . . . >> /home/clinical/tmp/demux.log.txt
  exit
fi
echo [${NOW}] [${RUN}] Setup correct, starts demuxing . . . >> /home/clinical/tmp/demux.log.txt
mkdir -p ${UNALIGNEDBASE}${RUN}
/usr/local/bin/configureBclToFastq.pl --sample-sheet ${BASE}Data/Intensities/BaseCalls/SampleSheet.csv --use-bases-mask Y101,I6n,Y101 --input-dir ${BASE}Data/Intensities/BaseCalls --output-dir ${UNALIGNEDBASE}${RUN}/Unaligned >> /home/clinical/tmp/demux.log.txt
cd ${UNALIGNEDBASE}${RUN}/Unaligned
nohup make -j 8 > nohup.${NOW}.out 2>&1
NOW=$(date +"%Y%m%d%H%M%S")
echo [${NOW}] [${RUN}] Demultiplexing finished, packing for backup . . . >> /home/clinical/tmp/demux.log.txt
tar -czf ${BACKUPDIR}${RUN}.tar.gz ${BASE} > /dev/null
md5sum ${BACKUPDIR}${RUN}.tar.gz > ${BACKUPDIR}${RUN}.tar.gz.md5.txt
NOW=$(date +"%Y%m%d%H%M%S")
echo [${NOW}] [${RUN}] Copyinging stats to clinstatsdb >> /home/clinical/tmp/demux.log.txt
/home/clinical/SCRIPTS/parseunaligned.py /home/clinical/DEMUX/${RUN}/ /home/clinical/RUNS/${RUN}/Data/Intensities/BaseCalls/SampleSheet.csv
NOW=$(date +"%Y%m%d%H%M%S")
echo [${NOW}] [${RUN}] Demultiplexing done! Start packing for customer . . . >> /home/clinical/tmp/demux.log.txt
/home/clinical/SCRIPTS/getfastq2.bash ${UNALIGNEDBASE}${RUN} >> /home/clinical/tmp/demux.log.txt
NOW=$(date +"%Y%m%d%H%M%S")
echo [${NOW}] [${RUN}] Fastq files created in OUTBOX under Project/FlowcellID >> /home/clinical/tmp/demux.log.txt


