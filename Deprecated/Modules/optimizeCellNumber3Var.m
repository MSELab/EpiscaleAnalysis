function tempSSR = optimizeCellNumber3Var( g_0_min, g_0_max, k )
runs = 15;
SSR = 0;
for run = 1:runs
    tempSSR = 0;
    fExperimental = @(t) 20*exp(6*(1-exp(-0.03*(t-30))));
    
    cellNumber = simulateCellNumber([g_0_min g_0_max], ...
        7, 20000, 1000, k, 5000);
    times = 0:1000:20000;
    [xAdd, xMult] = rescaleX(fExperimental, times(1:length(cellNumber)), cellNumber);
    
    simulationTime = (times(1:length(cellNumber))+xAdd)*xMult;
    cellNumber(simulationTime>110) = [];
    cellNumber(simulationTime<30) = [];
    simulationTime(simulationTime>110) = [];
    simulationTime(simulationTime<30) = [];
    
    startTime = min(simulationTime);
    endTime = max(simulationTime);
    
    tempSSR = tempSSR + mean((fExperimental(simulationTime) - cellNumber).^2);
    lostTime = 0;
    if endTime < 110
        lostTime = (110 - endTime);
    end
    if startTime > 30
        lostTime = lostTime + (startTime - 30);
    end
    
    tempSSR = tempSSR + ((80-lostTime)/80)*1e10;
    SSR = SSR + tempSSR;
end

end

