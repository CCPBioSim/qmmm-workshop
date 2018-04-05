#!/bin/bash -f
#
# Script written for the tutorial workshop "QM/MM Modelling of Enzyme Reactions"
# (C) Marc van der Kamp, 2018
#
# Run cpptraj to perform actions specified in input file
$AMBERHOME/bin/cpptraj < ../strip_arg90.in > strip_arg90.out

# Write sander single-point energy calc input file
echo "Single point energy calculation for each frame of an input trajectory
&cntrl
 imin=5, maxcyc=1,
 ntpr=5,
 ntb=1, 
 ifqnt=1,
/
&qmmm
 qmmask=':CHO',
 qmcharge=-2,
 qm_theory='AM1',
 qmcut=10
/
" > ener.in

# Run energy calculation on stripped trajectory with sander - writes energy of each structure in input trajectory to ener.log (in the order that the structures appears in the trajectory file i.e. product to substrate)
echo "Calculating energy for trajectory with stripped residue..."
$AMBERHOME/bin/sander -O -i ener.in -o ener.log -p Ala90.wt.box.top -c min_Ala90_rc-1.8.rst -y min_Ala90.trj
echo "done!"

# Extract total energy for each step of stripped adiabatic mapping trajectory and print to file (in reverse order so go from the substrate to product)
awk '/minimization completed/ {print $4}' ener.log > Ala90_energies.dat

