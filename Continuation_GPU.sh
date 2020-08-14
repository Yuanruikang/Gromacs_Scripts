#!/bin/csh
read -p "Are the parameters of system set well?:" Yes
set gpu_id = 0
set name = "POPC-insert"
set final_frame = 500000
set extend_ps = 200000
set cnt = 1
set cntmax = 5
set step = 0
echo "=================================
$gpu_id $name $final_frame
================================="
#extend ps
#gmx convert-tpr -s ${name}.tpr -extend $extend_ps -o ${name}.tpr
gmx mdrun -ntmpi 1 -ntomp 20 -gpu_id $gpu_id -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${name} -cpi ${name}.cpt -append -s ${name}.tpr
mv primary_info primary_info_last
mv Energy  Energy_last
mkdir primary_info
mkdir Energy
cd Energy
echo "Potential"| gmx -nocopyright energy -f ../${name}.edr -o energy_Pntential.xvg -b $step
  #xmgrace energy_Potential.xvg
echo "Kinetic-En"| gmx -nocopyright energy -f ../${name}.edr -o energy_kinetic.xvg -b $step
  #xmgrace energy_kinetic.xvg
echo "Total-Energy"| gmx -nocopyright energy -f ../${name}.edr -o energy_Total.xvg -b $step
  #xmgrace energy_Total.xvg
echo "Temperature"| gmx -nocopyright energy -f ../${name}.edr -o energy_Temperature.xvg -b $step
  #xmgrace energy_Temperature.xvg
echo "Pressure"| gmx -nocopyright energy -f ../${name}.edr -o energy_Pressure.xvg -b $step
  #xmgrace energy_Pressure.xvg
echo "Density"| gmx -nocopyright energy -f ../${name}.edr -o energy_Density.xvg -b $step
  #xmgrace energy_Density.xvg
#echo -e "Potential \n Kinetic-En \n Total-Energy" | gmx -nocopyright energy -f ../${name}.edr -o energy_3.xvg
#echo -e "Box-X \n Box-Y \n Box-Z" | gmx -nocopyright energy -f ../${name}.edr -o energy_box.xvg
echo "Volume" | gmx -nocopyright energy -f ../${name}.edr -o energy_volume.xvg
  #xmgrace -block box.xvg -bxy 1:2  -bxy 1:3 -bxy 1:4
cd ../
echo "q"| gmx -nocopyright make_ndx -f ${name}.gro -o index_pbc.ndx -n index.ndx
echo -e "MEMB \n system" | gmx -nocopyright trjconv -s ${name}.tpr -f ${name}.trr -o ${name}_noPBC.xtc -center -pbc mol -n index_pbc.ndx
echo 1 1 | gmx -nocopyright trjconv -f ${name}_noPBC.xtc -s  ${name}.tpr -fit rot+trans -o ${name}_noPBC_fit_Prot.xtc -n index_pbc.ndx
echo 0 | gmx -nocopyright trjconv -f ${name}_noPBC.xtc -s  ${name}.tpr -o ${name}_finalframe.gro -dump $final_frame -sep -n index_pbc.ndx

#sed -i.bak 'M,Nd' filename > newfilename#delete the M-N lines
#sed -e '/TIP3/d'  step6.6_equilibration.gro  > ${name}_nowater.gro   # 删除a.txt中含"abc"的行，将操作之后的结果保存到a.log
#sed '/TIP3/d;/POT/d' step6.6_equilibration.gro  > ${name}_nowater.gro   # 删除含字符串"abc"或“efg"的行，将结果保存到a.log

#==============================================================================================================
cd primary_info
#Gyrate
echo 1 | gmx -nocopyright gyrate -s ../${name}.tpr -f ../${name}_noPBC_fit_Prot.xtc -o gyrate_fit_${name}.xvg

#RMSF
echo 1 | gmx -nocopyright rmsf -f ../${name}.trr -s ../${name}.tpr -o rmsf-per-residue_${name}.xvg -ox average_${name}.pdb -oq bfactors-residue_${name}.pdb -res

#Comparison with the initial structure

echo 1 1 | gmx -nocopyright rms -s ../${name}.tpr -f ../${name}_noPBC.xtc -o rmsd_all_atoms_vs_start_${name}.xvg -tu ns

echo 4 4 | gmx -nocopyright rms -s ../${name}.tpr -f ../${name}_noPBC.xtc -o rmsd_backbone_vs_start_${name}.xvg -tu ns

echo "Protein" | gmx -nocopyright trjconv -f ../${name}_noPBC.xtc  -s ../${name}.tpr -o traj_protein_noPBC_${name}.xtc

echo 1 1 | gmx -nocopyright rms -f traj_protein_noPBC.xtc -s average.pdb -o rmsd-all-atom-vs-average_${name}.xvg -tu ns

echo 1 1 | gmx -nocopyright rms -f traj_protein_noPBC.xtc -s average.pdb -o rmsd-backbone-vs-average_${name}.xvg -tu ns
date
