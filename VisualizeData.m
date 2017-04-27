% function VisualizeData()

%% Prepare workspace
settings = prepareWorkspace;
settings.thruData = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\PooledData\$_Raw.mat';
settings.thruT1 = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\PooledData\$_T1.mat';

labels = {'Exp1_GrowthAndMR/Growth_0.8_MR_1', ...
    'Exp1_GrowthAndMR/Growth_0.8_noMR_2', ...
    'Exp1_GrowthAndMR/Growth_1.6_MR_1', ...
    'Exp1_GrowthAndMR/Growth_1.6_noMR_1', ...
    'Exp1_GrowthAndMR/Growth_3.2_MR_1', ...
    'Exp1_GrowthAndMR/Growth_3.2_noMR_1'};    

%% Annotate videos
for i = 1:length(labels)
    disp(['Processing number ' num2str(i) ' of ' num2str(length(labels))]);
    flag(i) = annotateVideo(labels{i}, settings);
end
