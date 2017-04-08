clear r2Temp regressionCoefficient cellNumberMean cellNumberStd T1NumberTotal T1PerCell
close all

%% Declaration
growthRates = [0.3, 0.4, 0.5, 0.6, 0.7] * 1.5;
simulationTimescale = 100 / 2000; % 100 hours per 2000 timesteps
binSize = 100;
regionOfInterest = 5;

%% Inputs from identification script
outT1s; % When T1s Happen
outN; % Whether Time Was Analyzed
outCellNumber; % Total Number of Cells
outPosition;
outT1Position;
outLabelIndices;
startTime = 1400;
endTime = 2000;

%% Initialization
n = 1;
settings = prepareWorkspace();
completeSimulations = outN(:,endTime);
simulationProgress = sum(outN,2);
failed = [];

%% Data Extraction
for i = unique(labelIndices)
    % Iterate over the replicates within one experiment
    jCount = 1;
    for j = find(outLabelIndices == i)
        if ~completeSimulations(j)
            failed = [failed j]
            continue
        end
        tempN = outN(j, :);
        clear T1Total T1InRange allCellInRange allCellTotal;
        
        if min(gradient(tempN)) > 0
            error('Simulation missing output files')
        end
        
        failureFlag = false;
        
        for t = startTime:endTime
            cellPositions = outPosition{j,t};
            T1Positions = outT1Position{j,t};
            maxR = max(cellPositions);
            if maxR < regionOfInterest
                failed = [failed j]
                failureFlag = true;
                break
                error('disc is too small');
            end
            T1positions = outT1Position{j,t};
            T1Total(t) = length(T1positions) / 2;
            T1InRange(t) = sum(T1positions < regionOfInterest) / 2;
            allCellInRange(t) = sum(cellPositions < regionOfInterest);
            allCellTotal(t) = length(cellPositions);
        end
        
        if failureFlag
            continue
        end
        
%         plot(startTime:endTime, allCellInRange(startTime:endTime), startTime:endTime, allCellTotal(startTime:endTime));
%         hold on
        plot(startTime:endTime, cumsum(T1InRange(startTime:endTime)), startTime:endTime, cumsum(T1Total(startTime:endTime)));
        hold on
        cumT1Mat(i,jCount,1:endTime) = cumsum(T1InRange);
        
        r2Temp = fitlm(startTime:endTime,cumsum(T1InRange(startTime:endTime)));
        regressionCoefficient(i,jCount) = r2Temp.Rsquared.Ordinary;
        cellNumberMean(i,jCount) = mean(allCellInRange(startTime:endTime));
        cellNumberStd(i,jCount) = std(allCellInRange(startTime:endTime));
        T1NumberTotal(i,jCount) = sum(T1InRange);
        T1PerCell(i,jCount) = T1NumberTotal(i,jCount) / cellNumberMean(i,jCount);
        
        jCount = jCount + 1;
    end
    close all
end


%% Mean Cummulitive T1 Transition Number
close all
cumT1Mat(cumT1Mat==0) = NaN;
meanT1 = squeeze(nanmean(cumT1Mat(:,:,1:2000),2));
stdT1 = squeeze(nanstd(cumT1Mat(:,:,1:2000),0,2));
color = {'m','c','g','b','k','y','r'};
for i = 1:4
     shadedErrorBar(1:length(meanT1(i,:)), meanT1(i,:), stdT1(i,:), color{i});
     hold on
end

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
T1NumberTotal(T1NumberTotal == 0) = NaN;
% T1NumberTotal(failed,:) = [];
T1NumberFreq = T1NumberTotal / simulationTimescale / (endTime-startTime) / 3600;
UnivarScatter(T1NumberFreq','Label',   {'0.45'	... 
                                        '0.50'   ...
                                        '0.55'	... 
                                        '0.60'   ...
                                        }, 'SEMColor', [1 1 1]);
hXLabel = xlabel('Average Growth Rate (S, x 10^-^3)');
hYLabel = ylabel('T1 Transition Frequency s^-^1');

set(gca,'FontSize',20)

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'Arial'   , ...
    'FontSize'      , 22      	 ,...
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

axis normal
% hFigure.PaperUnits = 'inches';
% hFigure.PaperPosition = [-4 -4 40 40];
% hFigure.PaperPositionMode = 'manual';
print([ settings.outFigureDir 'T1TransitionGrowth.png'],'-dpng','-r75')
print([ settings.outFigureDir 'T1TransitionGrowth.eps'],'-depsc2')
