#!/bin/bash

# Prepare for Umbrella sampling, WITHOUT spawning:
#  - create directory for each rc
#  - create md inputfile(s) for each rc (requires presence of 'template' $md_files)
#  - create restraint (.RST) files for each rc
#  - create job submission script that runs series of jobs (run_umb_samp.sh)
#  Marc van der Kamp, 27/3/2018
#
##### THE FOLLOWING IS THE ESSENTIAL USER INPUT! #####
#
# Necessary files - all need to be present, with their relative paths from working dir
prmtop="../wt.sp20.top"
restart="md.rst"
md_files="../md1ps.i"
# Reaction coordinate values, restraint, definition
start_rc=-1.8
end_rc=1.8
step=0.15	# NB: if start_rc > end_rc, make step<0 
kumb=100	# Force constant, in ..
rc_hrs=0.5      # Estimate of time (in hrs) jobs for one rc-value will take - for job submission script
# Define expr OR rc_iat for rc definition 
# 	(for details, check Amber manual section "Distance, angle and torsional restraints", e.g. Amber11.pdf section 6.1.1)
# NB rc_expr is currently not always handled correctly by AMBER/sander. Use rc_iat instead.
#rc_line="restraint = \"coordinate(distance(3757,3755),1.0,distance(3741,3762),-1.0)\""
rc_line="iat=3757,3755,3741,3762, rstwt=1,-1,"
#
################### END USER INPUT ###################
#

#### Start preparing directories and files
qsub_file="run_umb_samp.sh"

echo "Preparing the following reaction coordinate values:"

# Write the job submission script, except for jobs
# Now PBS options are hard-coded, so users may need to change them
# Working dir
workdir=`pwd`
jobname=`basename $workdir`
jobname=$jobname"_wt"
# Guess time needed on 1 node / 8 procs
nodes=1
procs=1
hours=0
#for ((i=$start; i<=$end; i++)); do hours=`echo "$hours + $rc_hrs" | bc`; done
#hrs=`printf "%.0f" $hours`
hrs=3
#
# Print the first part of the job script
#
printf "#!/bin/bash
#
# If running on cluster, add queing system settings here
# e.g. for PBS (replace JOB with PBS):
#JOB -l walltime=$hrs:00:00,nodes=$nodes:ppn=1
#JOB -N $jobname
#JOB -j oe
#
# 0. Run what you need to run to set AMBERHOME ('Load amber')
#source \$HOME/amber16/amber.sh
#
# 1. Set  working directory   
export MYDIR=\"$workdir\"
#
# Change into the simulation run directory
cd \$MYDIR
#
# 2. Set the executable name  
#
export MYEXE=\"\$AMBERHOME/bin/sander\"
# ---------------------------------------------------------------
# EXECUTE a number of amber jobs
" > $qsub_file


#### Start THE loop 
# In case 'bc' is not present, use hard-coded r1 and r4)
for i in `seq $start_rc $step $end_rc`; do
       rc=`printf "%3.2f" $i`
       r1=`echo "scale=2; $rc-10" | bc`
       r4=`echo "scale=2; $rc+10" | bc`
       #r1=-10.0
       #r4=10.0 
       printf "\t%s\n" $rc
# Continue
	mkdir rc$rc
	cd rc$rc 
	# Write .RST file 
	printf "# reaction coordinate d(O7-C5) - d(C1-C9)
&rst 
$rc_line,
r1=$r1,r2=$rc,r3=$rc,r4=$r4,
rk2=$kumb,rk3=$kumb,
/
&rst
iat=3757,3755,3741,3762, rstwt=1,-1,
rk2=0,rk3=0,
/" > rc$rc.RST
	# Write md inputfiles, using 'template' md files
	temp_count=0
	for template in $md_files; do
		temp_count=`expr $temp_count + 1`
		#file=`basename $template | sed -e "s,\.i,_rc$rc.i,g"`
		mdname=`basename $template | sed -e "s,\.i,,g"`
		sed -e "s/ifqnt=1,/ifqnt=1, nmropt=1,/g" ../$template > $mdname.i
		printf "&wt type=\'DUMPFREQ\', istep1=1 /
&wt type=\'END\' /
DISANG=rc$rc.RST
DUMPAVE=rc${rc}_$temp_count.tra" >> $mdname.i
	        # Add execute lines to job submission script
        	printf "cd $workdir/rc$rc\n" >> ../$qsub_file
        	#printf "mpirun -i $mdname.i -o $mdname.log -r ../$restart\n" >> ../$qsub_file
		printf "\$MYEXE -O -i $mdname.i -o $mdname.log -p ../$prmtop -c ../$restart -x $mdname.nc -r $mdname.rst\n" >> ../$qsub_file
                restart="rc$rc/$mdname.rst"
	done
	cd ..
done

echo "All done."
echo "   Carefully check the contents of the reaction coordinate directories created."
echo "   Check and, if neccesary, alter the job submission file: run_umb_samp.sh"
echo "Have fun umbrella sampling!"
