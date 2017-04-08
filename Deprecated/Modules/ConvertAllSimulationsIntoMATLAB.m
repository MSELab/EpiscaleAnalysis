% This function reads a logfile describing which datafiles have been
% converted into .mat data, and then converts the unconverted datafiles
% into .mat data. Each simulation is saved as a .mat file, and the logfile
% is updated.

% A structure describing all simulations named simulationLog is generated:
% Structure (1xM): simulationLog
% Properties:
% Name:         Naming convention of simulation [string]
% Length:       Number of timepoints processed  [uint16]
% TimeTaken:    Time taken to process data      [double]
% Error
% 
% Where M represents the number of simulations
% 
% A '.mat' file for each simulation containing the following variables is
% generated:
% rawDetails        Structure containing read datafile  [structure]
% position          Radian position of cells            {[1xt double]}
% T1Position        Radian position of T1 transitions   {[1xt double]}
% Where M represents the number of simulations

function ConvertAllSimulationsIntoMATLAB(settings)
%% Load in list of all simulations, and list of processed simulations
labels = getLabels(settings, {}, 2);

if exist(settings.matLog, 'file')
    load(settings.matLog, 'simulationLog');
    analyzedNames = {simulationLog.Name};
else
    simulationLog = [];
    analyzedNames = {'asdasd'};
end

%% Determine which simulations need to be processed
% Add unproccessessed simulations to queue
queueNames = {};
for currentLabel = labels'
    previouslyAnalyzed = false;
    for pastLabel = analyzedNames
        if strcmp(currentLabel{1}, pastLabel{1})
            previouslyAnalyzed = true;
            break
        end
    end
    if ~previouslyAnalyzed
        queueNames{end + 1} = currentLabel{1};
    end
end
newSimulations = length(queueNames);
queueTimes(1:newSimulations) = 0;
simulationIndex(1:newSimulations) = length(simulationLog) + (1:newSimulations);

% Find processed simulations with new timepoints and add to queue
for i = length(simulationLog):-1:1
    % Check for new simulation datafiles
    namingConvention = simulationLog(i).Name;
    lastTimepoint = simulationLog(i).Length - 1;
    possibleFileName = processDatafileName(namingConvention, lastTimepoint + 1);
    if exist([settings.inDetailsDir possibleFileName], 'file')
        queueNames{end + 1} = namingConvention;
        queueTimes(end + 1) = lastTimepoint + 1;
        simulationIndex(end + 1) = i;
    end
end

%% Process and save simulations
for m = 1:length(queueNames)
    tic
    disp(['Loading data simulation ' num2str(m) ' of ' num2str(length(queueNames))]);
    rawDetails = convertSimulationintoMatArray([settings.inDetailsDir queueNames{m}], 0);
   
    disp(['Parsing data arrays ' num2str(m) ' of ' num2str(length(queueNames))]);
    clear edgeCell polyClass cellArea growthProgress
    for i = length(rawDetails):-1:1
        edgeCell{i} = str2double({rawDetails{i}.IsBoundrayCell});
        polyClass{i} = str2double({rawDetails{i}.NumOfNeighbors});
        cellArea{i} = str2double({rawDetails{i}.CellArea});
        growthProgress{i} = str2double({rawDetails{i}.GrowthProgress});
        memNodes{i} = str2double({rawDetails{i}.CurrentActiveMembrNodes});
        intNodes{i} = str2double({rawDetails{i}.CurrentActiveIntnlNode});
   	end
        
    disp(['Counting T1 transitions ' num2str(m) ' of ' num2str(length(queueNames))]);
    [position, T1Position] = IdentifyT1Transitions(rawDetails);
    if isempty(position)
        simulationLog(simulationIndex(m)).Error = 'decreasing cell number';
    end
        
    save([settings.matDir queueNames{m} '.mat'], 'intNodes', 'memNodes', 'rawDetails', 'position', 'T1Position', 'edgeCell', 'polyClass', 'cellArea', 'growthProgress', '-v7.3');
    
    simulationLog(simulationIndex(m)).Name = queueNames{m};
    simulationLog(simulationIndex(m)).Length = length(rawDetails);
    simulationLog(simulationIndex(m)).TimeTaken = toc;
    simulationLog(simulationIndex(m)).EndCellNumber = length(rawDetails{end});
    
    save(settings.matLog, 'simulationLog');
end