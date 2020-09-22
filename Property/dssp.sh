#!/bin/bash
read -p "name" name
cd ../6.0-6.6/1ns_Equilibration
gmx2018 grompp -f ../step7_production.mdp -o ${name}2018version.tpr -c step6.6_equilibration.gro -n ../index.ndx -p ../topol.top
cp ${name}2018version.tpr ../../dssp
cd ../../dssp
echo 1 | gmx2018 do_dssp -f ../Traj_${name}_CenMEMB.xtc -s ${name}2018version.tpr -o ${name}.xpm -sc ${name}_scount.xvg -tu ns
gmx2018 xpm2ps -f ${name}.xpm -by 10 -bx 0.1 -o ${name}.eps
