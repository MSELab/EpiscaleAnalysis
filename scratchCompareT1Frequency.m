% %% Prepare workspace
% clearvars
% settings = prepareWorkspace;
% [labels, metadata] = importData(settings);
%
% %% Load data
% for i = 1:length(labels)
%     if (exist(['Data' filesep labels{i} filesep 'T1Transitions.mat'], 'file'))
%         data = load(['Data' filesep labels{i} filesep 'T1Transitions.mat']);
%         data2 = load(['Data' filesep labels{i} filesep 'dataFile.mat']);
%         if ~isfield(data, 'frame') || ~isfield(data, 'T1_count')
%             flag(i) = -3;
%         elseif length(data.frame) <= 10
%             flag(i) = -2;
%         else
%             flag(i) = 1;
%             frame{i} = data.frame;
%             T1_count{i} = data.T1_count;
%         end
%     else
%         flag(i) = -1;
%     end
% end
%
% frame = frame(flag > 0);
% T1_count = T1_count(flag > 0);

%% Extract data for reproducible area and cell number
% Declare analysis settings
firstDivision = 50;
lastDivision = 200;
cellRadius = 70;
minCellsToCount = 1;

% Load data
cellNumber = data2.cellNumber;
cellPos = data2.cellCenters;
T1_transition_time = data.T1_time;
T1_cells = data.T1_cells;

% Determine which T1 transitions are to be counted
timeToAnalyze = cellNumber(1) + [firstDivision, lastDivision];
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
for i = 

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
scatter(T1_pos(:,1),T1_pos(:,2),'.')
axis equal

T1_count = sum(T1_trans_counted);

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

