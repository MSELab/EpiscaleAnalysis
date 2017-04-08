clear all
close all

%% Parameter Declaration
searchTerms = {'N0','N0'};
binSize = 50;
scalingFactor = 1;
outputTimes = [1250, 2500, 3750, 5000];
smallFont = 11;

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);

%% Data Extraction
for j = length(labels):-1:1
    disp(['Analyzing: ' labels{j}])
    load([settings.matDir labels{j} '.mat'], 'cellArea');
    load([settings.matDir labels{j} '.mat'], 'position', 'edgeCell');
    
    for t = 1:length(outputTimes)
        if outputTimes(t) > length(cellArea)
            continue
        end
       
        tmpPos = position{outputTimes(t)};
        tmpArea = cellArea{outputTimes(t)};
        tmpEdge = logical(edgeCell{outputTimes(t)});
        
        tmpPos(tmpEdge) = [];
        tmpArea(tmpEdge) = [];
        
        rMax = max(tmpPos);
        normPos = tmpPos / rMax;
        areaTemp = tmpArea;
        k = 1;
        for rBin = [0,0.2;0.2,0.3;0.3,0.4;0.4,0.5;0.5,0.6;0.6,0.7;0.7,0.8;0.8,0.9;0.9,1]'
            rposition(k) = mean(rBin);
            Area(j,k,t) = mean(areaTemp(normPos>=rBin(1)&normPos<rBin(2)));
            k = k + 1;
        end
    end
end

%% Analysis
Area (Area == 0) = NaN;
stdArea = squeeze(nanstd(Area,1));
meanArea = squeeze(nanmean(Area,1));

%% Make Figure
current = figure;
subplot(1,length(outputTimes),1)
for i = 1:length(outputTimes)
    subplot(1,length(outputTimes),i)
    hCurrent = errorbar(rposition, meanArea(:,i), stdArea(:,i));
    axis([0, 1, 3, 8]);
    xlabel('Relative distance','FontSize', smallFont, 'FontName','Times');
    if i == 1
        ylabel('Mean Cell Area (\mum^2)', 'FontSize', smallFont, 'FontName','Times');
    end
    
    set(hCurrent                       , ...
        'LineStyle'       , '-'       , ...
        'Color'           , [0 0 0]  	, ...
        'LineWidth'       , 1       	, ...
        'Marker'          , '.'    	, ...
        'MarkerSize'      , 4      	, ...
        'MarkerEdgeColor' , [0 0 0]   , ...
        'MarkerFaceColor' , [0 0 0]   ...
);

set(gca, ...
	'LineWidth'     , 1       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.025 .025]	, ...
    'TickDir'       , 'in'   , 'FontSize', smallFont, 'FontName','Times'	...
);

end

% set(current, 'PaperUnits','inches','PaperPosition', [0, 0, 6.5, 1.8]);
set(current, 'PaperUnits','inches','PaperPosition', [0, 0, 3.5, 1.8]);
print([settings.outFigureDir 'Figure7.png'],'-dpng','-r600');
print([settings.outFigureDir 'Figure7.eps'],'-depsc2')