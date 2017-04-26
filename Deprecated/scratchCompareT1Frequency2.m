%% Prepare workspace
clearvars
settings = prepareWorkspace;
[labels, metadata] = importData(settings);

settings.firstDivision = 10;
settings.lastDivision = 300;
settings.cellRadius = 60;
settings.minCellsToCount = 1;

%% Load data
flag = zeros(1, length(labels));

for i = 1:length(labels)
    if (exist(['Data' filesep labels{i} filesep 'T1Transitions.mat'], 'file'))
        disp(['Processing: ' labels{i}])
        data = load(['Data' filesep labels{i} filesep 'T1Transitions.mat'], 'T1_time', 'T1_cells', 'flag','frame','T1_count');
        if data.flag < 1
            if data.flag == -1
                flag(i) = 0;
            else
                flag(i) = -4;
            end
            continue
        elseif ~isfield(data, 'T1_time') || ~isfield(data, 'T1_cells')
            disp('Processing failed flag -3')
            flag(i) = -3;
            continue
        end
        data2 = load(['Data' filesep labels{i} filesep 'dataFile.mat'], 'cellNumber', 'cellCenters', 'flag');
        if ~isfield(data2, 'cellNumber') || ~isfield(data2, 'cellCenters')
            flag(i) = -3;
            continue
        else
            disp('Processing Successful')
            measurements(i) = compareT1Transitions(data, data2, settings);
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

g_ave(isnan([measurements.R2])) = [];
MR(isnan([measurements.R2])) = [];
measurements(isnan([measurements.R2])) = [];

save('export.mat', 'g_ave', 'MR', 'measurements')