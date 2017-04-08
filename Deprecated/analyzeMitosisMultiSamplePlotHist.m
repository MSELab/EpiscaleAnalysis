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
    ,'Growth_2to4_7_' ...
    ,'Growth_2to4_8_' ...
    ,'Growth_2to4_9_' ...
    }';

warning ('off','all');

colors = {'k','m','b','r','c','k','m','b','r','c'};

cellNumber = 0;

for i = 1:6
    
    inputFileLocation = [initialInputDir labels{i}];
    
    timePoint = 1;
    m = 1;
    t = 1;
    while(exist([inputFileLocation num2str(t, '%05d') '.txt'],'file'))
        
        if t > 2000
            break
        end
        
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
        % Extract positions
        matrixOfStringArrays = cellfun(@(x) strrep(x,')',''),{cellData.CellCenter},'UniformOutput',false);
        matrixOfStringArrays = cellfun(@(x) strrep(x,'(',''),matrixOfStringArrays,'UniformOutput',false);
        matrixOfStringArrays = cellfun(@(x) strrep(x,',',' '),matrixOfStringArrays,'UniformOutput',false);
        cellsToDelete = cellfun('isempty', matrixOfStringArrays);
        matrixOfStringArrays(cellsToDelete) = [];
        areaTemp(cellsToDelete) = [];
        growthTemp(cellsToDelete) = [];
        dividingCellsTemp = growthTemp > 0.91;
        newCellsTemp = (cellNumber+1):length(growthTemp);
        cellNumber = length(growthTemp);
        strcatmat = strjoin(matrixOfStringArrays,' ');
        numbermatrix = sscanf(strcatmat,'%f');
        tempnumbermat = reshape(numbermatrix, [3, cellNumber]);
        cellxs = squeeze(tempnumbermat(1, :));
        cellys = squeeze(tempnumbermat(2, :));
        xs = cellxs - 25;
        ys = cellys - 25;
        rTemp = (xs.^2 + ys.^2).^0.5;
        rTempNorm = rTemp ./ max(rTemp(:));
        
        activeTemp = growthTemp > -1;
        
        k = 1;
        for rBin = [0,0.2;0.2,0.3;0.3,0.4;0.4,0.5;0.5,0.6;0.6,0.7;0.7,0.8;0.8,0.9;0.9,1]'
            rposition(k) = mean(rBin);
            meandividingCells(i,k,m) = mean(dividingCellsTemp(rTempNorm>=rBin(1)&rTempNorm<rBin(2)));
            stddividingCells(i,k,m) = std(dividingCellsTemp(rTempNorm>=rBin(1)&rTempNorm<rBin(2)));
            k = k + 1;
        end
        
        cellDivisionLocations(i,newCellsTemp) = rTempNorm(newCellsTemp);
        cellDivisionLocations(i,newCellsTemp) = rTempNorm(newCellsTemp);
        
        [t i]
        m = m + 1;
        timePoint = timePoint + 1;
        t = t + 1;
    end
    cellDivisionLocations(i,(cellNumber+1):end)=nan;
end

stdArea2 = squeeze(nanstd(dividingCells,0,1));
meanArea = squeeze(nanmean(dividingCells,1));
current = figure;
for i = 1:4
    subplot(1,4,i)
    errorbar(rposition, meanArea(:,i), stdArea2(:,i))
    axis([0, 1, 1.5, 3.3]);
    xlabel('Relative distance');
    ylabel('Area (um^2)');
end

set(current, 'PaperUnits','inches','PaperPosition', [0, 0, 16, 2.7]);
%print(['Figure7HighRes.png'],'-dpng','-r1200')
