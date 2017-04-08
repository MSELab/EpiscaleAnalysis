clear all
close all

%% Declaration
growthRates = [0.3, 0.4, 0.5, 0.6, 0.7] * 1.5;
binSize = 100;
regionOfInterest = 5;
startTime = 1400;
endTime = 2000;
searchTerms = {'GrowthConstant_0.3to' , ...
                'GrowthConstant_0.4to' , ...
                'GrowthConstant_0.5to' , ...
                'GrowthConstant_0.6to' , ...
                'GrowthConstant_0.7to' ...
               };
           
smallFont = 24;
bigFont = 28;

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings.matDir, searchTerms, 3);
T1perHour = NaN(length(unique(labelIndices)), length(labelIndices));

%% Data Extraction
for i = unique(labelIndices)
    % Iterate over the replicates within one experiment
    jCount = 1;
    for j = find(labelIndices == i)
        load([settings.matDir labels{j}], 'T1Position');
        load([settings.matDir labels{j}], 'position');
        
        [T1perHour(i, jCount) R2(i, jCount)] = T1FrequencyRoI( T1Position, position );
        
        jCount = jCount + 1;
    end
    close all
end

%% Signifigance Testing
[p,tbl,stats] = anova1(T1perHour');
disp('ANOVA Statistical Results');
disp(['p value:      ' num2str(p)]);
disp(['sample size:  ' num2str(stats.n)]);

%% Mean Cummulitive T1 Transition Number
% close all
% cumT1Mat(cumT1Mat==0) = NaN;
% meanT1 = squeeze(nanmean(cumT1Mat(:,:,1:2000),2));
% stdT1 = squeeze(nanstd(cumT1Mat(:,:,1:2000),0,2));
% color = {'m','c','g','b','k','y','r'};
% for i = 1:4
%      shadedErrorBar(1:length(meanT1(i,:)), meanT1(i,:), stdT1(i,:), color{i});
%      hold on
% end

% %% Mean Cummulitive T1/100 div Transition Number
% close all
% T1per100Divisions(T1per100Divisions == 0) = NaN;
% meanT1 = squeeze(nanmean(T1per100Divisions(:,:,1:2000),2));
% stdT1 = squeeze(nanstd(T1per100Divisions(:,:,1:2000),0,2));
% color = {'m','c','g','b','k','y','r'};
% for i = 1:length(categories)
%      shadedErrorBar(1:length(meanT1(i,:)), meanT1(i,:), stdT1(i,:), color{i});
%      hold on
% end

% %% Mean T1 frequency (binned)
% close all
% for 
% T1sOverTimePeriod(T1sOverTimePeriod == 0) = NaN;
% binValueinHours = binValue * simulationTimescale;
% T1perHour = T1sOverTimePeriod(:,:,binValue<=2000) / binSize / simulationTimescale;
% meanT1 = squeeze(nanmean(T1perHour,2));
% stdT1 = squeeze(nanstd(T1perHour,0,2));
% color = {'m','c','g','b','k','y','r'};
% for i = 1:length(categories)
%      shadedErrorBar(binValueinHours(1:length(meanT1)), meanT1(i,:), stdT1(i,:), color{i});
%      hold on
% end

%% Frequency of T1 transitions at different growthrates
close all
UnivarScatter(T1perHour','Label',      {'0.45'	... 
                                        '0.50'   ...
                                        '0.55'	... 
                                        '0.60'   ...
                                        '0.65'   ...
                                       }, 'SEMColor', [1 1 1], 'MarkerFaceColor', 'k');
hXLabel = xlabel('Average Growth Rate (S, x 10^-^3)');
hYLabel = ylabel('T1 Transition Frequency hr^-^1');

set(gca,'FontSize',smallFont)

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'Times'   , ...
    'FontSize'      , bigFont      	 ,...
    'Color'           , [0 0 0]  	...
);

set(gca, ...
	'LineWidth'     , 2       	, ...
    'Box'           , 'on'     	, ...
    'TickLength'    , [.025 .025]	, ...
    'TickDir'       , 'in'    	...
);
% 
% xlhand = get(gca,'xlabel');
% set(xlhand, 'fontsize',26);
% ylhand = get(gca,'ylabel');
% set(ylhand, 'fontsize',26);
% minAxis = nanmin(T1perHour(:));
maxAxis = uint16(nanmax(T1perHour(:))+0.5);
axis([0.25 5.75 0 maxAxis])

axis normal
% hFigure.PaperUnits = 'inches';
% hFigure.PaperPosition = [-4 -4 40 40];
% hFigure.PaperPositionMode = 'manual';
print([ settings.outFigureDir 'T1Growth.eps'],'-depsc2')
print([ settings.outFigureDir 'T1Growth.png'],'-dpng','-r300')
