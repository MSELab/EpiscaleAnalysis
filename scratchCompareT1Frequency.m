%% Prepare workspace
clearvars
settings = prepareWorkspace;
[labels, metadata] = importData(settings);

%% Load data
for i = 1:length(labels)
    if (exist(['Data' filesep labels{i} filesep 'T1Transitions.mat'], 'file'))
        data = load(['Data' filesep labels{i} filesep 'T1Transitions.mat'], 'T1_count', 'frame');
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

%% Make figures
figure(1)
clf

g = metadata(flag > 0,:).g_ave;
MR = metadata(flag > 0,:).MR;

g_key = unique(g);
MR_key = unique(MR);

for i = 1:length(g_key)
    for j = 1:length(MR_key)
        active = g_key(i) == g & MR_key(j) == MR;
        clear frameNum
        for k = find(active)
            tmp = T1_count{k};
            frameNum(k) = length(tmp);
        end
        T1_count_mat = nan(max(frameNum), sum(active));
        k_count = 1;
        for k = find(active)'
            tmp = T1_count{k};
            T1_count_mat(1:length(tmp), k_count) = tmp;
            k_count = k_count + 1;
        end
        N(i,j) = k_count;
        meanProfile{i,j} = nanmean(T1_count_mat, 2);
    end
end

colors = {'k', 'r', 'g', 'b', 'm', 'c'};

for i = 1:size(meanProfile,1)
    plot(cumsum(meanProfile{i,1}), ['--' colors{i}]);
    hold on
    plot(cumsum(meanProfile{i,2}), ['-' colors{i}]);
end

legendmat = {};
for i = 1:length(g_key)
    legendmat{end+1} = ['g_a_v_e = ' num2str(g_key(i)), ' no MR'];
    legendmat{end+1} = ['g_a_v_e = ' num2str(g_key(i))];
end

legend(legendmat)
xlim([10, inf])

set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')

xlabel('Time (0.01 hours)')
ylabel('Cummulitive number of T1 transitions')

