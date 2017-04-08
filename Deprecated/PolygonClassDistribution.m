clear all
close all

%% Parameter Declaration
searchTerms = {'N0'};
simulationLabel = {'Episcale'};
outputTime = 5300;
largeFont = 12;
smallFont = 8;

%% Import Experimental Data
experimentalLabel = {'Hydra', 'Drosophila', 'Xenopus', 'Chick', 'Farhadifar et. al. 2007'};
polygons = 3:8;
meanFraction = [0.0000, 0.0000, 0.0014, 0.0043, 0.0023; ...
                0.0256, 0.0298, 0.0384, 0.0469, 0.1136; ...
                0.2642, 0.2784, 0.2898, 0.2372, 0.3220; ...
                0.4616, 0.4574, 0.4290, 0.4517, 0.2845; ...
                0.2074, 0.2003, 0.1818, 0.2003, 0.1674; ...
                0.0369, 0.0313, 0.0497, 0.0483, 0.1140]; ...
    
stdFraction =  [0.0000, 0.0000, 0.0000, 0.0000, 0; ...
                0.0170, 0.0156, 0.0099, 0.0043, 0; ...
                0.0185, 0.0185, 0.0170, 0.0099, 0; ...
                0.0199, 0.0227, 0.0241, 0.0355, 0; ...
                0.0128, 0.0256, 0.0128, 0.0156, 0; ...
                0.0128, 0.0128, 0.0085, 0.0057, 0];

%% Manually Input Adh = 2.5
% sim1 = [0 1 653 1283 472 39]';
% sim2 = [0 2 672 1382 486 34]';
% sim3 = [0 0 725 1588 547 37]';
% sim1 = sim1 / sum(sim1);
% sim2 = sim2 / sum(sim2);
% sim3 = sim3 / sum(sim3);
% meanAdh25 = mean([sim1, sim2, sim3],2);
% stdAdh25 = std([sim1, sim2, sim3], 1, 2);

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);

%% Data Extraction
for i = 1
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
    meanFraction(:, end + 1) = mean(simFraction, 2);
    stdFraction(:, end + 1) = std(simFraction, 1, 2);
end

%% Manually insert Adh data
% meanFraction(:, end + 1) = meanAdh25;
% stdFraction(:, end + 1) = stdAdh25;

%% Data analysis and signifigance testing
[numPoly, numExptConditions] = size(meanFraction);
figureLabels = [experimentalLabel simulationLabel];
polyClassID = repmat(polygons, [numExptConditions, 1])';

%% Plot data roughly
close all

errorbar(polyClassID, meanFraction, stdFraction);

%% Plot data in bar graphs
close all

hFigure = figure();
h = bar(meanFraction);
set(h,'BarWidth',1);    % The bars will now touch each other
set(gca,'YGrid','off')
set(gca,'GridLineStyle','-')
set(gca,'XTicklabel','')
hylabel = ylabel('Fraction');
% hxlabel = xlabel('Polygon Class');
lh = legend(figureLabels);
set(lh,'Location','bestoutside','Orientation','vertical')
hold on;
numgroups = size(meanFraction, 1); 
numbars = size(meanFraction, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, meanFraction(:,i), stdFraction(:,i), 'k', 'linestyle', 'none');
end

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
%hFigure.PaperPosition = [0 0 3.45 2.1];
hFigure.PaperPosition = [0 0 5.45 2.1];
hFigure.PaperPositionMode = 'manual';

colormap([parula(4); 0.3,0.3,0.3; 0.6,0.6,0.6])

print([ settings.outFigureDir 'PolygonClassFigure.png'],'-dpng','-r300')
print([ settings.outFigureDir 'PolygonClassFigure.eps'],'-depsc2')




