clear all
close all

%% Declaration
growthRates = 3.0;
binSize = 200;
simulationTimescale = 2000 / 100; % 2000 timesteps per 100 hours
T1Settings.analysisTime = 2000;
T1Settings.minimumTime = 50;
T1Settings.minCellNumber = 50;
T1Settings.cellsToAnalyze = 50;
searchTerms = {'Growth_2to4','GrowthConstant_0.5to'};
           
smallFont = 24;
bigFont = 28;

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);
T1perHour = NaN(length(unique(labelIndices)), length(labelIndices));
R2 = NaN(length(unique(labelIndices)), length(labelIndices));
startTimes = NaN(length(unique(labelIndices)), length(labelIndices));
endTimes = NaN(length(unique(labelIndices)), length(labelIndices));
T1InRange = cell(length(unique(labelIndices)), length(labelIndices));

%% Data Extraction
for i = unique(labelIndices)
    % Iterate over the replicates within one experiment
    runIndices = find(labelIndices == i);
    for j = find(labelIndices == i)
        disp(['Analyzing: ' labels{j}])
        load([settings.matDir labels{j} '.mat'], 'T1Position');
        load([settings.matDir labels{j} '.mat'], 'position');
        load([settings.matDir labels{j} '.mat'], 'edgeCell');
        
        [T1perHour(i, j), R2(i, j), startTimes(i, j), endTimes(i, j), T1InRange{i, j}] = T1FrequencyRoI(T1Position, position, edgeCell, T1Settings);
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

%% Plot cummulitive T1 Transitions
close all
hfigure = figure();
[types, samples] = size(T1InRange);
countedT1cumm = nan(types, samples, 4000);

for i = 1:types
    for j = 1:samples
        countedT1temp = T1InRange{i,j};
        if length(countedT1temp) < 1 || isnan(startTimes(i,j))
            continue
        end
        countedT1temp(1:(startTimes(i,j) - 1)) = [];
        plot(cumsum(countedT1temp));
        countedT1(i, j, 1:length(countedT1temp)) = countedT1temp;
        countedT1cumm(i, j, 1:length(cumsum(countedT1temp))) = cumsum(countedT1temp);
        hold on
    end
end

%% Plot mean and stdev of cumm T1 transitions
close all
hfigure = figure();
meanT1perHour = squeeze(nanmean(countedT1cumm,2));
stdT1perHour = squeeze(nanstd(countedT1cumm,1,2));

errorbar(repmat(1:4000,[types, 1])',meanT1perHour',stdT1perHour')

%% Mean T1 frequency (binned)
close all

for i = 1:types
    for j = 1:samples
        countedT1temp = T1InRange{i,j};
        if length(countedT1temp) < 1 || isnan(startTimes(i,j))
            continue
        end
        countedT1temp(1:(startTimes(i,j) - 1)) = [];
        bin = 1;
        for binMin = 1:binSize:(length(countedT1temp)-1)
            binMax = min([length(countedT1temp), binMin+binSize-1]);
            binValueinHours = (binMax - binMin + 1) / simulationTimescale;
            binnedT1Freq(i, j, bin) = sum(countedT1temp(binMin:binMax)) / binValueinHours;
            bin = bin + 1;
        end
    end
end

meanT1Freq = squeeze(nanmean(binnedT1Freq,2))';
stdT1Freq = squeeze(nanstd(binnedT1Freq,0,2))';
color = {'m','c','g','b','k','y','r'};
for i = 1:types
     shadedErrorBar(((1:length(meanT1Freq(i,:))) - 0.5) * binSize / simulationTimescale, meanT1Freq(i,:) * 2, stdT1Freq(i,:) * 2, color{i});
     hold on
end

xlabel('Time after 500 cells reached (hr)');
ylabel('T1 transitions per hour per 1000 cells');
axis([0 inf 0 20])