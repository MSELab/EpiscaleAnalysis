% This script obtains the neighbor-number for every non-edge cell at set
% time-points in a simulation, and generates a figure panel comparing
% average neighbor number across different conditions

clear all

%% Parameter Declaration
relevantTimes = [2000];
relevantSimulations = {'Growth_0.5to2.5', 'Growth_1to3', 'Growth_1.5to3.5', 'Growth_2to4'};

%% Initialization
settings = prepareWorkspace();

%% Analysis
for k = 1:length(relevantSimulations)
    labels = getLabels(settings.inDetailsDir, relevantSimulations{k}, 2);
    simulationNumber = length(labels);
    for i = 1:simulationNumber
        for t = relevantTimes
            %% Extract Data
            currentFilename = [settings.inDetailsDir processDatafileName(labels{i}, t)];
            
            % If the file doesn't exist, then the simulation continues to the
            % next file in the list.
            if exist(currentFilename, 'file') ~= 2
                continue
            end
            
            cellData = parseDatafile(currentFilename);
            
            % Extract polygon class and edge-cell status for each cell
            % at the relevant time-point
            adjacencyMatrix = makeAdjacencyMatrix({cellData.NeighborCells});
            
            cellArrayPolygonClass = sum(adjacencyMatrix, 1);
            cellArrayBoundary = str2double({cellData.IsBoundrayCell});
            
            %% Process Data
            polyClasses = cellArrayPolygonClass(~cellArrayBoundary);
            averagePolyClass(k,i) = mean(polyClasses);
        end
    end
end

% Process the extracted data to make figures later
averagePolyClass(averagePolyClass == 0) = NaN;
averageN = nanmean(averagePolyClass, 2);
stdN = nanstd(averagePolyClass, 1, 2);

%% Normalized area at each polygon class for each simulation
close all
errorbar(1:length(averageN), averageN, stdN)
hold on

disp(['The average polygon class is: ' num2str(averageN(4)) ' +/- ' num2str(stdN(4))]);
