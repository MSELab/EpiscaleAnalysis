function [labels, tableExpt] = importData(settings)

%% Import experimental data
tableExpt = readtable(settings.inLabels);
expt = tableExpt.Experiment;
label = tableExpt.Label;

for i = 1:size(tableExpt, 1)
    labels{i} = [expt{i} filesep label{i}];
end