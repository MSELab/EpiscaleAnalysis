% This script obtains assortativity of tissues under different conditions
% and generates figures comparing them. Aboav-Weaire Law states that cells
% with more sides tend to have neighbors with fewer sides. To this effect,
% average neighbor number is also analyzed for cells of a particular
% polygon class bin.

clear all

%% Parameter Declaration
relevantTimes = 5477;
relevantSimulations = 'N';
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
        
        for cellIndex = 1:length(cellArrayPolygonClass)
            currentNeighbors = find(adjacencyMatrix(:,cellIndex));
            tempNeighborNumbers = cellArrayPolygonClass(currentNeighbors);
            cellArrayNeighborDegree(cellIndex) = mean(tempNeighborNumbers);
        end
        
        %% Process Data
        areas = cellArrayArea(~cellArrayBoundary);
        polyClasses = cellArrayPolygonClass(~cellArrayBoundary);
        neighborDegree = cellArrayNeighborDegree(~cellArrayBoundary);
        NBins = unique(polyClasses);
        averageArea = mean(areas);
        for binIndex = 1:length(possibleBins)
            bin = possibleBins(binIndex);
            aveAreaPerPolyClass(binIndex, i) = mean(areas(polyClasses == bin)) / averageArea;
            aveNeighborDegree(binIndex, i) = mean(neighborDegree(polyClasses == bin));
            sampleSize(binIndex, i) = sum(polyClasses == bin);
        end
    end
end

% Remove data with insufficient sample size
aveAreaPerPolyClass(sampleSize < minimumCellNumber) = NaN;
aveNeighborDegree(sampleSize < minimumCellNumber) = NaN;
aveNeighborDegree(aveNeighborDegree == 0) = NaN;
averageAn = nanmean(aveAreaPerPolyClass, 2);
averageND = nanmean(aveNeighborDegree, 2);
stdAn = nanstd(aveAreaPerPolyClass, 1, 2);
stdND = nanstd(aveAreaPerPolyClass, 1, 2);
relevantBins = possibleBins(~isnan(averageAn));
relevantAverageAn = averageAn(~isnan(averageAn));
relevantStdAn = stdAn(~isnan(averageAn));
relevantAverageND = averageND(~isnan(averageND));
relevantStdND = stdND(~isnan(averageND));

%% Normalized area at each polygon class for each simulation
% close all
% for i = 1:6
%     plot(aveAreaPerPolyClass(:, i))
%     hold on
% end

%% Average neighbor number at each polygon class for each simulation
% close all
% for i = 1:6
%     plot(aveNeighborDegree(:, i))
%     hold on
% end

%% Normalized area at each polygon class with averages and standard deviation
close all
hFigure = figure('Units', 'pixels');
hold on;

An = [relevantAverageAn, relevantStdAn];
ND = [relevantAverageND, relevantStdND];

[hAxes, hArea, hNeighborDegree] = plotyy(relevantBins, An, relevantBins, ND, @plotErrorBar, @plotErrorBar);

set(hArea                       , ...
  'LineStyle'       , '-'       , ...
  'Color'           , [0 0 0]  	, ...
  'LineWidth'       , 4       	, ...
  'Marker'          , '.'    	, ...
  'MarkerSize'      , 36      	, ...
  'MarkerEdgeColor' , [0 0 0]   , ...
  'MarkerFaceColor' , [0 0 0]   ...
);

set(hNeighborDegree           	, ...
  'LineStyle'       , '--'      , ...
  'Color'           , [0 0 0]  	, ...
  'LineWidth'       , 4       	, ...
  'Marker'          , 'x'    	, ...
  'MarkerSize'      , 12      	, ...
  'MarkerEdgeColor' , [0 0 0]   , ...
  'MarkerFaceColor' , [0 0 0]   ...
);

hXLabel = xlabel('Polygon Class');
hYLabel1 = get(hAxes(1),'Ylabel');
hYLabel2 = get(hAxes(2),'Ylabel');

ylabel(hAxes(1), 'A_n');
ylabel(hAxes(2), 'Neighbor Polygon Class');

hAxes(1).XTick = relevantBins;
hAxes(2).XTick = relevantBins;
hAxes(1).YTick = 0.8:0.2:1.4;
hAxes(2).YTick = 5.5:0.2:6.5;
hAxes(1).XColor = [0 0 0];
hAxes(2).XColor = [0 0 0];
hAxes(1).YColor = [0 0 0];
hAxes(2).YColor = [0 0 0];

axis(hAxes(1),[min(relevantBins)-0.5 max(relevantBins)+0.5 0.8 1.4])
axis(hAxes(2),[min(relevantBins)-0.5 max(relevantBins)+0.5 5.5 6.5])

set([hAxes, hXLabel, hYLabel1, hYLabel2]   , ...
	'FontName'      , 'Arial'   , ...
    'FontSize'      , 40      	 ...
);

set([hXLabel, hYLabel1, hYLabel2]   , ...
	'FontName'      , 'Arial'   , ...
    'FontSize'      , 40      	 ,...
    'Color'           , [0 0 0]  	...
);

set(gca, ...
	'LineWidth'     , 4       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.025 .025]	, ...
    'TickDir'       , 'in'    	...
);
axes(hAxes(1));
axis square
axes(hAxes(2));
axis square
% hFigure.PaperUnits = 'inches';
% hFigure.PaperPosition = [-4 -4 60 60];
hFigure.PaperPosition = [-5 -5 15 15];
hFigure.PaperPositionMode = 'auto';
print([ settings.outFigureDir 'LewisLaw_AboavWeaireLawFigure.png'],'-dpng','-r75')
print([ settings.outFigureDir 'LewisLaw_AboavWeaireLawFigure.eps'],'-depsc2')