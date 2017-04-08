function settings = getSettings()
% Get root directories
% activeDir = '/afs/crc.nd.edu/group/Zartman/Pavel/Project3Episcale/GrowthStudy/';
% activeDir = strrep(activeDir, '/', filesep);
[activeDir, ~, ~] = fileparts(mfilename('fullpath'));
settings.activeDir = [activeDir filesep];
settings.inLabels = [settings.activeDir 'DataIndex.xlsx'];
settings.simulation = [settings.activeDir 'Data' filesep '$' filesep];

% Get directory structure
settings.dirStats = [settings.simulation 'DataOutput' filesep];
settings.dirVtk = [settings.simulation 'Paraview' filesep];
settings.thruData = [settings.simulation 'dataFile.mat'];
settings.thruT1 = [settings.simulation 'T1Transitions.mat'];

% Get dependency directories
settings.depExt = [settings.activeDir 'Dependencies' filesep];
settings.depInt = [settings.activeDir 'Modules' filesep];

% T1 transition settings
settings.mpCutoff = [0.01, 0.99];
settings.framesSearched = 10;
settings.minSimTime = 1000;

% Animation settings
settings.refBB = [11.35, 40.25, 10.42, 40.634]; % x1, x2, y1, y2
settings.radiusCC = 8;
settings.opacityCC = 0.8;
settings.annotationName = '$_annotated_xxxxx';
end

