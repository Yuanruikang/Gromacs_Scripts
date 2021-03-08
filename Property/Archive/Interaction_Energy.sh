#!/bin/bash 
alias gmx="gmx -nocopyright"
shopt -s expand_aliases
shopt expand_aliases
read -p "Please check your begining time and ending time,and other settings" yes 
read -p "Please input the name" name
#name="SDPC-insert"
r_0_num=12
r_1_num=1
begin=400000
end=800000
r_0="MEMB"
r_1="Protein"

rm -rf ${name}_log
mkdir ${name}_log
#################################################
type=0
echo -e "$r_0" |gmx trjconv -s ../${name}.tpr  -f ../Traj_${name}_CenMEMB.xtc -n ../index_pbc.ndx -o self-${type}.xtc -b ${begin}  -e ${end}
echo -e "$r_0" |gmx convert-tpr -s ../${name}.tpr -n ../index_pbc.ndx -o self-${type}.tpr
gmx mdrun -rerun self-${type}.xtc -s self-${type}.tpr -o self-${type}.trr -e self-${type}.edr -g self-${type}_energy.log
echo -e "LJ-(SR) \n Coulomb-(SR) \n Coul.-recip."  | gmx energy -f self-${type}.edr -o self-${type}.xvg  | tail -5 > self-${type}.log
mv self-${type}.log ${name}_log
#################################################
type=1
  echo -e "${r_1}" |gmx trjconv -s ../${name}.tpr  -f ../Traj_${name}_CenMEMB.xtc -n ../index_pbc.ndx -o self-${type}.xtc -b ${begin}  -e ${end}
  echo -e "${r_1}" |gmx convert-tpr -s ../${name}.tpr -n ../index_pbc.ndx -o self-${type}.tpr
  gmx mdrun -rerun self-${type}.xtc -s self-${type}.tpr -o self-${type}.trr -e self-${type}.edr -g self-${type}_energy.log
  echo -e "LJ-(SR) \n Coulomb-(SR) \n Coul.-recip."  | gmx energy -f self-${type}.edr -o self-${type}.xvg  | tail -5 > self-${type}.log
  mv self-${type}.log ${name}_log
###############################################
type="PROT-MEMB"
  {
    echo  "$r_1_num |  $r_0_num "
    echo q
  } |gmx make_ndx -f ../${name}.tpr -o inter-${type}.ndx -n ../index_pbc.ndx
  echo -e "${r_1}_MEMB" |gmx trjconv -s ../${name}.tpr  -f ../Traj_${name}_CenMEMB.xtc -n inter-${type}.ndx -o inter-${type}.xtc -b ${begin}  -e ${end}
  echo -e "${r_1}_MEMB" |gmx convert-tpr -s ../${name}.tpr -n inter-${type}.ndx -o inter-${type}.tpr
  gmx mdrun -ntmpi 1 -ntomp 20 -rerun inter-${type}.xtc -s inter-${type}.tpr -o inter-${type}.trr -e inter-${type}.edr -g inter-${type}_energy.log
  echo -e "LJ-(SR) \n Coulomb-(SR) \n Coul.-recip."  | gmx energy -f inter-${type}.edr -o inter-${type}.xvg  | tail -5 > inter-${type}.log
  mv inter-${type}.log ${name}_log
  ###############################################
rm -rf inter-*
rm -rf self-*
rm -rf *#
