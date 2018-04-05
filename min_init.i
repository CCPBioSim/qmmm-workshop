Short QM/MM minimization with ibelly restraint outside 18.0 sphere (sp20)
&cntrl
 imin=1, maxcyc=500, ntmin=1, ncyc=100,
 ntpr=50, 
 ntb=0, 
 ntb=0, cut=10,
 ibelly=1,
 bellymask=':232@C1<:18',
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

