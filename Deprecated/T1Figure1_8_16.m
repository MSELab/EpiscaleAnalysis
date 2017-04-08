
categories = {'Growth_0.5to2.5','Growth_1to3','Growth_1.5to3.5','Growth_2to4'};
growthRates = [1.5, 2, 2.5, 3];

clear T1per100Divisions cumT1Mat totalTime totalCells simulationName T1sOverTimePeriod binValue

simulationTimescale = 100 / 2000; % 100 hours per 2000 timesteps

binSize = 100;

%% Data Extraction
for i = 1:length(categories)
    indices = find(~cell2mat(cellfun(@(x) isempty(x),strfind(labels, categories{i}), 'UniformOutput', 0)));
    % Iterate over the replicates within one experiment
    jCount = 1;
    for j = indices
        tempN = N(j, :);
        if min(gradient(tempN)) > 0
            error('Simulation missing output files')
        end
        
        tempT1 = T1s(j, :);
        tempdivisions = cellNumberMatrix(j, :) - 7;
        
        tempT1(~tempN) = [];
        tempdivisions(~tempN) = [];
        
        % Extract cummilitive distribution
        cummT1 = cumsum(tempT1);
        cumT1Mat(i, jCount, 1:4000) = NaN;
        if length(tempT1) >= 2000
            cumT1Mat(i, jCount, 1:length(cummT1)) = cummT1;
        end   
        
        % Extract summary statistics
        T1per100 = cummT1 ./ tempdivisions / 100;
        T1per100Divisions(i,jCount,1:length(T1per100)) = T1per100;
        totalTime(i, jCount) = length(tempT1);
        totalCells(i, jCount) = max(tempdivisions) + 7;
        simulationName{i,jCount} = labels{j};
        
        if length(tempT1) >= 2000
            T1per100summary(i,jCount) = T1per100(2000);
        end
        
        binNumber = 1;
        % Extract frequencies
        for initialTime = 1:binSize:length(tempT1)
            finalTime = binSize + initialTime - 1;
            finalTime = min(finalTime, length(tempT1));
            T1sOverTimePeriod(i,jCount,binNumber) = sum(tempT1(initialTime:finalTime));
            binValue(binNumber) = mean([initialTime finalTime]);
            binNumber = binNumber + 1;
        end
        
        jCount = jCount + 1;
    end
end

for i = 1:length(categories)
    useableSampleSize(i) = sum(totalTime(i, :) >= 2000);
    sampleSize(i) = sum(totalTime(i, :) >= 1);
end
    
useableSampleSize
sampleSize

%% Mean Cummulitive T1 Transition Number
close all
meanT1 = squeeze(nanmean(cumT1Mat(:,:,1:2000),2));
stdT1 = squeeze(nanstd(cumT1Mat(:,:,1:2000),0,2));
color = {'m','c','g','b','k','y','r'};
for i = 1:length(categories)
     shadedErrorBar(1:length(meanT1(i,:)), meanT1(i,:), stdT1(i,:), color{i});
     hold on
end

%% Mean Cummulitive T1/100 div Transition Number
close all
T1per100Divisions(T1per100Divisions == 0) = NaN;
meanT1 = squeeze(nanmean(T1per100Divisions(:,:,1:2000),2));
stdT1 = squeeze(nanstd(T1per100Divisions(:,:,1:2000),0,2));
color = {'m','c','g','b','k','y','r'};
for i = 1:length(categories)
     shadedErrorBar(1:length(meanT1(i,:)), meanT1(i,:), stdT1(i,:), color{i});
     hold on
end

%% Mean T1 frequency (binned)
close all
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

%% Cummulitive T1/100 div Transition Number at t = 2000
close all
T1per100Divisions(T1per100Divisions == 0) = NaN;
finalT1 = T1per100Divisions(:,:,2000);
UnivarScatter(finalT1');