%% Prepare workspace
clearvars
settings = prepareWorkspace;
[labels, metadata] = importData(settings);

settings.firstDivision = 10;
settings.lastDivision = 300;
settings.cellRadius = 60;
settings.minCellsToCount = 1;

%% Load data
for i = 1:length(labels)
    if (exist(['Data' filesep labels{i} filesep 'T1Transitions.mat'], 'file'))
        data = load(['Data' filesep labels{i} filesep 'T1Transitions.mat']);
        data2 = load(['Data' filesep labels{i} filesep 'dataFile.mat']);
        measurements(i) = compareT1Transitions(data, data2, settings);
        if ~isfield(data, 'frame') || ~isfield(data, 'T1_count')
            flag(i) = -3;
        elseif length(data.frame) <= 10
            flag(i) = -2;
        else
            flag(i) = 1;
            frame{i} = data.frame;
            T1_count{i} = data.T1_count;
        end
    else
        flag(i) = -1;
    end
end

frame = frame(flag > 0);
T1_count = T1_count(flag > 0);

%% Extract data for reproducible area and cell number
% Declare analysis settings


% Load data
cellNumber = data2.cellNumber;
cellPos = data2.cellCenters;
T1_transition_time = data.T1_time;
T1_cells = data.T1_cells;

% Determine which T1 transitions are to be counted
cellsToAnalyze = cellNumber(1) + [firstDivision, lastDivision];
timeWindowTmp = find(cellNumber >= cellsToAnalyze(1) & cellNumber <= cellsToAnalyze(2));
timeToAnalyze = [timeWindowTmp(1), timeWindowTmp(end)];
T1_in_time_window = T1_transition_time >= timeToAnalyze(1) & ...
    T1_transition_time <= timeToAnalyze(2);

for i = 1:length(T1_in_time_window)
    t = T1_transition_time(i);
    Ns = T1_cells(:,i)';
    
    tmpCenters = cellPos{i}(:,1:2);
    origin = [mean(tmpCenters(:,1)), mean(tmpCenters(:,2))];
    distFromOrigin = sqrt(sum((tmpCenters-origin).^2,2));
    sortDist = sort(distFromOrigin);
    maxDistance = sortDist(cellRadius);
    activeCells = find(distFromOrigin <= maxDistance);
    
    cellsInRange(i) = sum(sum(activeCells == Ns));
    inTimeWindow(i) = T1_in_time_window(i);
end

T1_trans_counted = inTimeWindow & (cellsInRange >= minCellsToCount);

%% Test
T1_times = uint16(T1_transition_time(T1_trans_counted))';
frames = timeToAnalyze(1):timeToAnalyze(2);
cumT1Trans = zeros(size(frames));
for i = 1:length(T1_times)
    cumT1Trans(frames > T1_times(i)) = cumT1Trans(frames > T1_times(i)) + 1;
end

for t = 1:length(T1_times)
    T1_pos(t,:) = mean(cellPos{T1_times(t)}(T1_cells(:,t),1:2),1);
end

tmpCenters = cellPos{T1_times(end)}(:,1:2);
origin = [mean(tmpCenters(:,1)), mean(tmpCenters(:,2))];
distFromOrigin = sqrt(sum((tmpCenters-origin).^2,2));
sortDist = sort(distFromOrigin);
maxDistance = sortDist(cellRadius);
activeCells = find(distFromOrigin <= maxDistance);

cellsInRange(i) = sum(sum(activeCells == Ns));
inTimeWindow(i) = T1_in_time_window(i);

figure(1)
clf
scatter(tmpCenters(:,1),tmpCenters(:,2))
hold on
scatter(origin(1), origin(2))
scatter(tmpCenters(activeCells,1),tmpCenters(activeCells,2),'filled')
scatter(T1_pos(:,1),T1_pos(:,2),32,'filled')
axis equal

T1_count = sum(T1_trans_counted);

figure(2)
plot(frames, cumT1Trans);
xlabel('Time (frames)')
ylabel('T1 Transitions')

mdl = fitlm(frames, cumT1Trans);
coeff = mdl.Coefficients;
coeff = coeff(2,:);

measurements.T1_transition_rate = coeff.Estimate;
measurements.T1_transition_rate_SE = coeff.SE;
measurements.mdl = mdl;
measurements.R2 = mdl.Rsquared.Adjusted;
measurements.frames = timeToAnalyze;
measurements.err_ratio = coeff.Estimate / coeff.SE;

measurements

figure(3)
for t = 1:length(cellNumber)
    Ns = T1_cells(:,i)';
    
    tmpCenters = cellPos{t}(:,1:2);
    origin = [mean(tmpCenters(:,1)), mean(tmpCenters(:,2))];
    distFromOrigin = sqrt(sum((tmpCenters-origin).^2,2));
    sortDist = sort(distFromOrigin);
    rMaxMat(t) = sortDist(cellRadius);
end
plot(1:length(cellNumber), rMaxMat);
xlabel('Frames')
ylabel('Radius')

figure(4)
plot(cellNumber(frames), cumT1Trans);
xlabel('Cell Number')
ylabel('T1 Transitions')

%% Make figures
% figure(1)
% clf
%
% g = metadata(flag > 0,:).g_ave;
% MR = metadata(flag > 0,:).MR;
%
% g_key = unique(g);
% MR_key = unique(MR);
%
% for i = 1:length(g_key)
%     for j = 1:length(MR_key)
%         active = g_key(i) == g & MR_key(j) == MR;
%         clear frameNum
%         for k = find(active)
%             tmp = T1_count{k};
%             frameNum(k) = length(tmp);
%         end
%         T1_count_mat = nan(max(frameNum), sum(active));
%         k_count = 1;
%         for k = find(active)'
%             tmp = T1_count{k};
%             T1_count_mat(1:length(tmp), k_count) = tmp;
%             k_count = k_count + 1;
%         end
%         N(i,j) = k_count;
%         meanProfile{i,j} = nanmean(T1_count_mat, 2);
%     end
% end
%
% colors = {'k', 'r', 'g', 'b', 'm', 'c'};
%
% for i = 1:size(meanProfile,1)
%     plot(cumsum(meanProfile{i,1}), ['--' colors{i}]);
%     hold on
%     plot(cumsum(meanProfile{i,2}), ['-' colors{i}]);
% end
%
% legendmat = {};
% for i = 1:length(g_key)
%     legendmat{end+1} = ['g_a_v_e = ' num2str(g_key(i)), ' no MR'];
%     legendmat{end+1} = ['g_a_v_e = ' num2str(g_key(i))];
% end
%
% legend(legendmat)
% xlim([10, inf])
%
% set(gca, 'YScale', 'log')
% set(gca, 'XScale', 'log')
%
% xlabel('Time (0.01 hours)')
% ylabel('Cummulitive number of T1 transitions')

