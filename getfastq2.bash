#!/bin/bash
#   usage:
#      getfastq2.bash <absloute-unaligned-base>
#      Output fastq files will appear in the OUT dir (see below) inder project/flowcell
UNALIGNBASE=$(echo $1 | awk '{if (substr($0,length($0),1) != "/") {print $0"/"} else {print $0}}')
OUT=/home/clinical/OUTBOX/
echo $UNALIGNBASE
DATE=$(echo ${UNALIGNBASE} | awk 'BEGIN {FS="/"} {split($(NF-1),arr,"_");print arr[1]}')
echo $DATE
FC=$(echo ${UNALIGNBASE} | awk 'BEGIN {FS="/"} {split($(NF-1),arr,"_");print substr(arr[4],2,length(arr[4]))}')
echo $FC
PROJs=$(ls ${UNALIGNBASE}Unaligned/ | grep Proj)
for PROJ in ${PROJs[@]};do
  echo ${PROJ}
  mkdir -p ${OUT}${PROJ}
  samples=$(ls ${UNALIGNBASE}Unaligned/${PROJ} | grep Sa)
  for var in ${samples[@]};do
    echo ${UNALIGNBASE}Unaligned/${PROJ}/${var}
    mkdir -p ${OUT}${PROJ}/${FC}
    BARCODE=$(ls ${UNALIGNBASE}Unaligned/${PROJ}/${var} | grep _L001_R1_001.fastq.gz | awk '{len=split($1,arr,"_");print arr[len-3]}')
    cat ${UNALIGNBASE}Unaligned/${PROJ}/${var}/*_L001_R1_* > ${OUT}${PROJ}/${FC}/1_${DATE}_${FC}_${var}_index${BARCODE}_R1.fastq.gz
    cat ${UNALIGNBASE}Unaligned/${PROJ}/${var}/*_L002_R1_* > ${OUT}${PROJ}/${FC}/2_${DATE}_${FC}_${var}_index${BARCODE}_R1.fastq.gz
    cat ${UNALIGNBASE}Unaligned/${PROJ}/${var}/*_L001_R2_* > ${OUT}${PROJ}/${FC}/1_${DATE}_${FC}_${var}_index${BARCODE}_R2.fastq.gz
    cat ${UNALIGNBASE}Unaligned/${PROJ}/${var}/*_L002_R2_* > ${OUT}${PROJ}/${FC}/2_${DATE}_${FC}_${var}_index${BARCODE}_R2.fastq.gz
  done
  prj=$(echo ${PROJ} | sed 's/Project_//')
  /home/clinical/SCRIPTS/selectunaligned2.py ${prj} ${FC} > ${OUT}${PROJ}/${FC}/stats.txt
  r1s=$(ls ${OUT}${PROJ}/${FC}/ | grep _R1.fastq.gz)
  for r1 in ${r1s[@]};do
    r2=$(echo $r1 | sed 's/_R1.fastq.gz/_R2.fastq.gz/')
    bc=$(echo $r1 | awk 'BEGIN {FS="_"} {print $(NF-1)}' | sed 's/index//')
    lane=$(echo $r1 | awk 'BEGIN {FS="_"} {print $1}')
    fc=$(echo $r1 | awk 'BEGIN {FS="_"} {print $3}')
    sample=$(echo $r1 | awk 'BEGIN {FS="_"} {print $4"_"$5"_"$6"_"$7"_"$8}' | sed 's/_R1.fastq.gz//' | sed "s/_index${bc}//")
    echo $sample $fc $lane $bc $r1 $r2 | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$4,$5,$6}' >> ${OUT}${PROJ}/${FC}/meta.txt
  done
done

