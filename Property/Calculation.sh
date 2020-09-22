#!/bin/bash
alias gmx="gmx -nocopyright"
shopt -s expand_aliases
shopt expand_aliases

name="DDoPC-0919"
begin_ps=400000
end_ps=800000

begin_ns=400
end_ns=800

mkdir sasa
cd sasa
echo 1 | gmx sasa -f ../Traj_${name}_CenMEMB.xtc -s ../${name}.tpr -b $begin_ns -e $end_ns -tu ns
cd ..

mkdir RDF
cd RDF
gmx rdf -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -ref 'com of group "r30-35"' -sel 'name C29' -n ../index_pbc.ndx -b $begin_ps -o ${name}_r30-35_C29

gmx rdf -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -ref 'com of group "r30-35"' -sel 'name P' -n ../index_pbc.ndx -b ${begin_ps} -o ${name}_r30-35_P

gmx rdf -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -ref 'com of resname "LYS"' -sel 'name P' -n ../index_pbc.ndx -b ${begin_ps} -o ${name}_LYS_P

gmx rdf -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -ref 'com of resid 30' -sel 'name P' -n ../index_pbc.ndx -b ${begin_ps} -o ${name}_30_P

gmx rdf -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -ref 'com of resid 32' -sel 'name P' -n ../index_pbc.ndx -b ${begin_ps} -o ${name}_32_P

cd ..

mkdir distance
cd distance

gmx distance -s ../${name}.tpr -f ../Traj_${name}_CenMEMB.xtc -select 'com of group "PO4_UP" plus com of group "r30-35"' -oxyz ${name}_r30-35_PO4_XYZ -n ../index_pbc.ndx -tu ns

gmx analyze -f ${name}_r30-35_PO4_XYZ.xvg -dist ${name}_r30-35_PO4_dist.xvg -b $begin_ns

cd ..
mkdir density
cd density

echo -e "MEMB \n Protein \n P_O11_O12_O13_O14 \n"|gmx density -f ../Traj_${name}_CenMEMB.xtc -s ../${name}.tpr -d z -center -relative -o ${name}_density.xvg -b ${begin_ps} -ng 2 -n ../index_pbc.ndx -dens num

cd ..

