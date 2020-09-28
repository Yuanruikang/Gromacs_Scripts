#!/bin/bash
alias gmx2018="gmx2018 -nocopyright"
shopt -s expand_aliases
shopt expand_aliases
read -p "Please check your begining time and ending time,and type! AA_amounts!" yes 
read -p "Please input the name" name
type=25
AA_amounts=36
begin_ps=400000
while [ "$type" -lt $AA_amounts ]; do
  {
	  echo r$type
	  echo q
  }|gmx2018 make_ndx -f ../${name}.gro -o index_pbc.ndx -n index_pbc.ndx
  type=$((type + 1))
done
cd ../6.0-6.6/1ns_Equilibration
gmx2018 grompp -f ../../InterE-${name}/step7_rerun.mdp -o ${name}_rerun.tpr -c step6.6_equilibration.gro -n ../../InterE-${name}/index_pbc.ndx -p ../topol.top
cp ${name}_rerun.tpr ../../InterE-${name}
cd ../../InterE-${name}
gmx2018 mdrun -rerun ../${name}.trr -s ${name}_rerun.tpr -o Inter-${name}.trr -e Inter-${name}.edr -g Inter-${name}_energy.log
rm -rf *#
type=25
echo "Energy                      Average   Err.Est.       RMSD  Tot-Drift" >> AAEnergy_${name}.log
while [ "$type" -lt $AA_amounts ]; do
  {
	  echo -e "Coul-SR:r_${type}-MEMB \n LJ-SR:r_${type}-MEMB "
  }|gmx2018 energy -f Inter-${name}.edr -o Inter-${name}_${type}.xvg -b $begin_ps | tail -2 >> AAEnergy_${name}.log
  type=$((type + 1))
done

rm -rf *#

