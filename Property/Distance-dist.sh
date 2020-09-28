#!/bin/bash
alias gmx="gmx -nocopyright"
shopt -s expand_aliases
shopt expand_aliases
read -p "Please check your begining time and ending time,and other settings" yes 
read -p "Please input the name" name
type=25
AA_amounts=36
echo "SS3                      Average   Err.Est.       RMSD  Tot-Drift" >> AAEnergy_${name}.log
while [ "$type" -lt $AA_amounts ]; do
  gmx distance -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc  -oxyz ${name}_r${type}_PO4_XYZ -tu ns -n ../index_pbc.ndx -select "com of group "MEMB" plus res_com of resnr ${type}"
  gmx analyze -f ${name}_r${type}_PO4_XYZ.xvg -dist r${type}_${name}_dist.xvg -b 400 | tail -2 >> AAEnergy_${name}.log
  type=$((type + 1))
done
rm -rf *#
