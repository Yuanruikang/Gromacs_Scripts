#!/bin/bash
name="POPC25A-0904"
gmx energy -f ../${name}.edr -b 400000 -e 800000 -o ${name}_box_xy | tail -n 4 > ${name}_box_aver.dat
grep -v \# ${name}_box_xy.xvg | grep -v \@ | awk ' { N1=102 ; t=$1 ; lx=$2 ; ly=$3 ; print t , lx*ly/(N1/2)}' > ${name}_apl.dat
cp ${name}_apl.dat ${name}_apl.xvg
gmx analyze -f ${name}_apl.xvg -dist ${name}_head_area | tail -n 5 > ${name}_hear_area_all.dat
