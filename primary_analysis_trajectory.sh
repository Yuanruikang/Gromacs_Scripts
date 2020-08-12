#!/bin/bash
name=" "
sed -i.bak 'M,Nd' filename > newfilename#delete the M-N lines

sed -e '/TIP3/d'  step6.6_equilibration.gro  > ${name}_nowater.gro   # 删除a.txt中含"abc"的行，将操作之后的结果保存到a.log

sed '/TIP3/d;/POT/d' step6.6_equilibration.gro  > ${name}_nowater.gro   # 删除含字符串"abc"或“efg"的行，将结果保存到a.log

#==============================================================================================================
#Gyrate
echo 1 | gmx gyrate -s ../${name}.tpr -f ../${name}_noPBC_fit_Prot.xtc -o gyrate_fit_${name}.xvg

#RMSF
gmx rmsf -f ../${name}.trr -s ../${name}.tpr -o rmsf-per-residue_${name}.xvg -ox average_${name}.pdb -oq bfactors-residue_${name}.pdb -res

#Comparison with the initial structure

echo 1 1 | gmx rms -s ../${name}.tpr -f ../${name}_noPBC.xtc -o rmsd_all_atoms_vs_start_${name}.xvg -tu ns

echo 4 4 | gmx rms -s ${name}.tpr -f ${name}_noPBC.xtc -o rmsd_backbone_vs_start_${name}.xvg -tu ns

echo "Protein" | gmx trjconv -f ${name}_noPBC.xtc  -s ${name}.tpr -o traj_protein_noPBC_${name}.xtc

gmx rms -f traj_protein_noPBC.xtc -s average.pdb -o rmsd-all-atom-vs-average_${name}.xvg -tu ns

gmx rms -f traj_protein_noPBC.xtc -s average.pdb -o rmsd-backbone-vs-average_${name}.xvg -tu ns
