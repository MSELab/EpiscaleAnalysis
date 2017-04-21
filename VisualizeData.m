% function VisualizeData()

%% Prepare workspace
settings = prepareWorkspace;
[labels, metadata] = importData(settings);
dirPng = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\Data\Exp1_GrowthAndMR\AllPng\';
data1 = load('SummaryT1.mat');
data2 = load('Summary.mat');


%% Load data


%% Rearrange data