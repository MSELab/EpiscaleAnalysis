# Summary
A list of simulations is stored in DataIndex.xlsx. That list corresponds to the organization of directories in the /Data folder. The script file preprocessSimulations will run the matlab file analyzeT1Transitions. This results in generating a .mat file in each simulation folder with easily-accessible data for each simulation, and a .mat file with a T1 transition analysis.

# Sample workflow
The following is a sample workflow
-Run the Epi-Scale simulation, generating output in the animation and dataOutput folders of the sce cells directory
-Run the downsampleVTK.sh script to delete vtk fils so that the vtk framerate is 1/5th of the dataout framerate
-Move the animation and dataOutput folders into /Data/unsorted
-Run the script sortData.sh to sort the unsorted data into directories. Note: the simulations must have unique identifiers.
-Run preprocessSimulations.sh to generate .mat files for each simulation
-Use one of the analysis scripts to load the .mat files and generate figures