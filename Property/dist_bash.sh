#!/bin/bash
i=1
i_all=57
name=pope-40
k=0
rm -rf ${name}_AA_distance
mkdir ${name}_AA_distance
while [ "$i" -lt "$i_all" ];do
awk '{
  if($1=="&")k++;
  if(k==2) 
  {
     if($1>=-1.5)
     print $2
  }
}' r${i}_${name}_dist.xvg >> ${name}_AA_distance/${name}_r${i}dist.dat
let "i++"
done


