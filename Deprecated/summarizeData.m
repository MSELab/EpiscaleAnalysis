function summarizeData(settings)

%% Prepare workspace
settings = prepareWorkspace;
[labels, metadata] = importData(settings);

%% Load data
flag = zeros(1, length(labels));

for i = 1:length(labels)
    if (exist(['Data' filesep labels{i} filesep 'T1Transitions.mat'], 'file'))
        disp(['Processing: ' labels{i}])
%         T1Data{i} = load(['Data' filesep labels{i} filesep 'T1Transitions.mat']);
        Data{i} = load(['Data' filesep labels{i} filesep 'dataFile.mat'],'cellNumber');
    end
end

%% Rearrange data
save('Summary.mat','labels','metadata','Data')