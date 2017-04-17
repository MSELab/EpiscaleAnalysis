%% Prepare workspace
clearvars
settings = prepareWorkspace;
[labels, metadata] = importData(settings);

settings.firstDivision = 10;
settings.lastDivision = 300;
settings.cellRadius = 60;
settings.minCellsToCount = 1;

%% Load data
for i = 1:length(labels)
    if (exist(['Data' filesep labels{i} filesep 'T1Transitions.mat'], 'file'))
        data = load(['Data' filesep labels{i} filesep 'T1Transitions.mat']);
        data2 = load(['Data' filesep labels{i} filesep 'dataFile.mat']);
        measurements(i) = compareT1Transitions(data, data2, settings);
        if ~isfield(data, 'frame') || ~isfield(data, 'T1_count')
            flag(i) = -3;
        elseif length(data.frame) <= 10
            flag(i) = -2;
        else
            disp(['Processing: ' labels{i}])
            flag(i) = 1;
            frame{i} = data.frame;
            T1_count{i} = data.T1_count;
        end
    else
        flag(i) = -1;
    end
end

%% Rearrange data
g_ave = metadata.g_ave;
MR = metadata.MR;

g_ave = g_ave(flag > 0);
MR = MR(flag > 0);
measurements = measurements(flag > 0);