#!/bin/csh
#$ -N ProcessEpiScale
#$ -q long
#$ -pe smp 2
#$ -M pbrodski@nd.edu
#$ -m bea

cd /afs/crc.nd.edu/group/Zartman/Pavel/Project3Episcale/Analysis
module load matlab/9.2
MATLABPATH="/afs/crc.nd.edu/group/Zartman/Pavel/Project3Episcale/Analysis"
matlab -nodisplay -nosplash -nojvm -r < "analyzeT1Transitions(2)"
