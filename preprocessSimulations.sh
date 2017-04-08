#!/bin/csh
#$ -N ProcessEpiScale
#$ -q long
#$ -pe smp 8

setenv MATLABPATH /afs/crc.nd.edu/group/Zartman/Pavel/Project3Episcale/GrowthStudy
cd /afs/crc.nd.edu/group/Zartman/Pavel/Project3Episcale/GrowthStudy
module load matlab/9.2
matlab -nodisplay -nosplash -nojvm -r < "convertSimulationOutput(8)"
