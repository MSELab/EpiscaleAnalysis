clearvars
close all

%% Declaration
searchTerms = {'N0'};
           
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

%% Get A_dot/A
% [~, dAds] = gradient(totalArea);
dAds = gradient(totalArea);
dAdt = dAds / dtds;
A_dot_over_A = dAdt ./ totalArea;


%% Plot test graphs
close all
figure(1)
t = ((1:length(totalArea)))*dtds;
plot(t, totalArea)
xlabel('Time (hr)')
ylabel('Area (length^2)')
return
figure(2)
dAdt(1:10,:) = [];
plot(dAdt)

figure(3)
A_dot_over_A(1:10,:) = [];
plot(A_dot_over_A)

figure(4)
meanAdotA = nanmean(A_dot_over_A,2);
meanAdotA(isnan(meanAdotA)) = [];
t = ((1:length(meanAdotA))+9)*dtds;
plot(t, meanAdotA)
xlabel('Time (hr)')
ylabel('A_d_o_t/A (hr^-^1)')

figure(5)
meanAdotA = nanmean(A_dot_over_A,2);
meanAdotA(isnan(meanAdotA)) = [];
t = ((1:length(meanAdotA))+9)*dtds;
plot(t, imgaussfilt(meanAdotA,5))
xlabel('Time (hr)')
ylabel('A_d_o_t/A (hr^-^1), Gaussian Filter sigma = 5')
