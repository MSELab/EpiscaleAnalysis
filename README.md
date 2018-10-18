# Summary
This repo contains analysis scripts that were used to interpret simulation results and tune some of the simulation parameters for the EpiScale simulation. A sample simulation output is shown here: https://www.youtube.com/watch?v=t12xhtv3py0

# How to use the code
A list of simulations is stored in DataIndex.xlsx. That list corresponds to the organization of directories in the /Data folder. The script file preprocessSimulations will run the matlab file analyzeT1Transitions. This results in generating a .mat file in each simulation folder with easily-accessible data for each simulation, and a .mat file with a T1 transition analysis.

- The main EpiScale project is available at: https://github.com/ali1363/SceCells.
- Please cite our manuscript at: https://doi.org/10.1371/journal.pcbi.1005533.g001

# Sample workflow
The following is a sample workflow:
- Run the Epi-Scale simulation, generating output in the animation and dataOutput folders of the scecells directory
- Run the downsampleVTK.sh script to delete vtk fils so that the vtk framerate is 1/5th of the dataout framerate
- Move the animation and dataOutput folders into /Data/unsorted
- Run sortData.sh to sort the unsorted data into directories. Note: the simulations must have unique identifiers.
- Run preprocessSimulations.sh to generate .mat files for each simulation
- Use one of the analysis scripts to load the .mat files and generate figures
