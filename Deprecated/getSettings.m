function settings = getSettings()
% Get root directories
[activeDir, ~, ~] = fileparts(mfilename('fullpath'));
settings.activeDir = [activeDir filesep];
settings.inRootDir = 'D:\Project 2 Episcale\SimulationRawOutput\';
settings.outRootDir = [settings.activeDir 'Output' filesep];
settings.archiveRootDir = [settings.activeDir 'Archive' filesep];

% Get input directories
settings.inDetailsDir = [settings.inRootDir 'DetailedStats' filesep];
settings.inPolyDir = [settings.inRootDir 'PolygonTextFiles' filesep];
settings.inAnimationDir = [settings.inRootDir 'AnimationVTKs' filesep];
settings.inOutputLogDir = [settings.inRootDir 'OutputLogs' filesep];

% Get output directories
settings.outFigureDir = [settings.outRootDir 'Figures' filesep];
settings.matDir = [settings.outRootDir 'MatFiles' filesep];
settings.outAnalysisDir = [settings.outRootDir 'Analysis' filesep];
settings.archiveCopyVTK = [settings.outRootDir 'CopyVTK' filesep];

% Get dependency directories
settings.depExt = [settings.activeDir 'ExternalDependencies' filesep];
settings.depInt = [settings.activeDir 'HelperFunctions' filesep];

% Get filename of details logfile
settings.matLog = [settings.matDir 'analyzedSimulations.mat'];

end

