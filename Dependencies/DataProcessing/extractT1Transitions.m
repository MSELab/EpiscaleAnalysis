function flag = extractT1Transitions(label, settings)
if nargin < 2
    settings = getSettings;
end


%% Initialization
mpCutoff = settings.mpCutoff;
framesSearched = settings.framesSearched;
minSimTimeToAn = 100;
minSimTime = 1; %settings.minSimTime;
[data, flag] = getData(label, {'neighbors','growthProgress','cellCenters'});
pathDatafile = strrep(settings.thruT1, '$', label);
if ~flag
    return
end
if exist(pathDatafile, 'file')&&~settings.force
    flag = 2;
    disp('T1 transitions already analyzed.')
    return
end

%% Obtain cell number per frame
n = 0;
for i = 1:length(data.neighbors)
   tmp1 = data.growthProgress{i};
   tmp2 = data.cellCenters{i};
   N1 = length(tmp1);
   N2 = length(tmp2);
   if N1 == N2 && N1 >= n 
       n = N1;
   else
       break
   end
   Nmat(i) = N1;
end

data.neighbors = data.neighbors(1:i-1);
data.growthProgress = data.growthProgress(1:i-1);
data.cellCenters = data.cellCenters(1:i-1);

if length(data.cellCenters) < minSimTimeToAn
    flag = -2;
    save(pathDatafile, 'flag')
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
toRemove = i_gained > j_gained | i_gained > Nmat(t_gained)' | j_gained > Nmat(t_gained)';
i_gained(toRemove) = [];
j_gained(toRemove) = [];
t_gained(toRemove) = [];

%% Find corresponding loser cells
T1Cell = [];
T1Time = [];

for i = 1:length(i_gained)
    tmp = data.neighbors{t_gained(i)};
    toLose = intersect(tmp{[i_gained(i), j_gained(i)]});
    if length(toLose) >= 2
        loserCells = nchoosek(toLose,2);
        for j = 1:size(loserCells, 1)
            T1Cell(end+1,1:4) = [i_gained(i), j_gained(i), loserCells(j,:)];
            T1Time(end+1) = t_gained(i);
        end
    end
end

%% Verify that loser cells lost each other as neighbors
adjLost = (adj(:,:,2:end)-adj(:,:,1:end-1)) < 0;
tSearchStart = max(T1Time - framesSearched, 1);
tSearchEnd = min(T1Time + framesSearched, numFrames - 1);
T1Cell2 = [];
T1Time2 = [];
for i = 1:length(T1Time)
    adjLostActive = adjLost(T1Cell(i,3),T1Cell(i,4),tSearchStart(i):tSearchEnd(i));
    lost = ind2sub(size(adjLostActive), find(adjLostActive)) + tSearchStart(i) - 1;
    if ~isempty(lost)
        T1Cell2(end+1:end+length(lost),:) = repmat(T1Cell(i,:), [length(lost), 1]);
        T1Time2(end+1:end+length(lost)) = mean([repmat(T1Time(i),size(lost)), lost],2);
    end
end
T1Cell = T1Cell2;
T1Time = T1Time2;

%% Verify that none of the T1 transition cells are mitotic
mitotic = ones(size(T1Time), 'logical');
for i = length(T1Time):-1:1
    time = round(min([length(data.growthProgress) T1Time(i)]));
    if length(data.growthProgress{time}) <= max(T1Cell(i,:))
        CP = data.growthProgress{time}(T1Cell(i,:));
        mitotic(i) = any(CP < mpCutoff(1) | CP > mpCutoff(2));
    else
        mitotic(i) = true;
    end
end
T1Cell = T1Cell(~mitotic, :);
T1Time = T1Time(~mitotic);

%% Save analysis
disp(['T1 Analysis: Saving mat T1 transition file for ' label])

flag = 1;

T1_cells = T1Cell;
T1_time = T1Time;

save(pathDatafile, 'T1_cells', 'T1_time', 'flag');