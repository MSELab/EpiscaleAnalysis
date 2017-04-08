clearvars
close all

%% Declaration
searchTerms = {'N0'};
colors = {'k','m','b','r','c'};

dtds = 100 / 2000; %100 hours per 2000 outputs

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);

memNodesMax = nan(6000, length(labels));
intNodesMax = nan(6000, length(labels));

%% Data Extraction
for j = length(labels):-1:1
    disp(['Analyzing: ' labels{j}])
    load([settings.matDir labels{j} '.mat'], 'cellArea', 'growthProgress');
    [savedAreaIFM, time] = trackCells(cellArea, growthProgress);
    savedAreaIFMAll{j} = savedAreaIFM;
    savedTime{j} = time;
end

%% Analyze mitotic data
for j = 1:length(labels)
    temp = savedAreaIFMAll{j};
    mitoticRatio = temp(:,3) ./ temp(:,2);
    time = savedTime{j};
    time = time(:,3);
    time = time(1:size(mitoticRatio,1),:);
    
    for i = 1:20
        temp2 = mitoticRatio(time>=((i-1)*100)&time<((i)*100));
        MR(i,j) = nanmean(temp2);
        n(i,j) = length(~isnan(temp2));
    end
    %mitRatio(j) = nanmean(mitoticRatio);
    %areaI(j) = nanmean(temp(:,1));
    %areaIstd(j) = nanstd(temp(:,1));
    %areaF(j) = nanmean(temp(:,2));
    %areaFstd(j) = nanstd(temp(:,2));
    %areaM(j) = nanmean(temp(:,3));
    %areaMstd(j) = nanstd(temp(:,3));
end

%% Make plots
meanMR = mean(MR, 2);
stdMR = std(MR, [], 2);
times = ((1:20) * 100 - 50) * dtds;

figure(1)
errorbar(times, meanMR, stdMR,'k');
xlabel('Time of measurement (hr)');
ylabel('Mitotic Ratio');
axis([0, 100, 0, 7])
