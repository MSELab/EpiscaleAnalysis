% This script obtains the area and the neighbor-number for every non-edge
% cell at set time-points in a simulation, and generates a figure panel
% plotting Average area vs neighbor number to test Lewis's law.

clear all

%% Parameter Declaration
relevantTimes = 4500;
relevantSimulations = 'Growth_2to4';
minimumCellNumber = 4; % Minimum number of cells in a bin for analysis
possibleBins = 1:12; % Bins to consider in analysis

%% Initialization
settings = prepareWorkspace();
labels = getLabels(settings, relevantSimulations, 2);
simulationNumber = length(labels);
aveAreaPerPolyClass = nan(length(possibleBins), simulationNumber); % An is the average area for a particular polygon class n x i
sampleSize = nan(length(possibleBins), simulationNumber);

%% Analysis
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
        
        % Extract area, polygon class, and edge-cell status for each cell
        % at the relevant time-point
        adjacencyMatrix = makeAdjacencyMatrix({cellData.NeighborCells});
        
        cellArrayArea = str2double({cellData.CellArea});
        cellArrayPolygonClass = sum(adjacencyMatrix, 1);
        cellArrayBoundary = str2double({cellData.IsBoundrayCell});
        
        %% Process Data
        areas = cellArrayArea(~cellArrayBoundary);
        polyClasses = cellArrayPolygonClass(~cellArrayBoundary);
        NBins = unique(polyClasses);
        averageArea = mean(areas);
        for binIndex = 1:length(possibleBins)
            bin = possibleBins(binIndex);
            aveAreaPerPolyClass(binIndex, i) = mean(areas(polyClasses == bin)) / averageArea;
            sampleSize(binIndex, i) = sum(polyClasses == bin);
        end
    end
end

% Remove data with insufficient sample size
aveAreaPerPolyClass(sampleSize < minimumCellNumber) = NaN;
averageAn = nanmean(aveAreaPerPolyClass, 2);
stdAn = nanstd(aveAreaPerPolyClass, 1, 2);
relevantBins = possibleBins(~isnan(averageAn));
relevantAverageAn = averageAn(~isnan(averageAn));
relevantStdAn = stdAn(~isnan(averageAn));


%% Normalized area at each polygon class for each simulation
close all
for i = 1:6
    plot(aveAreaPerPolyClass(:, i))
    hold on
end

%% Normalized area at each polygon class with averages and standard deviation
close all
hFigure = figure('Units', 'pixels', 'Position', [100 100 900 900]);
hold on;

hPlot = errorbar(relevantBins, relevantAverageAn, relevantStdAn);
set(hPlot                       , ...
  'LineStyle'       , '-'       , ...
  'Color'           , [0 0 0]  	, ...
  'LineWidth'       , 2       	, ...
  'Marker'          , '.'    	, ...
  'MarkerSize'      , 24      	, ...
  'MarkerEdgeColor' , [0 0 0]   , ...
  'MarkerFaceColor' , [0 0 0]   ...
);

hXLabel = xlabel('Polygon Class');
hYLabel = ylabel('A_n');

hAxes = gca;
axis([min(relevantBins)-0.5 max(relevantBins)+0.5 0.8 1.4]);
hAxes.XTick = relevantBins;

set([hAxes, hXLabel, hYLabel]   , ...
	'FontName'      , 'Arial'   , ...
    'FontSize'      , 24      	...
);

set(gca, ...
	'LineWidth'     , 2       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.02 .02]	, ...
    'TickDir'       , 'in'    	...
);

set(gcf, 'PaperPositionMode', 'auto');
print([ settings.outFigureDir 'LewisLawFigure.png'],'-dpng','-r300')
print([ settings.outFigureDir 'LewisLawFigure.eps'],'-depsc2')
close;