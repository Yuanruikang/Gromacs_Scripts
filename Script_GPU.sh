#!/bin/csh
set num = 24
set gpu_id = 1
set system = "POPC8CHL2"

gmx make_ndx -f step5_input.gro -o index.ndx

#minimization
gmx grompp -f step6.0_minimization.mdp -o step6.0_minimization.tpr -c step5_input.gro -p topol.top

gmx mdrun -ntmpi 1 -ntomp 24 -v -deffnm step6.0_minimization

# Equilibration
set cnt = 1
set cntmax = 6

while ( ${cnt} <= ${cntmax} )
    @ pcnt = ${cnt} - 1
    if ( ${cnt} == 1 ) then

        gmx grompp -f step6.{$cnt}_equilibration.mdp -o step6.{$cnt}_equilibration.tpr -c step6.{$pcnt}_minimization.gro -r step6.0_minimization.gro -n index.ndx -p topol.top

	      gmx mdrun -ntmpi 1 -ntomp 24 -gpu_id {$gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.{$cnt}_equilibration
    else
	      gmx grompp -f step6.{$cnt}_equilibration.mdp -o step6.{$cnt}_equilibration.tpr -c step6.{$pcnt}_equilibration.gro -r step6.0_minimization.gro -n index.ndx -p topol.top

	      gmx mdrun -ntmpi 1 -ntomp 24 -gpu_id {$gpu_id} -pme gpu -bonded gpu  -nb gpu -update gpu -v -deffnm step6.{$cnt}_equilibration
    endif
    @ cnt += 1
end

# Production

gmx grompp -f step7_production.mdp -o ${system}.tpr -c step6.6_equilibration.gro -n index.ndx -p topol.top
cp step6.6_equilibration.gro ../
cp index.ndx ../
cp ${system}.tpr ../
cd ..
gmx mdrun -ntmpi 1 -ntomp 24 -gpu_id ${gpu_id} -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${system}

date

#gmx convert-tpr -s ${system}.tpr -extend 400000 -o ${system}1.tpr #extend ps

#gmx mdrun -ntmpi 1 -ntomp 24 -gpu_id 0 -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${system} -cpi ${system}.cpt -append -s ${system}1.tpr
