clearvars
close all

%% Declaration
RandomGrowthSpeedMin = 2e-3;
RandomGrowthSpeedMax = 4e-3;
initialCellNumber = 7;
timeTotal = 20000;
timeStep = 1;
ProlifDecayCoeff = 2.14e-4;
replicates = 500;
growthConditions = {[1.3e-3 2.6e-3]}; %{[0.5e-3 2.5e-3], [1e-3 3e-3], [1.5e-3 3.5e-3], [2e-3 4e-3]};

% Experimental Data: "From genes to organisms: Bioinformatics system models and software." PhD diss., EPFL, 2014.
exptAreaT = [78, 90, 99, 110]; % [hours after fertilization]
exptArea = [1.02, 1.95, 2.8, 4.7]; % [um^2]
exptN = [.17, 1.05, 1.71];
exptNT = [73, 96, 114];

%% Initialization
settings = prepareWorkspace();
cellNumber = nan(replicates, length(growthConditions), round(timeTotal/timeStep) + 1);
growth = 1;

%% Simulate growth
for g0 = growthConditions
    for rep = 1:replicates
        disp(['Starting simulation #' num2str(rep)]);
        cellNumbertemp = simulateCellNumber(g0{1}, ...
            initialCellNumber, timeTotal, timeStep, ProlifDecayCoeff, 7000);
        cellNumber(rep, growth, 1:length(cellNumbertemp)) = cellNumbertemp;
        cellNumber(rep, growth, (length(cellNumbertemp)+1):length(growthConditions)) = nan;
    end
    growth = growth + 1;
end
fExperimental = @(t) 20*exp(6*(1-exp(-0.03*(t-30))));

%% Calculate
aveCellNumber = squeeze(nanmean(cellNumber, 1));
stdCellNumber = squeeze(nanstd(cellNumber, 1));
tSim = 0:timeStep:timeTotal;
[xAdd, xMult] = rescaleX(fExperimental, tSim, aveCellNumber');
tSim = 0:timeStep:timeTotal;
tExpt = (tSim + xAdd) * xMult;
tExpt = tExpt(1:length(aveCellNumber));

%% Generate Figure
close all
hErrBars = mseb(tExpt,[fExperimental(tExpt)', aveCellNumber]',[stdCellNumber*1e-5, stdCellNumber]');
axis([30, 110, 0, 5000]);
legend({'Experimental','Simulation'},'location','northwest');
xlabel('Time (hours after egg laying)');
ylabel('Cell number');
set(gca,'fontsize',18)
set(gca,'Fontname','arial')

close all
plot(tExpt, squeeze(cellNumber)');
axis([30, 110, 0, 6000]);
