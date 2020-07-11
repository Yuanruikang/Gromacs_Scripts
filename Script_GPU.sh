#!/bin/csh
set gpu_id =
set name =
echo "the GPU_ID is $gpu_id and the system name is $name"
gmx -nocopyright make_ndx -f step5_input.gro -o index.ndx

#minimization
gmx -nocopyright grompp -f step6.0_minimization.mdp -o step6.0_minimization.tpr -c step5_input.gro -p topol.top

gmx -nocopyright mdrun -ntmpi 1 -ntomp 24 -v -deffnm step6.0_minimization

# Equilibration
set cnt = 1
set cntmax = 6

while ( ${cnt} <= ${cntmax} )
    @ pcnt = ${cnt} - 1
    if ( ${cnt} == 1 ) then

        gmx -nocopyright grompp -f step6.{$cnt}_equilibration.mdp -o step6.{$cnt}_equilibration.tpr -c step6.{$pcnt}_minimization.gro -r step6.0_minimization.gro -n index.ndx -p topol.top

	      gmx -nocopyright mdrun -ntmpi 1 -ntomp 24 -gpu_id {$gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.{$cnt}_equilibration
    else
	      gmx -nocopyright grompp -f step6.{$cnt}_equilibration.mdp -o step6.{$cnt}_equilibration.tpr -c step6.{$pcnt}_equilibration.gro -r step6.0_minimization.gro -n index.ndx -p topol.top

	      gmx -nocopyright mdrun -ntmpi 1 -ntomp 24 -gpu_id {$gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.{$cnt}_equilibration
    endif
    @ cnt += 1
end

# Production

gmx -nocopyright grompp -f step7_production.mdp -o ${name}.tpr -c step6.6_equilibration.gro -n index.ndx -p topol.top
cp step6.6_equilibration.gro ../
cp index.ndx ../
cp ${name}.tpr ../
cd ..
gmx -nocopyright mdrun -ntmpi 1 -ntomp 24 -gpu_id ${gpu_id} -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${name}

date

#gmx convert-tpr -s ${name}.tpr -extend 100000 -o ${name}1.tpr #extend ps

#gmx mdrun -ntmpi 1 -ntomp 24 -gpu_id 1 -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${name} -cpi ${name}.cpt -append -s ${name}1.tpr
