#!/bin/csh
#$ -N ProcessEpiScale
#$ -q long
#$ -pe smp 12
#$ -M pbrodski@nd.edu
#$ -m bea

setenv MATLABPATH /afs/crc.nd.edu/group/Zartman/Pavel/Project3Episcale/Analysis/
cd /afs/crc.nd.edu/group/Zartman/Pavel/Project3Episcale/Analysis/
module load matlab/9.2
matlab -nodisplay -nosplash -r "analyzeT1Transitions(12,'/afs/crc.nd.edu/group/Zartman/Pavel/Project3Episcale/Analysis','force',1)"
