clear all
close all

%% Parameter Declaration
searchTerms = {'Growth_0.5to2.5_', 'Growth_1to3_', 'Growth_1.5to3.5_', 'Growth_2to4_'};
%simulationLabel = {'S_a_v_e=1.5', 'S_a_v_e=2.0', 'S_a_v_e=2.5', 'S_a_v_e=3.0'};
simulationLabel = {'g_0_,_ _a_v_e=1.5·10^-^3', 'g_0_,_ _a_v_e=2.0·10^-^3', 'g_0_,_ _a_v_e=2.5·10^-^3', 'g_0_,_ _a_v_e=3.0·10^-^3'};

outputTime = 2001;
largeFont = 12;
smallFont = 6;

%% Import Experimental Data
experimentalLabel = {'Hydra', 'Drosophila', 'Xenopus', 'Chick'};
polygons = 3:8;
meanFraction = [0.0000, 0.0000, 0.0014, 0.0043; ...
                0.0256, 0.0298, 0.0384, 0.0469; ...
                0.2642, 0.2784, 0.2898, 0.2372; ...
                0.4616, 0.4574, 0.4290, 0.4517; ...
                0.2074, 0.2003, 0.1818, 0.2003; ...
                0.0369, 0.0313, 0.0497, 0.0483]; ...
    
stdFraction =  [0.0000, 0.0000, 0.0000, 0.0000; ...
                0.0170, 0.0156, 0.0099, 0.0043; ...
                0.0185, 0.0185, 0.0170, 0.0099; ...
                0.0199, 0.0227, 0.0241, 0.0355; ...
                0.0128, 0.0256, 0.0128, 0.0156; ...
                0.0128, 0.0128, 0.0085, 0.0057];

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);
numSims = length(simulationLabel);
numExpt = length(experimentalLabel);

%% Data Extraction
for i = 1:numExpt
    simFraction = nan(length(polygons),length(labelIndices));
    for j = find(labelIndices == i)
        load([settings.matDir labels{j} '.mat'], 'polyClass');
        load([settings.matDir labels{j} '.mat'], 'edgeCell');
        if length(polyClass) < outputTime
            continue
        end
        disp(['Analyzing: ' labels{j}])
        currentPoly = polyClass{outputTime};
        currentEdge = edgeCell{outputTime};
        currentNonEdgePoly = currentPoly(~currentEdge);
        for k = polygons
            totalCells(k-min(polygons)+1) = sum(currentNonEdgePoly == k);
        end
        simFraction(:,j) = totalCells / sum(totalCells);
    end
    meanFraction(:, end + 1) = nanmean(simFraction, 2);
    stdFraction(:, end + 1) = nanstd(simFraction, 1, 2);
end

%% Data analysis and signifigance testing
[numPoly, numExptConditions] = size(meanFraction);
figureLabels = [experimentalLabel simulationLabel];
polyClassID = repmat(polygons, [numExptConditions, 1])';

%% Plot data roughly
close all

errorbar(polyClassID, meanFraction, stdFraction);

%% Plot data in bar graphs

shiftMag = 0
close all
% Make colormap. Expt is in parula, simulations are in greyscale.
customColormap = parula(numExpt);
tempGrays = gray(numSims+2);
customColormap((end+1):(end+numSims),:) = tempGrays(2:(end-1),:);

legendShift = [1 1 0 0] * shiftMag;

% Make bar graph
hFigure = figure();
h = bar(meanFraction);
for series = 1:(numExpt+numSims)
    set(h(series),'FaceColor',customColormap(series,:));
end
set(h,'BarWidth',1);    % The bars will now touch each other
set(gca,'YGrid','off')
set(gca,'GridLineStyle','-')
set(gca,'XTicklabel','')
hylabel = ylabel('Fraction');
% hxlabel = xlabel('Polygon Class');
lh = legend(figureLabels);
set(lh,'Location','northeastoutside','Orientation','vertical')
% set(lh,'Position',[0.7176 0.6568 0.1643 0.2371]+legendShift)

hold on;
numgroups = size(meanFraction, 1); 
numbars = size(meanFraction, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, meanFraction(:,i), stdFraction(:,i), 'k', 'linestyle', 'none');
end
axis([0.5,7.5,0,0.6])
set(gca, ...
	'LineWidth'     , 1       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.025 .025]	, ...
    'FontName'      , 'Times'   , ...
    'TickDir'       , 'in'   , 	...
'FontSize'      , largeFont      	 ...
);

set(h, ...
	'LineWidth'     , 0.5       	...
);

set(hylabel, ...
    'FontName'      , 'Times'   , ...
    'LineWidth'     , 1e-22       	, ...
'FontSize'      , largeFont      	 ...
);

set(lh   , ...
	'FontName'      , 'Times'   , ...
    'box'     , 'off'       	, ...
'FontSize'      , smallFont      	 ...
);

set(gca,'xtick',[])
set(gca,'xticklabel',[])

hFigure.PaperUnits = 'inches';
hFigure.PaperPosition = [0 0 4.6 2.1];
hFigure.PaperPositionMode = 'manual';

currentLegendPosition = get(lh,'Position');
set(lh,'Position',currentLegendPosition+legendShift)


print([ settings.outFigureDir 'PolygonClassFigureGrowth.png'],'-dpng','-r1200')
print([ settings.outFigureDir 'PolygonClassFigureGrowth.eps'],'-depsc2')

