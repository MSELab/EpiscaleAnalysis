
categories = {'GrowthConstant_0.4','GrowthConstant_0.5'};
growthRates = [0.6, 0.65];

clear T1per100Divisions cumT1Mat totalTime totalCells simulationName T1sOverTimePeriod binValue T1PerCell T1NumberTotal

simulationTimescale = 100 / 2000; % 100 hours per 2000 timesteps

binSize = 100;
regionOfInterest = 5;
close all
n = 1;

%% Data Extraction
for i = 1:length(categories)
    indices = find(~cell2mat(cellfun(@(x) isempty(x),strfind(labels', categories{i}), 'UniformOutput', 0)));
    % Iterate over the replicates within one experiment
    jCount = 1;
    for j = indices
        tempN = N(j, :);
        normT1positions = [];
        normCellPositions = [];
        clear T1Total T1InRange allCellInRange allCellTotal;
        for t = 1200:2000
            cellPositions = rMat{j,t};
            maxR = discSizeMat{j,t};
            if maxR < regionOfInterest
                error('disc is too small');
            end
            normCellPositions = [normCellPositions cellPositions ./ maxR];
            T1positions = cell2mat(positions{j,t});
            normT1positions = [normT1positions T1positions / maxR];
            T1Total(t) = length(T1positions) / 2;
            T1InRange(t) = sum(T1positions < regionOfInterest) / 2;
            allCellInRange(t) = sum(cellPositions < regionOfInterest);
            allCellTotal(t) = sum(cellPositions > 0);
        end
        
        %         plot(1200:2000, allCellInRange(1200:2000), 1200:2000, allCellTotal(1200:2000));
        %         hold on
        
        tempT1hist = hist(normT1positions,20);
        [tempcellhist tempbin] = hist(normCellPositions,20);
        tempratio = tempT1hist ./ tempcellhist;
        
        subplot(8,3,n)
        hist(normT1positions);
        n = n + 1;
        subplot(8,3,n)
        hist(normCellPositions);
        n = n + 1;
        subplot(8,3,n)
        plot(tempbin, tempratio);
        n = n + 1;
        if min(gradient(tempN)) > 0
            error('Simulation missing output files')
        end
        r2Temp = fitlm(1200:2000,cumsum(T1InRange(1200:2000)));
        regressionCoefficient(i,jCount) = r2Temp.Rsquared.Ordinary;
        cellNumberMean(i,jCount) = mean(allCellInRange(1200:2000));
        cellNumberStd(i,jCount) = std(allCellInRange(1200:2000));
        T1NumberTotal(i,jCount) = sum(T1InRange);
        T1PerCell(i,jCount) = T1NumberTotal(i,jCount) / cellNumberMean(i,jCount);
        
        jCount = jCount + 1;
    end
end


%% Mean Cummulitive T1 Transition Number
% close all
% meanT1 = squeeze(nanmean(cumT1Mat(:,:,1:2000),2));
% stdT1 = squeeze(nanstd(cumT1Mat(:,:,1:2000),0,2));
% color = {'m','c','g','b','k','y','r'};
% for i = 1:length(categories)
%      shadedErrorBar(1:length(meanT1(i,:)), meanT1(i,:), stdT1(i,:), color{i});
%      hold on
% end

%% Mean Cummulitive T1/100 div Transition Number
% close all
% T1per100Divisions(T1per100Divisions == 0) = NaN;
% meanT1 = squeeze(nanmean(T1per100Divisions(:,:,1:2000),2));
% stdT1 = squeeze(nanstd(T1per100Divisions(:,:,1:2000),0,2));
% color = {'m','c','g','b','k','y','r'};
% for i = 1:length(categories)
%      shadedErrorBar(1:length(meanT1(i,:)), meanT1(i,:), stdT1(i,:), color{i});
%      hold on
% end

%% Mean T1 frequency (binned)
% close all
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

%% Cummulitive T1/100 div Transition Number at t = 2000
close all
T1NumberTotal(T1NumberTotal == 0) = NaN;
T1NumberFreq = T1NumberTotal / simulationTimescale / 800 / 3600;
UnivarScatter(T1NumberFreq','Label',{'0.40 to 0.80', '0.5 to 1.00'});
xlabel('Growth Rate (S)');
ylabel('T1 Transition Frequency (Hz)');
