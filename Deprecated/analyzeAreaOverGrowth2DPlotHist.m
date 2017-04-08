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


for i = 1:6
    
    inputFileLocation = [initialInputDir labels{i}];
    
    t = 480;
    m = 1;
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
        
        matrixOfStringArrays = cellfun(@(x) strrep(x,')',''),{cellData.CellCenter},'UniformOutput',false);
        matrixOfStringArrays = cellfun(@(x) strrep(x,'(',''),matrixOfStringArrays,'UniformOutput',false);
        matrixOfStringArrays = cellfun(@(x) strrep(x,',',' '),matrixOfStringArrays,'UniformOutput',false);
        cellsToDelete = cellfun('isempty', matrixOfStringArrays);
        matrixOfStringArrays(cellsToDelete) = [];
        areaTemp(cellsToDelete) = [];
        growthTemp(cellsToDelete) = [];
        [cellNumber] = length(growthTemp);
        
        areaOverGrowthTemp = areaTemp ./ (growthTemp + 1);
        
        strcatmat = strjoin(matrixOfStringArrays,' ');
        numbermatrix = sscanf(strcatmat,'%f');
        tempnumbermat = reshape(numbermatrix, [3, cellNumber]);
        
        cellxs = squeeze(tempnumbermat(1, :));
        cellys = squeeze(tempnumbermat(2, :));
        
        xs = cellxs - 25;
        ys = cellys - 25;
        rTemp = (xs.^2 + ys.^2).^0.5;
        rRounded = round(rTemp*scalingFactor,1)/scalingFactor;
        
        activeTemp = growthTemp < 0.90 & growthTemp > 0.05;
        rRounded(~activeTemp) = [];
        areaTemp(~activeTemp) = [];
        
        rs = unique(rRounded);
        
        j = 1;
        clear position meanArea stdArea
        for r = rs
            position(j) = r;
            meanArea(j) = mean(areaTemp(rRounded==r));
            stdArea(j) = std(areaTemp(rRounded==r));
            j = j + 1;
        end
        
        
        hold on
        shadedErrorBar(position, meanArea, stdArea, colors{m});
        axis([0, 25, 0, 1.2]);
        
        drawnow;
        t
        m = m + 1;
        t = t + 120;
        if t > 2000
            break
        end
    end
    print(['Figure7_' num2str(i) '.png'],'-dpng','-r1200')
    close all
end