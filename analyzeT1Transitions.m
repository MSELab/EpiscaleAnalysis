% This function is meant to be run on a cluster to convert the output of
% the Epi-Scale simulation into a matlab-interpretable format.

% Flags
% 1: Made datafile for label
% 2: Datafile already exists
% -1: Did not find raw data

function flag = analyzeT1Transitions(coreNumber, settings)
%% Initialization
if nargin < 1
    coreNumber = 1;
end
if nargin < 2
    settings = prepareWorkspace;
else
    prepareWorkspace
end

labels = importData(settings);

%% Processes all files listed in the spreadsheet
flag_convert = zeros(length(labels), 1);
flag_analyze = zeros(length(labels), 1);

if coreNumber == 1
    for k = 1:length(labels) %randperm(length(labels))
        flag_convert(k) = saveSimulation(labels{k}, settings);
        flag_analyze(k) = extractT1Transitions(labels{k}, settings);
    end
else
    parpool(coreNumber);
    parfor k = 1:length(labels)
        flag_convert(k) = saveSimulation(labels{k}, settings);
        flag_analyze(k) = extractT1Transitions(labels{k}, settings);
    end
end

flag = [flag_convert, flag_analyze];
