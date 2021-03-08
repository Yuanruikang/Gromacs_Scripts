#!/bin/bash
alias gmx="gmx -nocopyright"
shopt -s expand_aliases
shopt expand_aliases
name="pope"
step=0
step_rmsf=300000
#cp  6.0-6.6/index.ndx index_pbc.ndx
mkdir ${name}_Primary_info
mkdir ${name}_Energy
#################################################
cd ${name}_Energy
echo "Potential"| gmx energy -f ../${name}.edr -o energy_potential_${name}.xvg -b $step | tail -n 7 >> log.txt
  
echo "Kinetic-En"| gmx energy -f ../${name}.edr -o energy_kinetic_${name}.xvg -b $step | tail -n 7 >> log.txt
  
echo "Total-Energy"| gmx energy -f ../${name}.edr -o energy_total_${name}.xvg -b $step | tail -n 7 >> log.txt
  
echo "Temperature"| gmx energy -f ../${name}.edr -o energy_temperature_${name}.xvg -b $step | tail -n 7 >> log.txt
  
echo "Pressure"| gmx energy -f ../${name}.edr -o energy_pressure_${name}.xvg -b $step | tail -n 7 >> log.txt
  
echo "Density"| gmx energy -f ../${name}.edr -o energy_density_${name}.xvg -b $step | tail -n 7 >> log.txt

echo -e "Potential \n Kinetic-En \n Total-Energy" | gmx energy -f ../${name}.edr -o energy_3.xvg | tail -n 7 >> log.txt 

echo "Volume" | gmx energy -f ../${name}.edr -o energy_volume_${name}.xvg | tail -n 7 >> log.txt

echo -e "Box-X \n Box-Y \n Box-Z" | gmx energy -f ../${name}.edr -o energy_box_${name}.xvg | tail -n 7 >> log.txt
  
cd ../
#################################################

echo -e "PROT1 \n system" | gmx  trjconv -s ${name}.tpr  -f ${name}.trr -o Traj_${name}_CenPROT.xtc -center -pbc mol -n index_pbc.ndx
echo -e "PO4 \n system" | gmx  trjconv -s ${name}.tpr  -f Traj_${name}_CenPROT.xtc -o Traj_${name}_CenMEMB.xtc -center -pbc mol -n index_pbc.ndx

#echo -e "non-Water" | gmx trjconv -f ${name}.gro -s  ${name}.tpr -o non-water_${name}.gro -pbc mol -n index_pbc.ndx
#echo -e "non-Water" | gmx trjconv -f Traj_${name}_CenMEMB.xtc -s ${name}.tpr  -o non-Water_${name}.xtc -n index_pbc.ndx

cd ${name}_Primary_info

echo 1 | gmx mindist -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -n ../index_pbc.ndx -od mini-Prot_${name}.xvg -pi -tu ns -pbc yes

echo 1 | gmx  gyrate -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -o gyrate_fit_${name}.xvg
echo "PROT1" | gmx  gyrate -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -o gyrate_fit_PROT1_${name}.xvg -n ../index_pbc.ndx
echo "PROT2" | gmx  gyrate -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -o gyrate_fit_PROT2_${name}.xvg -n ../index_pbc.ndx

echo "Protein PO4_Down" | gmx mindist -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -n ../index_pbc.ndx -od mini-Prot-PO4Down_${name}.xvg -tu ns -pbc yes
#starting frame -b
#starting frame -b --!!!!!!!!!!!Attention
echo 1 | gmx rmsf -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc  -o rmsf-per-residue_${name}.xvg -ox average_${name}.pdb -oq bfactors-residue_${name}.pdb -res -b $step_rmsf

echo 1 1 | gmx  rms -s ../6.0-6.6/step5_input.gro -f ../Traj_${name}_CenMEMB.xtc -o rmsd_all_atoms_vs_start_${name}.xvg -tu ns

echo 4 4 | gmx  rms -s ../6.0-6.6/step5_input.gro -f ../Traj_${name}_CenMEMB.xtc -o rmsd_backbone_vs_start_${name}.xvg -tu ns

