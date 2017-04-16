% This function is meant to be run on a cluster to convert the output of
% the Epi-Scale simulation into a matlab-interpretable format.

% Flags
% 1: Made datafile for label
% 2: Datafile already exists
% -1: Did not find raw data

function flag = convertSimulationOutput(coreNumber, settings, directory)
%% Initialization
if nargin < 1
    coreNumber = 1;
end
if nargin < 2
    settings = getSettings;
end
if nargin == 3
    settings.activeDir = directory;
end

settings = prepareWorkspace(settings);
labels = importData(settings);

%% Processes all files listed in the spreadsheet
flag = zeros(length(labels), 1);
if coreNumber == 1
    for k = randperm(length(labels))
        flag(k) = saveSimulation(labels{k}, settings);
    end
else
    parpool(coreNumber);
    parfor k = 1:length(labels)
        flag(k) = saveSimulation(labels{k}, settings);
    end
end
