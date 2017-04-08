function settings = prepareWorkspace()
% Run this at the beginning of each Epi-Stim simulation post-processing
% script. This identifies the dependancy folders, and sets folders for
% inputs and output.

close all
fclose('all');
settings = getSettings();
cd(settings.activeDir);
warning('off','MATLAB:MKDIR:DirectoryExists');

% Add dependancy folders to path
addpath(settings.depExt, settings.depInt);

% Make output folders
mkdir(settings.outFigureDir);
mkdir(settings.matDir);
mkdir(settings.outAnalysisDir);
mkdir(settings.archiveCopyVTK);

warning('on','MATLAB:MKDIR:DirectoryExists');

% Updates all .mat files generated from detailedStatistics Epi-Scale
% output. This should only take time the first time it is run after new
% simulation files are added.
ConvertAllSimulationsIntoMATLAB(settings);

end