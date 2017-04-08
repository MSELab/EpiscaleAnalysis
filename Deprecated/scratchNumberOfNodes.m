clearvars
close all

%% Declaration
searchTerms = {'Control_0.55_to_1.11','N0'};
           
dtds = 100 / 2000; %100 hours per 2000 outputs

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);

memNodesMax = nan(4000, length(labels));
intNodesMax = nan(4000, length(labels));

%% Data Extraction
for j = length(labels):-1:1
    disp(['Analyzing: ' labels{j}])
    load([settings.matDir labels{j} '.mat'], 'memNodes', 'intNodes');
    for t = length(memNodes):-1:1
        mem = memNodes{t};
        int = intNodes{t};
        memNodesMax(t, j) = max(mem);
        intNodesMax(t, j) = max(int);
    end
end

%% Plot test graphs
close all
figure(1)
t = ((1:size(memNodesMax, 1)))*dtds;
plot(t, memNodesMax)
xlabel('Time (hr)')
ylabel('Membrane Nodes in Largest Cell')
legend({'run 1', 'run 2', 'run 3', 'run 4'})

figure(2)
plot(t, intNodesMax)
xlabel('Time (hr)')
ylabel('Internal Nodes in Largest Cell')
legend({'run 1', 'run 2', 'run 3', 'run 4'})