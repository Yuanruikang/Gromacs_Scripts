#!/bin/bash
alias gmx="gmx -nocopyright"
shopt -s expand_aliases
shopt expand_aliases

gpu_id=0
name=""
cnt=1
cntmax=5
step=0
cpu_nums=20
#gmx convert-tpr -s ${name}.tpr -extend $extend_ps -o ${name}.tpr
#gmx mdrun -ntmpi 1 -ntomp 20 -gpu_id $gpu_id -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${name} -cpi ${name}.cpt -append -s ${name}.tpr
echo 'q' | gmx make_ndx -f step5_input.gro -o index.ndx

mkdir Minimization
mkdir NVT-NPT_Equilibration
#Minimization
cd Minimization
gmx grompp -f ../step6.0_minimization.mdp -o step6.0_minimization0.tpr -c ../step5_input.gro -p ../topol.top
gmx_d mdrun -ntmpi 1 -ntomp 24 -v -deffnm step6.0_minimization0
gmx grompp -f ../step6.0_minimization_1.mdp -o step6.0_minimization.tpr -c step6.0_minimization0.gro -p ../topol.top
gmx_d mdrun -ntmpi 1 -ntomp 24 -v -deffnm step6.0_minimization

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
# Production
gmx  grompp -f ../step7_production.mdp -o ${name}.tpr -c step6.5_equilibration.gro -n ../index.ndx -p ../topol.top
cp ../index.ndx ../../
cp ${name}.tpr ../../
cd ../../
gmx  mdrun -ntmpi 1 -ntomp ${cpu_nums} -gpu_id ${gpu_id} -pme gpu -bonded gpu -nb gpu -update gpu -v -deffnm ${name}

date
