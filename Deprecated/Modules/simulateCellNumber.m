function cellsOverTime = simulateCellNumber(g0, n0, timeTotal, timeStep, k, maxCells)

%% Initialization
g0_min = g0(1);
g0_max = g0(2);
cellsOverTime = nan(1, round(timeTotal/timeStep));
growthProgress = zeros(1, n0);
growthRate = nan(1, n0);
timeIndex = 1;

%% Simulation loop
for t = 0:timeStep:timeTotal
    % Assign growth rates to new cells
    randomNumbers = rand(1, sum(isnan(growthRate)));
    g_0 = randomNumbers * (g0_max - g0_min) + g0_min;
    growthRate(isnan(growthRate)) = g_0 * exp(-k * t);
    
    % Perform simulation
    growthProgress = growthProgress + growthRate * timeStep;
    dividingCells = growthProgress > 1;
    growthProgress(dividingCells) = 0;
    growthRate(dividingCells) = nan;
    growthProgress = [growthProgress zeros(1,sum(dividingCells))];
    growthRate = [growthRate nan(1,sum(dividingCells))];
    cellsOverTime(timeIndex) = length(growthRate);
    timeIndex = timeIndex + 1;
    
    if length(growthRate) > maxCells
        
        return
    end
end