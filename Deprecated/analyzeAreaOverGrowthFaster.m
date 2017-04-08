clear all
close all

inputDir = 'G:\ESEM Paper\ESEM simulationDatafiles\detailedStat_';
labels = { ...
    'Growth_2to4_1_' ...
    ,'Growth_2to4_2_' ...
    ,'Growth_2to4_3_' ...
    ,'Growth_2to4_4_' ...
    ,'Growth_2to4_5_' ...
    ,'Growth_2to4_6_' ...
    }';

warning ('off','all');

for i = 1:6
    inputFileLocation = [inputDir labels{i}];
    
    t = 1;
    v = VideoWriter(['areaVideoOverGrowth_' num2str(i) '.avi']);
    open(v);
    while(exist([inputFileLocation num2str(t, '%05d') '.txt'],'file'))
        
        inputDir = [inputFileLocation num2str(t, '%05d') '.txt'];
        data = importdata(inputDir);
        cellRank = 0;
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
        
        matrixOfStringArrays = cellfun(@(x) strrep(x,')',''),{cellData.CellCenter},'UniformOutput',false);
        matrixOfStringArrays = cellfun(@(x) strrep(x,'(',''),matrixOfStringArrays,'UniformOutput',false);
        matrixOfStringArrays = cellfun(@(x) strrep(x,',',' '),matrixOfStringArrays,'UniformOutput',false);
        cellsToDelete = cellfun('isempty', matrixOfStringArrays);
        matrixOfStringArrays(cellsToDelete) = [];
        areaTemp(cellsToDelete) = [];
        growthTemp(cellsToDelete) = [];
        [cellNumber] = length(growthTemp);
        
        strcatmat = strjoin(matrixOfStringArrays,' ');
        numbermatrix = sscanf(strcatmat,'%f');
        tempnumbermat = reshape(numbermatrix, [3, cellNumber]);
        
        cellxs = squeeze(tempnumbermat(1, :));
        cellys = squeeze(tempnumbermat(2, :));
        
        xs = cellxs - 25;
        ys = cellys - 25;
        rTemp = (xs.^2 + ys.^2).^0.5;
        
        activeTemp = growthTemp < 0.90 & growthTemp > 0.05;
        clf
        scatter(rTemp(activeTemp), areaTemp(activeTemp)./(growthTemp(activeTemp)+1),16,'k','filled');
        axis([0, 25, 0, 0.7]);
        drawnow;
        t
        writeVideo(v,getframe(gcf))
        t = t + 25;
    end
    close(v)
end