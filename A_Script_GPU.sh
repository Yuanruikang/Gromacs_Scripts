#!/bin/csh
set gpu_id = 1
set name = "SDPC"
set final_frame = 100000
set cnt = 1
set cntmax = 5
set step = 0
#gmx convert-tpr -s ${name}.tpr -extend 100000 -o ${name}.tpr #extend ps
#gmx mdrun -ntmpi 1 -ntomp 20 -gpu_id 0 -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${name} -cpi ${name}.cpt -append -s ${name}.tpr
gmx -nocopyright make_ndx -f step5_input.gro -o index.ndx
mkdir Minimization
mkdir NVT-NPT_Equilibration
mkdir 1ns_Equilibration
#Minimization
cd Minimization
gmx -nocopyright grompp -f ../step6.0_minimization.mdp -o step6.0_minimization.tpr -c ../step5_input.gro -p ../topol.top

gmx -nocopyright mdrun -ntmpi 1 -ntomp 24 -v -deffnm step6.0_minimization
cd ../
# Equilibration
cd NVT-NPT_Equilibration
while ( ${cnt} <= ${cntmax} )
    @ pcnt = ${cnt} - 1
    if ( ${cnt} == 1 ) then
        gmx -nocopyright grompp -f ../step6.{$cnt}_equilibration.mdp -o step6.{$cnt}_equilibration.tpr -c ../Minimization/step6.{$pcnt}_minimization.gro -r ../Minimization/step6.0_minimization.gro -n ../index.ndx -p ../topol.top

	      gmx -nocopyright mdrun -ntmpi 1 -ntomp 24 -gpu_id {$gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.{$cnt}_equilibration
    else
	      gmx -nocopyright grompp -f ../step6.{$cnt}_equilibration.mdp -o step6.{$cnt}_equilibration.tpr -c step6.{$pcnt}_equilibration.gro -r ../Minimization/step6.0_minimization.gro -n ../index.ndx -p ../topol.top

	      gmx -nocopyright mdrun -ntmpi 1 -ntomp 24 -gpu_id {$gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.{$cnt}_equilibration
    endif
    @ cnt += 1
end
#Pre-Production
cd ../
cd 1ns_Equilibration
gmx -nocopyright grompp -f ../step6.{$cnt}_equilibration.mdp -o step6.{$cnt}_equilibration.tpr -c ../NVT-NPT_Equilibration/step6.5_equilibration.gro -r ../Minimization/step6.0_minimization.gro -n ../index.ndx -p ../topol.top
gmx -nocopyright mdrun -ntmpi 1 -ntomp 24 -gpu_id {$gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.{$cnt}_equilibration

# Production
gmx -nocopyright grompp -f ../step7_production.mdp -o ${name}.tpr -c ../1ns_Equilibration/step6.6_equilibration.gro -n ../index.ndx -p ../topol.top
cp ../1ns_Equilibration/step6.6_equilibration.gro ../../
cp ../index.ndx ../../
cp ${name}.tpr ../../
cd ../../
gmx -nocopyright mdrun -ntmpi 1 -ntomp 12 -gpu_id ${gpu_id} -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${name}
mkdir primary_info
mkdir density
mkdir Scd
mkdir RDF
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
echo -e "Potential \n Kinetic-En \n Total-Energy" | gmx -nocopyright energy -f ../${name}.edr -o energy_3.xvg
echo "Volume" | gmx -nocopyright energy -f ../${name}.edr -o energy_volume.xvg
echo -e "Box-X \n Box-Y \n Box-Z" | gmx -nocopyright energy -f ../${name}.edr -o energy_box.xvg
  #xmgrace -block box.xvg -bxy 1:2  -bxy 1:3 -bxy 1:4
cd ../
echo "q"| gmx make_ndx -f ${name}.gro -o index_pbc.ndx -n index.ndx
mkdir traj
cd traj
echo -e "MEMB \n system" | gmx trjconv -s ../${name}.tpr -f ../${name}.trr -o ${name}_noPBC.xtc -center -pbc mol -n ../index_pbc.ndx
echo 1 1 | gmx trjconv -f ../${name}_noPBC.xtc -s  ../${name}.tpr -fit rot+trans -o ${name}_noPBC_fit_Prot.xtc -n ../index_pbc.ndx
echo 0 | gmx trjconv -f ../${name}_noPBC.xtc -s  ../${name}.tpr -o ${name}_finalframe.gro -dump $final_frame -sep -n ../index_pbc.ndx
date
