Short QM/MM minimization with ntr restraint on all residues that have all atoms >5 Ang from CHO
&cntrl
 imin=1, maxcyc=10000, ntmin=3, drms=0.05,
 ntpr=10, ntxo=1, 
 ntb=1, 
 ntr=1, restraint_wt=50.0,
 restraintmask='!:MOVE',
 ifqnt=1, nmropt=1
/
&qmmm
 qmmask=':CHO',
 qmcharge=-2,
 qm_theory='PM6',
 qmshake=0,
 qmcut=10
/
&wt type='END' /
DISANG=rc.RST
