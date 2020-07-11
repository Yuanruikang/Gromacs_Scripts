#!/bin/bash
name=" "
########################PART1 Does the system have balanced######################

#***inspect the Energy properties

echo "Potential"| gmx energy -f ${name}.edr -o energy_Pntential.xvg -b $step
Xmgrace energy_Potential.xvg

echo "Kinetic-En"| gmx energy -f ${name}.edr -o energy_kinetic.xvg -b $step

Xmgrace energy_kinetic.xvg

echo "Total-Energy"| gmx energy -f ${name}.edr -o energy_Total.xvg -b $step

Xmgrace energy_Total.xvg

echo "Temperature"| gmx energy -f ${name}.edr -o energy_Temperature.xvg -b $step

Xmgrace energy_Temperature.xvg

echo "Pressure"| gmx energy -f ${name}.edr -o energy_Pressure.xvg -b $step

Xmgrace energy_Pressure.xvg

echo "Density"| gmx energy -f ${name}.edr -o energy_Density.xvg -b $step

Xmgrace energy_Density.xvg

echo -e "Potential \n Kinetic-En \n Total-Energy" | gmx energy -f ${name}.edr -o energy_3.xvg

echo "Volume" | gmx energy -f ${name}.edr -o energy_volume.xvg

echo -e "Box-X\nBox-Y\nBox-Z" | gmx energy -f ${name}.edr -o energy_box.xvg

xmgrace -block box.xvg -bxy 1:2  -bxy 1:3 -bxy 1:4
#check the minimum mirror
echo 1 | gmx mindist -f ${name}.trr -s ${name}.tpr -od minimal-periodic-distance.xvg -pi -tu ns

#adjust the trajectory

#avoid the trajectory jumping between the bundary of box

#choice 0("System") outputing the whole system,of course ,you can choice other parties which you are interested in

sed -i.bak 'M,Nd' filename > newfilename#delete the M-N lines

sed -e '/TIP3/d'  step6.6_equilibration.gro  > ${name}_nowater.gro   # 删除a.txt中含"abc"的行，将操作之后的结果保存到a.log

sed '/TIP3/d;/POT/d' step6.6_equilibration.gro  > ${name}_nowater.gro   # 删除含字符串"abc"或“efg"的行，将结果保存到a.log

gmx make_ndx -f ${name}.gro -o index_pbc.ndx -n index.ndx

echo -e "MEMB \n system" | gmx trjconv -s ${name}.tpr -f ${name}.trr -o ${name}_noPBC.xtc -center -pbc mol -n index_pbc.ndx

echo 1 0 | gmx trjconv -f ${name}_noPBC.xtc -s  ${name}.tpr -fit rot+trans -o ${name}_noPBC_fit.xtc -n index_pbc.ndx

frame=200000
echo 0 | gmx trjconv -f ${name}_noPBC_fit.xtc -s  ${name}.tpr -o ${name}_final_frame.gro -dump $frame -sep -n index_pbc.ndx


#Gyrate
echo 1 | gmx gyrate -s ${name}.tpr -f ${name}_noPBC.xtc -o gyrate.xvg

#RMSF
gmx rmsf -f ${name}.trr -s ${name}.tpr -o rmsf-per-residue.xvg -ox average.pdb -oq bfactors-residue.pdb -res

#Comparison with the initial structure

echo 1 1 | gmx rms -s ${name}.tpr -f ${name}_noPBC.xtc -o rmsd_all_atoms_vs_start.xvg -tu ns

echo 4 4 | gmx rms -s ${name}.tpr -f ${name}_noPBC.xtc -o rmsd_backbone_vs_start.xvg -tu ns

echo "Protein" | gmx trjconv -f ${name}_noPBC.xtc  -s ${name}.tpr -o traj_protein_noPBC.xtc

gmx rms -f traj_protein_noPBC.xtc -s average.pdb -o rmsd-all-atom-vs-average.xvg -tu ns

gmx rms -f traj_protein_noPBC.xtc -s average.pdb -o rmsd-backbone-vs-average.xvg -tu ns
