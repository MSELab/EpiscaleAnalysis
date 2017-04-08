clear all

%% Parameter Declaration
relevantSimulations = {'Growth_2to4'};

%% Initialization
settings = prepareWorkspace();

%% Analysis
for k = 1:length(relevantSimulations)
    [labels, labelIndices] = getLabels(settings, relevantSimulations{k}, 3);
    simulationNumber = length(labels);
    for i = 1:simulationNumber
        %% Extract Data      
        load([settings.matDir labels{i} '.mat'], 'rawDetails');
        
        [cellx, celly, T1x, T1y, divx, divy] = IdentifyT1Transitions2D(rawDetails);
        
        
        %% Process Data
        polyClasses = cellArrayPolygonClass(~cellArrayBoundary);
        averagePolyClass(k,i) = mean(polyClasses);
        
    end
end