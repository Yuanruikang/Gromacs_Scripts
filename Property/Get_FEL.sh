#!/bin/bash
name="SDPC"
echo 3 3 | gmx -nocopyright covar -s ../${name}.tpr -f ../${name}_noPBC_fit_Prot.xtc -o -v -xpma

echo 3 3 | gmx -nocopyright anaeig -f ../${name}_noPBC_fit_Prot.xtc  -s ../${name}.tpr -v eigenvec.trr -last 1 -proj pc1.xvg

echo 3 3 | gmx -nocopyright anaeig -f ../${name}_noPBC_fit_Prot.xtc -s ../${name}.tpr -v eigenvec.trr -first 2 -last 2 -proj pc2.xvg

perl ./sham.pl -i1 pc1.xvg -i2 pc2.xvg -date 1 -date2 2 -o gsham_input.xvg

gmx -nocopyright sham -f gsham_input.xvg -ls FES.xpm

python2 xpm2txt.py -f FES.xpm -o fel_${name}.txt
