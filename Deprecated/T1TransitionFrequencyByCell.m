% clear all
close all

%% Declaration
% growthRates = [0.22, 0.33, 0.44, 0.55, 0.66] * 1.5;
growthRates = [0, 1];
binSize = 100;
T1Settings.analysisTime = 1000;
T1Settings.minimumTime = 100;
T1Settings.minCellNumber = 60;
T1Settings.cellsToAnalyze = 60;
% searchTerms = {'Growth_0.22' , ...
%                'Growth_0.33' , ...
%                'Growth_0.44' , ...
%                'Growth_0.55' , ...
%                'Growth_0.66' , ...
%                };
           
searchTerms = {'NoRounding' , ...
               'Control_0.55' , ...
               };
          
smallFont = 24;
bigFont = 28;

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);
T1perHour = NaN(length(unique(labelIndices)), length(labelIndices));
R2 = NaN(length(unique(labelIndices)), length(labelIndices));
startTimes = NaN(length(unique(labelIndices)), length(labelIndices));
endTimes = NaN(length(unique(labelIndices)), length(labelIndices));

%% Data Extraction
for i = unique(labelIndices)
    % Iterate over the replicates within one experiment
    runIndices = find(labelIndices == i);
    for j = find(labelIndices == i)
        disp(['Analyzing: ' labels{j}])
        load([settings.matDir labels{j} '.mat'], 'T1Position');
        load([settings.matDir labels{j} '.mat'], 'position');
        load([settings.matDir labels{j} '.mat'], 'edgeCell');
        
        [T1perHour(i, j), R2(i, j), startTimes(i, j), endTimes(i, j)] = T1FrequencyRoI(T1Position, position, edgeCell, T1Settings);
        if ~isnan(T1perHour(i, j))
            disp(['T1 transitions per hour: ' num2str(T1perHour(i, j))]);
        end
    end
    close all
end

%% Remove failed simulations
R2(isnan(T1perHour)) = NaN;
startTimes(isnan(T1perHour)) = NaN;
endTimes(isnan(T1perHour)) = NaN;

%% Signifigance Testing
[p,tbl,stats] = anova1(T1perHour');
disp('ANOVA Statistical Results');
disp(['p value:      ' num2str(p)]);
disp(['sample size:  ' num2str(stats.n)]);
save([settings.outAnalysisDir 'T1GrowthSignifigance'],'p','stats','T1perHour');

%% T1s per hour
close all
figure(1)
UnivarScatter(T1perHour','Label', cellfun(@num2str,num2cell(growthRates),'uniformoutput',0), 'SEMColor', [1 1 1], 'MarkerFaceColor', 'k');
                                   
hXLabel = xlabel('Growth Rate (g_0_,_ _a_v_e, x 10^-^3)');
hYLabel = ylabel('T1 Transition Frequency hr^-^1');

set(gca,'FontSize',smallFont)

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'Times'   , ...
    'FontSize'      , bigFont      	 ,...
    'Color'           , [0 0 0]  	...
);

set(gca, ...
	'FontName'      , 'Times'   , ...
    'LineWidth'     , 2       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.025 .025]	, ...
    ...%'YTick'         , 1:3       , ...
    'TickDir'       , 'in'    	...
);

maxAxis = uint16(nanmax(T1perHour(:))+0.5);
axis([-inf inf  -inf inf])

axis normal
print([ settings.outFigureDir 'T1Growth.eps'],'-depsc2')
print([ settings.outFigureDir 'T1Growth.png'],'-dpng','-r300')

%% R^2 values for all of the data (should be around 0.98 unless simulations are broken)
figure(2)
UnivarScatter(R2','Label',      {'0.45'	... 
                                        '0.60'   ...
                                        '0.75'	... 
                                        '0.90'   ...
                                        '1.05'   ...
                                       }, 'SEMColor', [1 1 1], 'MarkerFaceColor', 'k');
                                   
hXLabel = xlabel('Average Growth Rate (S, x 10^-^3)');
hYLabel = ylabel('R^2');

set(gca,'FontSize',smallFont)

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'Times'   , ...
    'FontSize'      , bigFont      	 ,...
    'Color'           , [0 0 0]  	...
);

set(gca, ...
	'FontName'      , 'Times'   , ...
    'LineWidth'     , 2       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.025 .025]	, ...
    'TickDir'       , 'in'    	...
);

maxAxis = round(nanmax(R2(:)),1)+0.1;
minAxis = round(nanmin(R2(:)),1)-0.1;
axis([0.25 5.75  -inf inf])

axis normal
print([ settings.outFigureDir 'T1GrowthR2.eps'],'-depsc2')
print([ settings.outFigureDir 'T1GrowthR2.png'],'-dpng','-r300')

%% Simulation start times
figure(3)
UnivarScatter(startTimes','Label',      {'0.45'	... 
                                        '0.60'   ...
                                        '0.75'	... 
                                        '0.90'   ...
                                        '1.05'   ...
                                       }, 'SEMColor', [1 1 1], 'MarkerFaceColor', 'k');
                                   
hXLabel = xlabel('Average Growth Rate (S, x 10^-^3)');
hYLabel = ylabel('Start Time (AU)');

set(gca,'FontSize',smallFont)

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'Times'   , ...
    'FontSize'      , bigFont      	 ,...
    'Color'           , [0 0 0]  	...
);

set(gca, ...
	'FontName'      , 'Times'   , ...
    'LineWidth'     , 2       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.025 .025]	, ...
    'TickDir'       , 'in'    	...
);

maxAxis = uint16(nanmax(startTimes(:))+0.5);
axis([0.25 5.75 0 maxAxis])

axis normal
print([ settings.outFigureDir 'T1GrowthStartTime.eps'],'-depsc2')
print([ settings.outFigureDir 'T1GrowthStartTime.png'],'-dpng','-r300')

%% Simulation total analyzed time
figure(4)
totalTimes = (endTimes - startTimes);
UnivarScatter(totalTimes','Label',      {'0.45'	... 
                                        '0.60'   ...
                                        '0.75'	... 
                                        '0.90'   ...
                                        '1.05'   ...
                                       }, 'SEMColor', [1 1 1], 'MarkerFaceColor', 'k');
                                   
hXLabel = xlabel('Average Growth Rate (S, x 10^-^3)');
hYLabel = ylabel('Total Time (AU)');

set(gca,'FontSize',smallFont)

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'Times'   , ...
    'FontSize'      , bigFont      	 ,...
    'Color'           , [0 0 0]  	...
);

set(gca, ...
	'FontName'      , 'Times'   , ...
    'LineWidth'     , 2       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.025 .025]	, ...
    'TickDir'       , 'in'    	...
);

maxAxis = uint16(nanmax(totalTimes(:)) + 0.5);
axis([0.25 5.75 0 maxAxis])

axis normal
print([ settings.outFigureDir 'T1GrowthTotalTime.eps'],'-depsc2')
print([ settings.outFigureDir 'T1GrowthTotalTime.png'],'-dpng','-r300')

%% Frequency of T1 transitions at different growthrates - mean and std
figure(5)
meanT1perHour = nanmean(T1perHour,2);
stdT1perHour = nanstd(T1perHour,1,2);

hErrorbar = errorbar(growthRates, meanT1perHour, stdT1perHour);
                                   
hXLabel = xlabel('Average Growth Rate (a_a_v_e x 10^-^3)');
hYLabel = ylabel('T1 Transition Frequency hr^-^1');

set(gca,'FontSize',smallFont)

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'Times'   , ...
    'FontSize'      , bigFont      	 ,...
    'Color'           , [0 0 0]  	...
);

set(gca, ...
	'FontName'      , 'Times'   , ...
    'LineWidth'     , 2       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.025 .025]	, ...
    'XTick'         , 0.45:0.15:1.05, ...
    'YTick'         , 1:0.5:3, ...
    'TickDir'       , 'in'    	...
);

set(hErrorbar, ...
'LineStyle'       , '-'       , ...
  'Color'           , [0 0 0]  	, ...
  'LineWidth'       , 2       	, ...
  'Marker'          , '.'    	, ...
  'MarkerSize'      , 24      	, ...
  'MarkerEdgeColor' , [0 0 0]   , ...
  'MarkerFaceColor' , [0 0 0]   ...
);

maxAxis = uint16(nanmax(T1perHour(:))+0.5);
axis([0.4 1.1 -inf inf])

axis normal
print([ settings.outFigureDir 'T1GrowthAve.eps'],'-depsc2')
print([ settings.outFigureDir 'T1GrowthAve.png'],'-dpng','-r300')

%% Mean Cummulitive T1 Transition Number
figure(6)
cumT1Mat(cumT1Mat==0) = NaN;
meanT1 = squeeze(nanmean(cumT1Mat(:,:,1:2000),2));
stdT1 = squeeze(nanstd(cumT1Mat(:,:,1:2000),0,2));
color = {'m','c','g','b','k','y','r'};
for i = 1:4
     shadedErrorBar(1:length(meanT1(i,:)), meanT1(i,:), stdT1(i,:), color{i});
     hold on
end

%% Mean Cummulitive T1/100 div Transition Number
figure(7)
T1per100Divisions(T1per100Divisions == 0) = NaN;
meanT1 = squeeze(nanmean(T1per100Divisions(:,:,1:2000),2));
stdT1 = squeeze(nanstd(T1per100Divisions(:,:,1:2000),0,2));
color = {'m','c','g','b','k','y','r'};
for i = 1:length(categories)
     shadedErrorBar(1:length(meanT1(i,:)), meanT1(i,:), stdT1(i,:), color{i});
     hold on
end

%% Mean T1 frequency (binned)
figure(8) 
T1sOverTimePeriod(T1sOverTimePeriod == 0) = NaN;
binValueinHours = binValue * simulationTimescale;
T1perHour = T1sOverTimePeriod(:,:,binValue<=2000) / binSize / simulationTimescale;
meanT1 = squeeze(nanmean(T1perHour,2));
stdT1 = squeeze(nanstd(T1perHour,0,2));
color = {'m','c','g','b','k','y','r'};
for i = 1:length(categories)
     shadedErrorBar(binValueinHours(1:length(meanT1)), meanT1(i,:), stdT1(i,:), color{i});
     hold on
end