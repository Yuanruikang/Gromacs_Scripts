#!/bin/bash
#final_frame=
alias gmx="gmx -nocopyright"
shopt -s expand_aliases
shopt expand_aliases

gpu_id=1
name=""
cnt=1
cntmax=5
step=0
cpu_nums=20

echo 'q' | gmx make_ndx -f step5_input.gro -o index.ndx

mkdir Minimization
mkdir NVT-NPT_Equilibration
mkdir 1ns_Equilibration

#Minimization
cd Minimization
gmx grompp -f ../step6.0_minimization.mdp -o step6.0_minimization.tpr -c ../step5_input.gro -p ../topol.top
gmx mdrun -ntmpi 1 -ntomp 24 -v -deffnm step6.0_minimization
cd ../

# Equilibration
cd NVT-NPT_Equilibration
while (($cnt <= $cntmax))
do
    pcnt=`expr $cnt - 1`
    if [ $cnt == 1 ]
    then
        gmx  grompp -f ../step6.${cnt}_equilibration.mdp -o step6.${cnt}_equilibration.tpr -c ../Minimization/step6.${pcnt}_minimization.gro -r ../Minimization/step6.0_minimization.gro -n ../index.ndx -p ../topol.top

        gmx  mdrun -ntmpi 1 -ntomp 24 -gpu_id ${gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.${cnt}_equilibration
    else
        gmx  grompp -f ../step6.${cnt}_equilibration.mdp -o step6.${cnt}_equilibration.tpr -c step6.${pcnt}_equilibration.gro -r ../Minimization/step6.0_minimization.gro -n ../index.ndx -p ../topol.top

        gmx  mdrun -ntmpi 1 -ntomp 24 -gpu_id ${gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.${cnt}_equilibration
    fi
    let "cnt++"
done
cd ../

#Pre-Production
cd 1ns_Equilibration
gmx  grompp -f ../step6.${cnt}_equilibration.mdp -o step6.${cnt}_equilibration.tpr -c ../NVT-NPT_Equilibration/step6.5_equilibration.gro -r ../Minimization/step6.0_minimization.gro -n ../index.ndx -p ../topol.top
gmx  mdrun -ntmpi 1 -ntomp ${cpu_nums} -gpu_id ${gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.${cnt}_equilibration

# Production
gmx  grompp -f ../step7_production.mdp -o ${name}.tpr -c step6.6_equilibration.gro -n ../index.ndx -p ../topol.top
cp ../index.ndx ../../
cp ${name}.tpr ../../
cd ../../
gmx  mdrun -ntmpi 1 -ntomp ${cpu_nums} -gpu_id ${gpu_id} -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${name}

mkdir primary_info
mkdir density
mkdir Scd
mkdir RDF
mkdir Energy
mkdir Distance
#################################################
cd Energy
echo "Potential"| gmx  energy -f ../${name}.edr -o energy_Pntential.xvg -b $step
  #xmgrace energy_Potential.xvg
echo "Kinetic-En"| gmx energy -f ../${name}.edr -o energy_kinetic.xvg -b $step
  #xmgrace energy_kinetic.xvg
echo "Total-Energy"| gmx energy -f ../${name}.edr -o energy_Total.xvg -b $step
  #xmgrace energy_Total.xvg
echo "Temperature"| gmx energy -f ../${name}.edr -o energy_Temperature.xvg -b $step
  #xmgrace energy_Temperature.xvg
echo "Pressure"| gmx energy -f ../${name}.edr -o energy_Pressure.xvg -b $step
  #xmgrace energy_Pressure.xvg
echo "Density"| gmx energy -f ../${name}.edr -o energy_Density.xvg -b $step
  #xmgrace energy_Density.xvg
echo -e "Potential \n Kinetic-En \n Total-Energy" | gmx energy -f ../${name}.edr -o energy_3.xvg
echo "Volume" | gmx energy -f ../${name}.edr -o energy_volume.xvg
echo -e "Box-X \n Box-Y \n Box-Z" | gmx energy -f ../${name}.edr -o energy_box.xvg
  #xmgrace -block box.xvg -bxy 1:2  -bxy 1:3 -bxy 1:4
cd ../
#################################################
mv index.ndx index_pbc.ndx

echo -e "Protein \n system" | gmx  trjconv -s ${name}.tpr -f ${name}.trr -o Traj_${name}_CenPROT.xtc -center -pbc mol -n index_pbc.ndx
echo -e "MEMB \n system" | gmx  trjconv -s ${name}.tpr -f Traj_${name}_CenPROT.xtc -o Traj_${name}_CenMEMB.xtc -center -pbc mol -n index_pbc.ndx

#echo -e "non-Water" | gmx  trjconv -f ${name}.gro -s  ${name}.tpr -o ${name}_nowater.gro -pbc mol -n index_pbc.ndx
#echo -e "non-Water" | gmx trjconv -f Traj_${name}_CenMEMB.xtc -s ${name}.tpr  -o Traj_non-Water.xtc -n index_pbc.ndx

cd primary_info
echo 1 | gmx mindist -s ../${name}.tpr -f ../${name}.trr -n ../index_pbc.ndx -od mini-Prot_${name}.xvg -pi -tu ns -pbc yes

echo 1 | gmx gyrate -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -o gyrate_fit_${name}.xvg

#starting frame -b
#starting frame -b --!!!!!!!!!!!Attention
echo 1 | gmx rmsf -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc  -o rmsf-per-residue_${name}.xvg -ox average_${name}.pdb -oq bfactors-residue_${name}.pdb -res

echo 1 1 | gmx  rms -s ../6.0-6.6/step5_input.gro -f ../Traj_${name}_CenMEMB.xtc -o rmsd_all_atoms_vs_start_${name}.xvg -tu ns

echo 4 4 | gmx  rms -s ../6.0-6.6/step5_input.gro -f ../Traj_${name}_CenMEMB.xtc -o rmsd_backbone_vs_start_${name}.xvg -tu ns
date
