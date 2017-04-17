function measurements = compareT1Transitions(data, data2, settings)
%% Extract data for reproducible area and cell number
% Declare analysis settings
firstDivision = settings.firstDivision;
lastDivision = settings.lastDivision;
cellRadius = settings.cellRadius;
minCellsToCount = settings.minCellsToCount;

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

T1_count = sum(T1_trans_counted);

mdl = fitlm(frames, cumT1Trans);
coeff = mdl.Coefficients;
coeff = coeff(2,:);

measurements.T1_transition_rate = coeff.Estimate;
measurements.T1_transition_rate_SE = coeff.SE;
measurements.mdl = mdl;
measurements.R2 = mdl.Rsquared.Adjusted;
measurements.frames = timeToAnalyze;
measurements.err_ratio = coeff.Estimate / coeff.SE;
end