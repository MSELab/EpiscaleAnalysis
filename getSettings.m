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
settings.annotateT1Time = 200;
settings.T1Color = 'red';
settings.lostColor =  'red';
settings.gainedColor =  'cyan';
settings.T1Opacity = 0.3;
settings.T1Radius = 24;

settings.thruAnimation = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\Data\$\pngFiles\';
settings.thruAnnotation = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\Data\$\pngAnnotated\';
settings.outAnimation = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\Data\$_annotated';
settings.thruData = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\PooledData\$_Raw.mat';
settings.thruT1 = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\PooledData\$_T1.mat';

settings.lostColor = [0,255, 255];
settings.gainedColor = [255,0,255];

settings.T1colors(:,1) = settings.lostColor;
settings.T1colors(:,2) = settings.lostColor;
settings.T1colors(:,3) = settings.gainedColor;
settings.T1colors(:,4) = settings.gainedColor;

settings.outputFrameRate = 5;

settings.force = 0;
end

