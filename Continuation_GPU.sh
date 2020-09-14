#!/bin/bash
read -p "Are the parameters of system set well?:" Yes
#final_frame=500000
gpu_id=0
name="POPC-insert"
extend_ps=200000
cnt=1
cntmax=5
step=0
echo "=================================
$gpu_id $name $final_frame
================================="
#extend ps
gmx convert-tpr -s ${name}.tpr -until $extend_ps -o ${name}.tpr
gmx mdrun -ntmpi 1 -ntomp 20 -gpu_id $gpu_id -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${name} -cpi ${name}.cpt -append -s ${name}.tpr

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
echo -e "Potential \n Kinetic-En \n Total-Energy" | gmx -nocopyright energy -f ../${name}.edr -o energy_3.xvg
echo -e "Box-X \n Box-Y \n Box-Z" | gmx -nocopyright energy -f ../${name}.edr -o energy_box.xvg
echo "Volume" | gmx -nocopyright energy -f ../${name}.edr -o energy_volume.xvg
  #xmgrace -block box.xvg -bxy 1:2  -bxy 1:3 -bxy 1:4

#================================================
cd ../
echo -e "MEMB \n system" | gmx  trjconv -s ${name}.tpr -f ${name}.trr -o Traj_${name}_noPBC.xtc -center -pbc mol -n index_pbc.ndx
echo 1 1 | gmx trjconv -f Traj_${name}_noPBC.xtc -s  ${name}.tpr -fit rot+trans -o ${name}_noPBC_fit_Prot.xtc -n index_pbc.ndx
echo 1 1 | gmx  trjconv -f ${name}.gro -s  ${name}.tpr -o ${name}_finalframe.gro -pbc mol -center

echo -e "PROT \n non-Water" | gmx  trjconv -s ${name}.tpr -f Traj_${name}_noPBC.xtc -o Traj_${name}_CenPROT.xtc -center -pbc mol -n index_pbc.ndx
echo -e "MEMB_UP \n non-Water" | gmx  trjconv -s ${name}.tpr -f Traj_${name}_CenPROT.xtc -o Traj_${name}_CenMEMB.xtc -center -pbc mol -n index_pbc.ndx

cd primary_info
echo 1 | gmx mindist -nocopyright -s ../${name}.tpr -f ../${name}.trr -n ../index_pbc.ndx -od mini-Prot_${name}.xvg -pi -tu ns -pbc yes

echo 1 | gmx -nocopyright gyrate -s ../${name}.tpr -f ../${name}_noPBC_fit_Prot.xtc -o gyrate_fit_${name}.xvg

#starting frame -b  
echo 1 | gmx -nocopyright rmsf -s ../${name}.tpr -f ../${name}_noPBC_fit_Prot.xtc  -o rmsf-per-residue_${name}.xvg -ox average_${name}.pdb -oq bfactors-residue_${name}.pdb -res

echo 1 1 | gmx -nocopyright rms -s ../6.0-6.6/step5_input.gro -f ../Traj_${name}_CenPROT.xtc -o rmsd_all_atoms_vs_start_${name}.xvg -tu ns

echo 4 4 | gmx -nocopyright rms -s ../6.0-6.6/step5_input.gro -f ../Traj_${name}_CenPROT.xtc -o rmsd_backbone_vs_start_${name}.xvg -tu ns

echo 1 1 | gmx -nocopyright rms -f ../${name}_noPBC_fit_Prot.xtc -s average_${name}.pdb -o rmsd-all-atom-vs-average_${name}.xvg -tu ns

echo 4 4 | gmx -nocopyright rms -f ../${name}_noPBC_fit_Prot.xtc -s average_${name}.pdb -o rmsd-backbone-vs-average_${name}.xvg -tu ns

date
