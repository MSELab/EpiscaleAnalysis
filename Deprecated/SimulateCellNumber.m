clearvars
close all

%% Declaration
RandomGrowthSpeedMin = 2e-3;
RandomGrowthSpeedMax = 4e-3;
initialCellNumber = 7;
timeTotal = 20000;
timeStep = 1;
ProlifDecayCoeff = 4.0e-4;
replicates = 3;
growthConditions = {[0.5e-3 2.5e-3], [1e-3 3e-3], [1.5e-3 3.5e-3], [2e-3 4e-3]};

%% Initialization
settings = prepareWorkspace();
cellNumber = nan(replicates, length(growthConditions), round(timeTotal/timeStep) + 1);
growth = 1;

%% Simulate growth
for g0 = growthConditions
    for rep = 1:replicates
        disp(['Starting simulation #' num2str(rep)]);
        
        cellNumber(rep, growth, :) = simulateCellNumber(g0{1}, ...
            initialCellNumber, timeTotal, timeStep, ProlifDecayCoeff, replicates);
    end
    growth = growth + 1;
end
%% Output
aveCellNumber = squeeze(nanmean(cellNumber, 1));
stdCellNumber = squeeze(nanstd(cellNumber, 1));
hErrBars = mseb(0:timeStep:timeTotal,aveCellNumber,stdCellNumber);