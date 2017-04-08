clear all
close all

scalingFactor = 0.25;

initialInputDir = 'G:\ESEM Paper\ESEM simulationDatafiles\detailedStat_';
labels = { ...
    'Growth_2to4_1_' ...
    ,'Growth_2to4_2_' ...
    ,'Growth_2to4_3_' ...
    ,'Growth_2to4_4_' ...
    ,'Growth_2to4_5_' ...
    ,'Growth_2to4_6_' ...
    }';

warning ('off','all');

colors = {'k','m','b','r','c'};


for i = 1
    m = 1;
    inputFileLocation = [initialInputDir labels{i}];
    
    t = 1;
    
    trackedCells = 0;
    
    while(exist([inputFileLocation num2str(t, '%05d') '.txt'],'file'))
        
        clear areaTemp growthTemp rTemp
        
        inputDir = [inputFileLocation num2str(t, '%05d') '.txt'];
        data = importdata(inputDir);
        cellRank = 0;
        
        clear cellData
        
        for j = 1:length(data)
            tempString = data{j};
            if ~isempty(tempString)
                colon = strfind(tempString, ':');
                field = strtrim(tempString(1:(colon-1)));
                values = tempString((colon+1):end);
                if strcmp(field, 'CellRank')
                    cellRank = str2num(values) + 1;
                else
                    cellData(cellRank).(field) = values;
                end
            end
        end
        
        areaTemp = str2double({cellData.CellArea});
        growthTemp = str2double({cellData.GrowthProgress});
        
        if trackedCells == 0
            cellStatus(growthTemp < 0.05) = 1;
            cellStatus(growthTemp > 0.05 & growthTemp < 0.91) = 2;
            cellStatus(growthTemp > 0.91) = 3;
            trackingNumbers = 1:length(growthTemp);
            trackedCells = length(growthTemp);
        else
            % Figure out which cells are transitioning
            currentlyDividingCells = growthTemp > 0.91;
            currentlyUnstableCells = growthTemp < 0.05;
            
            measureInitialInterphaseArea = (cellStatus == 1) & ~currentlyUnstableCells(1:length(cellStatus));
            measureFinalInterphaseArea = (cellStatus == 2) & currentlyDividingCells(1:length(cellStatus));
            measureMitoticArea = (cellStatus == 3) & ~currentlyDividingCells(1:length(cellStatus));
            
            for m = find(measureInitialInterphaseArea)
                savedAreaIFM(trackingNumbers(m),1) = trackedArea(m);
            end
            
            for m = find(measureFinalInterphaseArea)
                savedAreaIFM(trackingNumbers(m),2) = trackedArea(m);
            end
            
            for m = find(measureMitoticArea)
                savedAreaIFM(trackingNumbers(m),3) = trackedArea(m);
                trackingNumbers(m) = trackedCells + 1;
                trackedCells = trackedCells + 1;
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
        
        t
        t = t + 1;
    end
    
    savedAreaIFM(savedAreaIFM==0) = NaN;
    
end