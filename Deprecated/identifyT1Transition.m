
close all
clear all

initialInputDir = 'G:\ESEM Paper\ESEM simulationDatafiles\detailedStat_';
labels = { ...
     'Growth_0.5to2.5_1_' ...
    ,'Growth_0.5to2.5_2_' ...
    ,'Growth_0.5to2.5_3_' ...
    ,'Growth_1to3_1_' ...
    ,'Growth_1to3_2_' ...
    ,'Growth_1to3_3_' ...
    ,'Growth_1to3_4_' ...
    ,'Growth_1to3_5_' ...
    ,'Growth_1to3_6_' ...
    ,'Growth_1.5to3.5_1_' ...
    ,'Growth_1.5to3.5_2_' ...
    ,'Growth_1.5to3.5_3_' ...
    ,'Growth_2to4_1_' ...
    ,'Growth_2to4_2_' ...
    ,'Growth_2to4_3_' ...
    ,'Growth_2to4_4_' ...
    ,'Growth_2to4_5_' ...
    ,'Growth_2to4_6_' ...
    ,'Growth_2to4_7_' ...
    ,'Growth_2to4_8_' ...
    ,'Growth_2to4_9_' ...
    ,'Growth_3to5_1_' ...
    ,'Growth_3to5_2_' ...
    ,'Growth_3to5_3_' ...
    ,'Growth_3to5_4_' ...
    ,'Growth_4to6_1_' ...
    ,'Growth_5to7_1_' ...
    }';

warning ('off','all');

t = 1;
for i = 1:1:length(labels)
    
    
    
    m = 1;
    inputFileLocation = [initialInputDir labels{i}];

    cellNumber = 0;
    while(exist([inputFileLocation num2str(t, '%05d') '.txt'],'file'))
        
        inputDir = [inputFileLocation num2str(t, '%05d') '.txt'];
        data = importdata(inputDir);
        if isempty(data)
            break
        end
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
        
        cellNumberMatrix(i,t) = cellRank;
        
        growthProgress = str2double({cellData.GrowthProgress});
        edgeCell = str2double({cellData.IsBoundrayCell});
        cellArea = str2double({cellData.CellArea});
        cellPos = str2double({cellData.CellCenter});
        
        strTemp = {cellData.NeighborCells};
        emptyIndices = cellfun(@(x) isempty(x), strTemp);
        for kk = find(emptyIndices)
            strTemp{kk} = '0';
        end
        strTemp = strrep(strTemp,'}','');
        strTemp = strrep(strTemp,'{','');
        
        newCellNumber = length(cellData);
        newAdjacencyMatrix = zeros(length(cellData));
        for activeCell = 1:newCellNumber
            neighbortemp = sscanf(strTemp{activeCell}, '%i')' + 1;
            for j = neighbortemp
                newAdjacencyMatrix(activeCell, j) = true;
            end
        end
        
        if cellNumber > 0
            
            neighborChanges = adjacencyMatrix(1:cellNumber,1:cellNumber) - newAdjacencyMatrix(1:cellNumber,1:cellNumber);
            [is, js] = find(neighborChanges < 0);
            
            T1 = 0;
            
            for n = 1:length(is)
                x = is(n);
                y = js(n);
                area = [];
                position = {};
                if ~isnan(edgeCell(x)) && ~isnan(edgeCell(y)) && ...
                    ~edgeCell(x) && ~edgeCell(y) &&  x < y && ...
                        growthProgress(x) < 0.91 && growthProgress(y) < 0.91 && ...
                        growthProgress(x) > 0.03 && growthProgress(y) > 0.03 && ...
                        trackedCells(x) <= 0 && trackedCells(y) <= 0 
                    T1 = T1 + 1;
                    area = [area cellArea(x) cellArea(y)];
                    position = {position cellPos(x) cellPos(y)};
                    trackedCells(x) = 10;
                    trackedCells(y) = 10;
                end
                
            end
            T1s(i,t) = T1;
            if T1 > 0
                areaMat{i,t} = area;
                positions{i,t} = position;
            end
        end
        
        if cellNumber < newCellNumber
            trackedCells(newCellNumber) = 0;
        end
        trackedCells = trackedCells - 1;
        cellNumber = newCellNumber;
        adjacencyMatrix = newAdjacencyMatrix;
        N (i,t) = 1;
        t = t + 1;
        disp(['Simulation: ' num2str(i) ' of ' num2str(length(labels)) ' time = ' num2str(t)])
    end
    t = 1;
end

save('T1TransitionsNewAlgorithm','T1s','N','areaMat','positions','cellNumberMatrix');