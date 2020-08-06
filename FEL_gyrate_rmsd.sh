#!/bin/bash
name="sapc"
gmx gyrate -s ../${name}.tpr -f ../${name}_noPBC_fit_Prot.xtc -o FEL_gyrate.xvg

gmx rms -s ../${name}.tpr -f ../${name}_noPBC_fit_Prot.xtc -o FEL_rmsd.xvg

perl ./sham.pl -i1 FEL_gyrate.xvg -i2 FEL_rmsd.xvg -date 1 -date2 2 -o gsham_input.xvg

gmx sham -f gsham_input.xvg -ls FES.xpm

python2 xpm2txt.py -f FES.xpm -o fel_${name}_gr_rm.txt
