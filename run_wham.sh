#!/bin/bash -f
#
# Script written for the tutorial workshop "QM/MM Modelling of Enzyme Reactions"
# (C) Marc van der Kamp, 2018
#
# Run Weighted Histogram Analysis Method (or WHAM) on the data from umbrella sampling
# This is for the WHAM code installed from: http://membrane.urmc.rochester.edu/content/wham
# Assumes $WHAM_HOME is set.
#
if [ -z $WHAM_HOME ]; then
   echo "Please set \$WHAM_HOME and try again. Exiting..."
   exit
fi
# 0. Make .tra files with just the 1st column and 3rd column of the .tra files  from umbrella sampling (as the reaction co-ordinate values were not correctly written to the second column by this particular Amber installation)
for rc in `seq -1.8 0.15 1.8`; do awk '{printf "%s  %s\n",$1,$3}' rc$rc/rc${rc}_1.tra > rc$rc/rc${rc}_2.tra; done
# 1. Make a 'meta file' referencing the corrected .tra files - note that force-constant needs to be doubled, so set to 200 (due to different definition)
for i in `seq -1.8 0.15 1.8`; do echo "rc$i/rc${i}_2.tra $i 200"; done > meta.dat
# 2. Run wham with extremes and number of bins such that we'll get bins of 0.05 Ang width and midpoints of -1.8, -1.6 etc.
$WHAM_HOME/wham/wham P -1.825 1.825 73 0.000000001 300 0 meta.dat wham.txt 0 1 &> wham.log
