settings = prepareWorkspace;
[labels, metadata] = importData(settings);

for i = 1:length(labels)
    disp(['Extracting number ' num2str(i) ' of ' num2str(length(labels))])
    data{i} = load(['Data' filesep labels{i} filesep 'T1Transitions.mat']);
    data2{i} = load(['Data' filesep labels{i} filesep 'dataFile.mat']);
end

save('AllData.mat','labels','data','data2')