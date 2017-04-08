clearvars
close all

%% Declaration
searchTerms = {'Control_0.55_to_1.11','NoRounding_0.55_to_1.11', 'U0_'};
           
dtds = 100 / 2000; %100 hours per 2000 outputs


%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);

allCellNumber = nan(4000, length(labels));
totalArea = nan(4000, length(labels));

%% Data Extraction
for j = length(labels):-1:1
    disp(['Analyzing: ' labels{j}])
    load([settings.matDir labels{j} '.mat'], 'growthProgress', 'cellArea');
    for t = length(growthProgress):-1:1
        area = cellArea{t};
        totalArea(t, j) = sum(area);
        allCellNumber(t, j) = length(area);
    end
end

%% Process rounding data
cellNumber = 0;
for i = 1:6

