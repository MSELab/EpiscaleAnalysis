settings = prepareWorkspace();

settings.firstDivision = 10;
settings.lastDivision = 300;
settings.cellRadius = 60;
settings.minCellsToCount = 1;

[g_ave, MR, measurements] = summarizeT1Frequency(settings);

save('SummaryT1.mat','g_ave','MR','measurements','settings')

return
firstDiv = [0, 10, 30];
lastDiv = [60, 100, 250, 500];
cellRadius = [10, 25, 50, 100];
minCells = 1:4;

for i = 1:length(firstDiv)
    for j = 1:length(lastDiv)
        for k = 1:length(cellRadius)
            for m = 1:length(minCells)
                [i, j, k, m]
                
                settings.firstDivision = firstDiv(i);
                settings.lastDivision = lastDiv(j);
                settings.cellRadius = cellRadius(k);
                settings.minCellsToCount = minCells(m);
                
                [g_ave, MR, measurements] = summarizeT1Frequency(settings);
                
                R2(i,j,k,m) = mean([measurements.R2]);
                N(i,j,k,m) = length(measurements);
                err_ratio(i,j,k,m) = mean([measurements.err_ratio]);
                
                minR2(i,j,k,m) = min([measurements.R2]);
                minerr_ratio(i,j,k,m) = min([measurements.err_ratio]);
            end
        end
    end
end

save('AnalysisParameterSweep.mat')

%%
score = minR2(:) + R2(:) + minerr_ratio(:)/max(minerr_ratio(:)) + err_ratio(:)/max(err_ratio(:));
first1 = first(:);
last1 = last(:);
rad1 = rad(:);
mincell1 = mincell(:);

first1 = first1(score > 0);
last1 = last1(score > 0);
rad1 = rad1(score > 0);
mincell1 = mincell1(score > 0);
score1 = score(score > 0);

fitlm(array2table([first1, last1, rad1, mincell1, score1]),'linear')


