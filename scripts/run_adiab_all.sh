#!/bin/bash -f
#
# Script written for the tutorial workshop "QM/MM Modelling of Enzyme Reactions" 
# (C) Marc van der Kamp, 2018
#
# Add AMBERHOME to $PATH, to access the programs (assumes AMBERHHOME is set)
export PATH="$PATH:$AMBERHOME/bin"
# Prepare for adiabatic mapping
# Make directory, e.g. adiab1
# Make sure to have us_rc-0.3.rst file in the directory 
# Adiabatic mapping protocol starts here
# 1 - Initial minimisation with rc=-0.3
#  1.1) get structure from umbrella samling
#cp ../us1/rc-0.30/md1ps.rst md1ps_rc-0.3.rst
#  1.2) set restraint value
sed s,RC,-0.3,g ../data/rc_temp.RST > rc.RST
#  1.3) run minimisation
sander -O -i ../data/min_init.i -p ../data/wt.sp20.top -o min_rc-0.3init.log -c md1ps_rc-0.3.rst -ref  md1ps_rc-0.3.rst -r min_rc-0.3init.rst
# 2 - Prepare for adiabatic mapping with periodic box
#     This step is necessary, because the advanced minimisation algorithms in sander (xmin=3) do not work properly with a solvent "Cap".
#  2.1) get pdb from initial minimisation
printf "parm ../data/wt.sp20.top 
trajin min_rc-0.3init.rst
trajout min_rc-0.3init.pdb
" > make_pdb.in 
cpptraj < make_pdb.in &> make_pdb.out
#  2.2) run pdb through tleap to add box+water
tleap -f ../data/tleap_box.in &> tleap_box.out
#  2.3) select residues allowed to move in minimisations
#       Here, we use cpptraj to write a file with only atoms within 5 Ang of residue CHO
printf "parm wt.box.top
reference min_rc-0.3box.rst
trajin min_rc-0.3box.rst
strip !(:CHO<:5.0)
trajout move.pdb pdb
" > tmp_move.in
cpptraj < tmp_move.in &> tmp_move.out
#       Here, we use the generated pdb file and 'uniq' to get a list of residues with at least one atom in the pdb file
move=`awk '/^ATOM/ {print $5}' move.pdb | uniq | tr '\n' ','`
sed s/MOVE/$move/g ../data/min_xmin3_temp.i > min_xmin3.i
rm tmp_move*
#  2.4) Run quickly forwards to product (in series of minimisations)
start_rc=-0.3box
for rc in 0.0 0.4 0.8 1.0 1.4 1.8; do 
  sed s,RC,$rc,g ../data/rc_temp.RST > rc.RST
  sander -O -i min_xmin3.i -p wt.box.top -o min_rc$rc.log -c min_rc$start_rc.rst -ref min_rc-0.3box.rst -r min_rc$rc.rst
  start_rc=$rc
done
# 3 - Adiabatic mapping
# 3.1) Delete file with energies if present
if [ -e energies.dat ]; then
  rm energies.dat
fi
# 3.2) Run series backwards to reactant - "Adiabatic Mapping"
#      Energies collected in energies.dat
for rc in 1.8 1.6 1.4 1.2 1.0 0.8 0.6 0.4 0.2 0.0 -0.2 -0.3 -0.4 -0.6 -0.8 -1.0 -1.2 -1.4 -1.6 -1.8; do 
  sed s,RC,$rc,g ../data/rc_temp.RST > rc.RST
  sander -O -i min_xmin3.i -p wt.box.top -o min_rc$rc.log -c min_rc$start_rc.rst -ref min_rc-0.3box.rst -r min_rc$rc.rst
  eamber=`cat mdinfo | awk -v eamber=0 '{if ($1=="EAMBER") {eamber=$3}} END {printf("%10.4f",eamber)}'`
  printf "%s\t%s\n" $rc $eamber >> energies.dat
  start_rc=$rc
done
# Adiabatic mapping done
# 4 - Single point QM only energies
for rc in -1.8 -1.6 -1.4 -1.2 -1.0 -0.8 -0.6 -0.4 -0.3 -0.2 0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8; do
  bash ../scripts/sp_qmonly_cho.sh $rc
done > qmonly_energies.dat
# 5 - Single point QM/MM without Arg90
#  Writes energies to Ala90_energies.dat
bash ../scripts/sp_strip_arg90.sh 
# 6 - Put all energies in one data file (in the right order)
sort -n -k 1 energies.dat > tmp
paste tmp qmonly_energies.dat Ala90_energies.dat > adiabatic_mapping_energies.dat
rm tmp

