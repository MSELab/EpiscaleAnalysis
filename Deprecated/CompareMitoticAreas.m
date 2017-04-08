clearvars
close all

%% Declaration
searchTerms = {'RepulsiveLoad_0.5_', 'RepulsiveLoad_1_', 'RepulsiveLoad_1.5_', 'RepulsiveLoad_2_'};
formalLabels = {'0.5x', '1.0x', '1.5x', '2.0x'};
colors = {'k','m','b','r','c'};

dtds = 100 / 2000; %100 hours per 2000 outputs

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);

memNodesMax = nan(4000, length(labels));
intNodesMax = nan(4000, length(labels));

%% Data Extraction
for j = length(labels):-1:1
    disp(['Analyzing: ' labels{j}])
    load([settings.matDir labels{j} '.mat'], 'cellArea', 'growthProgress');
    savedAreaIFM = trackCells(cellArea, growthProgress);
    savedAreaIFMAll{j} = savedAreaIFM;
end

%% Analyze mitotic data
for j = 1:length(labels)
    temp = savedAreaIFMAll{j};
    MR = temp(:,3) ./ temp(:,2);
    mitoticRatio(j) = nanmean(MR);
    n(j) = sum(~isnan(MR));
end

%% Make plots
figure(1)
conditions = unique(labelIndices);
for i = conditions
    meanMR(i) = nanmean(mitoticRatio(labelIndices==i));
end
bar(conditions,meanMR,'k')
xlabel('Mitotic Force Fold-Change');
ylabel('Mitotic Area / Premitotic Area');
set(gca,'xticklabel',[formalLabels])
n










