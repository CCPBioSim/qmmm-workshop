#!/bin/bash -f
#
# Script written for the tutorial workshop "QM/MM Modelling of Enzyme Reactions"
# (C) Marc van der Kamp, 2018
#
# Script to run a single-point QM energy calculation for only CHO (chorismate)
# Reaction coordinate value to calculate energy for (USER INPUT)
rc=$1
# Start of sqm input file
printf "Run semi-empirical single-point calculation
 &qmmm
  qm_theory=\'AM1\', qmcharge=-2, maxcyc=0,
 /
" > sqm.in
# Fill in coordinate section of sqm input file
#   1) Use ambmask to print only CHO coordinates from restart file in PDB format
#   2) Use awk to convert PDB format to sqm coordinate and add to input
$AMBERHOME/bin/ambmask -p wt.box.top -c min_rc$rc.rst -prnlev 0 -out pdb -find :CHO | awk '/^ATOM/ {if ($4=="CHO") {if (substr($3,1,1)=="C") {z=6};if (substr($3,1,1)=="H") {z=1};if (substr($3,1,1)=="N") {z=7};if (substr($3,1,1)=="O") {z=8}; printf("%4d   %s   %6.3f    %6.3f   %6.3f\n",z,substr($3,1,1),$6,$7,$8)}}' >> sqm.in
echo "" >> sqm.in
# Run SQM
$AMBERHOME/bin/sqm -O -i sqm.in -o sqm.out
# Print the QM energy 
awk '/Total SCF energy/ {print $5}' sqm.out 
