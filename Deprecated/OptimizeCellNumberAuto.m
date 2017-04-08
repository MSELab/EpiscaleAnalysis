clearvars
close all
% parpool('local')

%% Declaration
RandomGrowthSpeedMin = 2e-3;
RandomGrowthSpeedMax = 4e-3;
initialCellNumber = 7;
timeTotal = 20000;
timeStep = 1;
ProlifDecayCoeff = 4.0e-4;
replicates = 20;
growthConditions = {[2e-3 4e-3]}; %{[0.5e-3 2.5e-3], [1e-3 3e-3], [1.5e-3 3.5e-3], [2e-3 4e-3]};
maxCells = 7000;

%% Initialization
settings = prepareWorkspace();

%% Optimization
close all

fSSR = @(x) optimizeCellNumber(x(1), x(2));

opts = optimoptions(@fmincon,'Display','final','UseParallel',true);
problem = createOptimProblem('fmincon','objective',...
 fSSR,'x0',[1.3e-3, 2.14e-4],'lb',[1e-3, 1e-4],'ub',[5e-3, 1e-3],'options',opts);
ms = MultiStart;
[x,fval,exitflag,output,solutions] = run(ms,problem,replicates);

g_0_min = x(1)
g_0_max = x(1) * 2
k = x(2)

% [xq,yq] = meshgrid(-2:.2:2, -2:.2:2);
% vq = griddata(x,y,v,xq,yq);

%% Output
% g_0_min = .0045;
% g_0_max = .0089;
% k = 1.5554e-4;
% optimizeCellNumber3Var(g_0_min, g_0_max, k)

% g_0_min = .0046;
% g_0_max = .0092;
% k = 1.0166e-04;
% optimizeCellNumber3Var(g_0_min, g_0_max, k)
% 
% g_0_min = 8.45e-4;
% g_0_max = 3.1e-3;
% k = 2.14e-4;
% optimizeCellNumber3Var(g_0_min, g_0_max, k)
% 
g_0_min = 1.3e-3;
g_0_max = g_0_min*2;
k = 2.14e-4;
optimizeCellNumber3Var(g_0_min, g_0_max, k)

tExpt = (0:80) + 30;
tSim = 0:timeStep:timeTotal;
fExperimental = @(t) 20*exp(6*(1-exp(-0.03*(t-30))));

simulatedOutput = simulateCellNumber([g_0_min g_0_max], initialCellNumber, timeTotal, timeStep, k, maxCells);
[xAdd, xMult] = rescaleX(fExperimental, tSim(1:length(simulatedOutput)), simulatedOutput);
plot(tExpt, fExperimental(tExpt), (tSim(1:length(simulatedOutput))+xAdd)*xMult, simulatedOutput);
axis([30, 110, 0, 5000]);

xlabel('Time (hours)')
ylabel('Cell number')
legend({'Experimental', 'Computational'})
