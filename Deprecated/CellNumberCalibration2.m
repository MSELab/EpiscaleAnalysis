% clear all
% close all
% 
% %% Declaration
% searchTerms = {'Growth_0.5to2.5','Growth_1to3','Growth_1.5to3.5','Growth_2to4'};
% %  searchTerms = {'g0'};
%           
% binSize = 50;
% mitoticCutoff = 0.92;
% 
% % Input parameters used in simulation
% ProlifDecayCoeff = 4.0e-4;
% RandomGrowthSpeedMin = 2e-3;
% RandomGrowthSpeedMax = 4e-3;
% simulationTimePerOutput = 10000 / 2000;
% 
% %% Initialization
% settings = prepareWorkspace();
% [labels, labelIndices] = getLabels(settings, searchTerms, 3);
% mitoticCellNumber = nan(4000, length(labels));
% allCellNumber = nan(4000, length(labels));
% mitoticFrequency = nan(4000, length(labels));
% percentCellsDivided = nan(55, length(labels));
% simulationTimestep = 100 / 2000; %100 hours per 2000 outputs
% 
% %% Input experimental data
% % Extracted from Wartlick, O., Mumcu, P., Kicheva, A., Bittig, T., Seum, 
% % C., Jülicher, F. & González-Gaitán, M. 2011 Dynamics of Dpp Signaling and 
% % Proliferation Control. Science 331, 1154–1159. (doi:10.1126/science.1200037)
% %
% % N(t) = a*t^b; fit good for t = 30 AEL to 150 AEL
% aFitNt = 1.43432376615343e-06;
% bFitNt = 4.78333850746379;
% tFitNt = [30 150];
% 
% %% Data Extraction
% for j = length(labels):-1:1
%     disp(['Analyzing: ' labels{j}])
%     load([settings.matDir labels{j} '.mat'], 'growthProgress');
%     for t = length(growthProgress):-1:1
%         growth = growthProgress{t};
%         mitoticCellNumber(t, j) = sum(growth > mitoticCutoff);
%         allCellNumber(t, j) = length(growth);
%         mitoticFrequency(t, j) = mitoticCellNumber(t, j) / allCellNumber(t, j) * 100;
%     end
%     tBin = 1;
%     for t = 1:binSize:(length(growthProgress) - binSize)
%         cellsDivided = allCellNumber(t + binSize, j) - allCellNumber(t, j);
%         percentCellsDivided(tBin, j) = cellsDivided / allCellNumber(t, j) * 100;
%         tBin = tBin + 1;
%     end
% end
% 
% %% Compare simulation cell number to experimental data
% % Interpolate experimental cell numbers
% tHours = tFitNt(1):tFitNt(2);
% cellNumberExpt = aFitNt .* tHours .^ bFitNt;
%     
% % Process cell number data
% meanCellNumber = nanmean(allCellNumber(:, labelIndices == 4), 2);
% stdCellNumber = nanstd(allCellNumber(:, labelIndices == 4), 1, 2);
% meanCellNumber(isnan(meanCellNumber)) = [];
% stdCellNumber(isnan(stdCellNumber)) = [];
% tSimulationSteps = 0:simulationTimePerOutput:((length(meanCellNumber)+3)*simulationTimePerOutput);
% 
% %% Make test plot for raw data
% % close all
% % subplot(2,1,1)
% % plot(tHours, cellNumberExpt);
% % title('Experimental')
% % xlabel('Time (hours)')
% % ylabel('Cell Number')
% % subplot(2,1,2)
% % plot(tSimulationSteps, meanCellNumber);
% % title('Simulation')
% % xlabel('Time (AU)')
% % ylabel('Cell Number')
% % 
% % %% Make test plot for rescaled data
% % % Experimental
% % close all
% % subplot(2,1,1)
% % plot(tHours, cellNumberExpt);
% % title('Experimental')
% % xlabel('Time (hours)')
% % ylabel('Cell Number')
% % axis([tFitNt -inf inf]);
% % 
% % % Rescaled simulation
% % subplot(2,1,2)
% % 
% % aRescale = 0.012309;
% % bRescale = 60.053329;
% % 
% % tRescaled = aRescale * tSimulationSteps + bRescale;
% % 
% % plot(tRescaled, meanCellNumber);
% % title('Simulation')
% % xlabel('Time (AU)')
% % ylabel('Cell Number')
% % axis([tFitNt -inf inf]);

clear all
close all

dt = 1e-2;
g_min_0 = 2e-3; %1/s
g_max_0 = 4e-3; %1/s
k_g = 4e-4 %1/s
N0 = 7;
t = 0:dt:120;
maxCell = 5000;
numRuns = 5;

g_min = g_min_0*exp(-k_g*t*3600);
g_max = g_max_0*exp(-k_g*t*3600);

N_saved = nan(numRuns, length(t));

for j = 1:numRuns
    j
    CP = nan(maxCell, length(t));
    CP(1:N0,1) = 0;
    g = nan(maxCell, length(t));
    g(1:N0,:) = repmat((rand(N0,1) * (g_max(1) - g_min(1))) + g_min(1),[1,size(g,2)]);
    N = nan(1, length(t));
    N(1) = 7;
    
    for i = 1:length(t)
        CP(:,i+1) = CP(:,i) + g(:,i) * (dt*3600);
        mitotic = find(CP(:,i+1) >= 1);
        mitotic = [mitotic', (N+1):(N+length(mitotic))];
        CP(mitotic,i+1) = 0;
        g(mitotic,(i+1):end) = repmat((rand(length(mitotic),1) * (g_max(i) - g_min(i))) + g_min(i),[1,size(g,2)-i]);
        N(i+1) = N(i) + length(mitotic/2);
    end
    N(end) = [];
    N_saved(j, :) = N;
end

plot(t, N_saved')

% aveN = nanmean(N_saved, 1);
% stdN = nanstd(N_saved, [], 1);
% plot(t,aveN)

return
%% Look at exponential fit to all experimental datasets
close all

tSimulationTime = 0:5:20000;
ProlifDecayCoeff = [4.0e-4, 4.0e-4, 4.0e-4, 4.0e-4];
RandomGrowthSpeedMin = [0.5e-3, 1e-3, 1.5e-3, 2e-3];
RandomGrowthSpeedMax = [2.5e-3, 3e-3, 3.5e-3, 4e-3];
simulationTimePerOutput = 10000 / 2000;
g0 = mean([RandomGrowthSpeedMin; RandomGrowthSpeedMax], 1);
k = ProlifDecayCoeff;



for m = 1:4
g{m} = g0(m).*exp(-k(m).*tSimulationTime);
% dN/dT = N * g(t) where g(t) = g0 * exp(-k*t)
% By integration, form of N is: N = a*exp(-b*exp(-c*t)))

end

for m = unique(labelIndices)
    meanCellNumber = nanmean(allCellNumber(:, labelIndices == m), 2);
    meanCellNumber(isnan(meanCellNumber)) = [];
    tSimulationSteps = 0:simulationTimePerOutput:((length(meanCellNumber)+3)*simulationTimePerOutput);
    tSimulationSteps = tSimulationSteps(1:length(meanCellNumber));
    
    subplot(2,3,1)
    hold on
    plot(tSimulationSteps, meanCellNumber);
    title('Simulation cell number')
    
    subplot(2,3,2)
    hold on
    plot(tSimulationTime(1:length(g{m})), g{m});
    title('Predicted simulation growth')
    
    subplot(2,3,3)
    hold on
    N(1) = 7;
    gTemp = g{m};
    for i = 2:length(g{m})
        N(i) = N(i-1) * (1 + gTemp(i));
    end
    plot(tSimulationTime(1:length(N)), N);
    title('Predicted cell number')
    
    
end

subplot(2,3,4)
plot(tHours, cellNumberExpt);
title('Experimental cell number')

subplot(2,3,5)
gExpt = gradient(cellNumberExpt) ./ cellNumberExpt;
plot(tHours, gExpt);
title('Back-calculated g')

%% Predicting cell number from g_0 and k for 2to4 simulation
close all

ProlifDecayCoeff = [4.0e-4, 4.0e-4, 4.0e-4, 4.0e-4];
RandomGrowthSpeedMin = [0.5e-3, 1e-3, 1.5e-3, 2e-3];
RandomGrowthSpeedMax = [2.5e-3, 3e-3, 3.5e-3, 4e-3];
g0act = mean([RandomGrowthSpeedMin; RandomGrowthSpeedMax], 1);
kact = ProlifDecayCoeff;

% If number of cells is N = a*exp(-b*exp(-c*t))) with t in units of 
% simulation time, then the simulations are fit by the 
% following parameters:

aSim = [223.9385916, 815.658292, 1674.299237, 4259.880577];
bSim = [3.243907417, 3.860059577, 4.844155413, 5.358800968];
cSim = [0.000259979, 0.000201818, 0.000260749, 0.000258939];

aExpt = 1399486.571;
bExpt = 13.14724181;
cExpt = 0.008558258;

close all
subplot(1,2,1)
for m = 1:4
    t = tSimulationTime(1:length(g{m}));
    plot(t, aSim(m).*exp(-bSim(m).*exp(-cSim(m).*t)));
    hold on
end

xlabel('Time (arbitrary)');
ylabel('Cell Number');
title('Simulation');

subplot(1,2,2)
t = 30:0.1:150;
plot(t, aExpt.*exp(-bExpt.*exp(-cExpt.*t)));
    
xlabel('Time (hours)');
ylabel('Cell Number');
title('Experimental');
axis([30, 150, 0, 4e4])

%% ARCHIVE

% c1 = a;
% g_0 = c.*b;
% k = c;
% 
% close all
% subplot(3,2,1)
% plot(c1)
% subplot(3,2,3)
% plot(g_0)
% subplot(3,2,5)
% plot(k)
% subplot(3,2,2)
% 
% subplot(3,2,4)
% plot(g_0./g0act)
% subplot(3,2,6)
% plot(k./kact)

% % Round 2: if g_0 and k are related to input values
% cNew = mean(k./kact) .* kact;
% bNew = (mean(g_0./g0act) .* g0act) ./ c;
% % Fit for a
% aNew = [215.9950538, 763.1530329, 1674.299237, 4615.665881];
% 
% % t = (0:10:10000);
% % NsimulationPredicted = a.*exp(-b.*exp(-c.*t));
% % plot(t, NsimulationPredicted);



