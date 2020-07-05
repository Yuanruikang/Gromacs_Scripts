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
gmx mindist -f ${name}.trr -s ${name}.tpr -od minimal-periodic-distance.xvg -pi

#adjust the trajectory

#avoid the trajectory jumping between the bundary of box

#choice 0("System") outputing the whole system,of course ,you can choice other parties which you are interested in

sed -i.bak 'M,Nd' filename > newfilename#delete the M-N lines

sed -e '/TIP3/d'  step6.6_equilibration.gro  > ${name}_nowater.gro   # 删除a.txt中含"abc"的行，将操作之后的结果保存到a.log

sed '/TIP3/d;/POT/d' step6.6_equilibration.gro  > ${name}_nowater.gro   # 删除含字符串"abc"或“efg"的行，将结果保存到a.log

gmx make_ndx -f ${name}.gro -o index_pbc.ndx -n index.ndx

gmx trjconv -s ${name}.tpr -f ${name}.trr -o ${name}_noPBC.xtc -center -pbc mol -n index_pbc.ndx

#gmx trjconv -s ${name}.tpr -f ${name}_noPBC.xtc -o ${name}_nojump.xtc -pbc nojump -ur compact -center
#Gyrate
gmx gyrate -s ${name}.tpr -f ${name}_noPBC.xtc -o gyrate.xvg

#RMSF
gmx rmsf -f ${name}.trr -s ${name}.tpr -o rmsf-per-residue.xvg -ox average.pdb -oq bfactors-residue.pdb -res

#Comparison with the initial structure

gmx rms -s ${name}.tpr -f ${name}_noPBC.xtc -o rmsd_all_atoms_vs_start.xvg -tu ns

gmx rms -s ${name}.tpr -f ${name}_noPBC.xtc -o rmsd_backbone_vs_start.xvg -tu ns

echo "Protein" | gmx trjconv -f ${name}_noPBC.xtc  -s ${name}.tpr -o traj_protein_noPBC.xtc

gmx rms -f traj_protein_noPBC.xtc -s average.pdb -o rmsd-all-atom-vs-average.xvg

gmx rms -f traj_protein_noPBC.xtc -s average.pdb -o rmsd-backbone-vs-average.xvg

#analysis the membrane
#PO4
a P | a O11 | a O12 | a O13 | a O14
gmx distance -s ${name}.tpr -f ${name}_noPBC.xtc -select  'cog of group "MEMB" plus cog of group "PROT"' -oav Distance_PROT_av.xvg -oall Distance_PROT_all.xvg -n index_pbc.ndx
gmx distance -s ${name}.tpr -f ${name}_noPBC.xtc -select  'cog of group "MEMB" plus cog of group "PO4"' -oav Distance_PO4_av.xvg -oall Distance_PO4_all.xvg -n index_pbc.ndx
#N(CH3)3
a N | a C13 | a H13A | a H13B | a H13C | a C14 | a H14A | a H14B | a H14C | a C15 | a H15A | a H15B | a H15C
gmx distance -s ${name}.tpr -f ${name}_noPBC.xtc -select  'cog of group "MEMB" plus cog of group "NCH33"' -oav Distance_NCH33_av.xvg -oall Distance_NCH33_all.xvg -n index_pbc.ndx
#Headgroups
pymol 
show sticks, name C1+C2+C3+N4+C5+C6+O7+P8+O9+O10+O11
