% Track cells to find (for each cell) area before, during, and
% after mitosis.
function [savedAreaIFM, time] = trackCells(cellArea, growthProgress)
m = 1; t = 1; trackedCells = 0;

for t = 1:length(cellArea)
    areaTemp = cellArea{t};
    growthTemp = growthProgress{t};
    
    if trackedCells == 0
        clear cellStatus
        cellStatus(growthTemp < 0.05) = 1;
        cellStatus(growthTemp > 0.05 & growthTemp < 0.91) = 2;
        cellStatus(growthTemp > 0.91) = 3;
        trackingNumbers = 1:length(growthTemp);
        trackedCells = length(growthTemp);
        currentlyDividingCells = growthTemp > 0.91;
        trackedArea = areaTemp;
    else
         
        % Figure out which cells are transitioning
        currentlyDividingCells = growthTemp > 0.91;
        currentlyUnstableCells = growthTemp < 0.05;
        
        measureInitialInterphaseArea = (cellStatus == 1) & ~currentlyUnstableCells(1:length(cellStatus));
        measureFinalInterphaseArea = (cellStatus == 2) & currentlyDividingCells(1:length(cellStatus));
        measureMitoticArea = (cellStatus == 3) & ~currentlyDividingCells(1:length(cellStatus));
        
        for m = find(measureInitialInterphaseArea)
            savedAreaIFM(trackingNumbers(m),1) = trackedArea(m);
            time(trackingNumbers(m),1) = t - 1;
        end
        
        for m = find(measureFinalInterphaseArea)
            savedAreaIFM(trackingNumbers(m),2) = trackedArea(m);
            time(trackingNumbers(m),2) = t - 1;
        end
        
        for m = find(measureMitoticArea)
            savedAreaIFM(trackingNumbers(m),3) = trackedArea(m);
            trackingNumbers(m) = trackedCells + 1;
            trackedCells = trackedCells + 1;
            time(trackingNumbers(m),3) = t - 1;
        end
        
        for m = (length(cellStatus)+1):length(growthTemp)
            trackingNumbers(m) = trackedCells + 1;
            trackedCells = trackedCells + 1;
        end
        
        cellStatus(growthTemp < 0.05) = 1;
        cellStatus(growthTemp > 0.05 & growthTemp < 0.91) = 2;
        cellStatus(growthTemp > 0.91) = 3;
        
        trackedArea = areaTemp;

    end
end

savedAreaIFM(savedAreaIFM==0) = NaN;