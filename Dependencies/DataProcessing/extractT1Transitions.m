function flag = extractT1Transitions(label, settings)
if nargin < 2
    settings = getSettings;
end

%% Initialization
mpCutoff = settings.mpCutoff;
framesSearched = settings.framesSearched;
minSimTime = 1; %settings.minSimTime;
[data, flag] = getData(label, {'neighbors','growthProgress','cellCenters'});
if ~flag
    return
end

%% Populate adjacency matrix
numFrames = length(data.neighbors);
for t = numFrames:-1:1
    tmp = data.neighbors{t};
    adj(1:length(tmp),1:length(tmp),t) = adjacencyArray2Mat(tmp);
end

%% Find cells that gain a neighbor
[i_gained, j_gained, t_gained] = ind2sub(size(adj),find((adj(:,:,2:end)-adj(:,:,1:end-1)) > 0));
duplicates = i_gained > j_gained;
i_gained = i_gained(~duplicates);
j_gained = j_gained(~duplicates);
t_gained = t_gained(~duplicates);

for i = length(i_gained):-1:1
    CP(i,:) = data.growthProgress{t_gained(i)+1}([i_gained(i), j_gained(i)]);
end

mitotic = any(CP' < mpCutoff(1) | CP' > mpCutoff(2));

adjLost = (adj(:,:,2:end)-adj(:,:,1:end-1)) < 0;
tSearchStart = max(t_gained - framesSearched, 1);
tSearchEnd = min(t_gained + framesSearched, numFrames - 1);

%% Find if cells expected to lose a neighbors do lose a neighbors
occurs = zeros(size(t_gained), 'logical');
t_lost = zeros(size(t_gained));
cellsInvolved = [];
for t = find(~mitotic)
    tmp = data.neighbors{t_gained(t)};
    toLose = intersect(tmp{[i_gained(t), j_gained(t)]});
    if length(toLose) < 2
        continue
    end
    if length(toLose) > 2
        toLose = toLose(1:2);
       warning('T1 transition requires 4 cells') 
    end
    occurs(t) = any(adjLost(toLose(1),toLose(2),tSearchStart(t):tSearchEnd(t)));
    if occurs(t)
        t_lost(t) = tSearchStart(t) - 1 + find(squeeze(adjLost(toLose(1),toLose(2), ...
            tSearchStart(t):tSearchEnd(t))));
        cellsInvolved(1:2,t) = [i_gained(t), j_gained(t)];
        cellsInvolved(3:4,t) = toLose;
    else
        cellsInvolved(1:4,t) = 0;
    end
end

%% Measure T1 transition frequency
T1_time = mean([t_gained, t_lost], 2);
T1_time = T1_time(occurs);
T1_cells = cellsInvolved(:, occurs);
cellCenters = data.cellCenters(round(T1_time));
if isempty(cellCenters)
    T1_positions = [];
    T1_radius = [];
end
for i = length(cellCenters):-1:1
    tmp = cellCenters{i};
    T1_positions(i,:) = mean(tmp(T1_cells(:,i),1:2),1) - 25;
    T1_radius = sqrt(sum(T1_positions.^2,2));
end

[T1_count,frame] = histcounts(T1_time,0:numFrames);
frame(1:minSimTime+1) = [];
frame = frame / 100; % convert frame to hours
T1_count(1:minSimTime) = [];
plot(frame,cumsum(T1_count))
T1_model = fitlm(frame,cumsum(T1_count));

%% Save analysis
pathDatafile = strrep(settings.thruT1, '$', label);
disp(['Saving mat T1 transition file for ' label])

save(pathDatafile, 'T1_model', 'T1_count', 'frame', 'T1_positions', ...
    'T1_radius', 'T1_cells', 'T1_time');

flag = 1;