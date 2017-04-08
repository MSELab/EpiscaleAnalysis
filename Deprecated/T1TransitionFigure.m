
close all
clear all

catNum = 0;


initialInputDir = 'F:\Wenzhao Data (T1)\ESEM simulationDatafiles\';

labels =  dir(initialInputDir);
labels = [{labels.name}];
dataFiles = cellfun(@(str) strfind(str, '_00000.txt'), labels,'UniformOutput',false);
dataFiles = cellfun(@(cell) isempty(cell), dataFiles, 'UniformOutput',false);
labels(cell2mat(dataFiles)) = [];
labels = unique(labels')';

categories = {'0.5to2.5','1to3','1.5to3.5','2to4'};

totalSimulations = 0;

for category = categories
    releventIndices = find(~cellfun(@isempty,strfind(labels,category)));
    totalSimulations = totalSimulations + length(releventIndices);
end    

currentRun = 1;

for category = categories
    catNum = catNum + 1;
    releventIndices = find(~cellfun(@isempty,strfind(labels,category)));
    
    warning ('off','all');
    
    t = 1;
    repNum = 0;
    for i = releventIndices
        repNum = repNum + 1;
        m = 1;
        inputFileLocation = [initialInputDir labels{i}];
        tempInput = [inputFileLocation(1:end-9) sprintf('%05d',t) '.txt'];
        
        cellNumber = 0;
        while(exist(tempInput,'file'))
            
            inputDir = tempInput;
            data = importdata(inputDir);
            if isempty(data) || t > 2000
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
            
            cellNumberMatrix(t) = cellRank;
            
            growthProgress = str2double({cellData.GrowthProgress});
            edgeCell = str2double({cellData.IsBoundrayCell});
            cellArea = str2double({cellData.CellArea});
            cellPos = {cellData.CellCenter};
            
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
                
                cellNumber = min([cellNumber newCellNumber]);
                
                neighborChanges = newAdjacencyMatrix(1:cellNumber,1:cellNumber) - adjacencyMatrix(1:cellNumber,1:cellNumber);
                % is and js are cells which gained a neighbor
                [is, js] = find(neighborChanges > 0);
                
                T1 = 0;
                position = {};
                
                for n = 1:length(is)
                    x = is(n);
                    y = js(n);
                    area = [];
                    
                    if ~isnan(edgeCell(x)) && ~isnan(edgeCell(y)) && ...
                            ~edgeCell(x) && ~edgeCell(y) &&  x < y && ...
                            growthProgress(x) < 0.91 && growthProgress(y) < 0.92 && ...
                            growthProgress(x) > 0.03 && growthProgress(y) > 0.03 && ...
                            trackedCells(x) <= 0 && trackedCells(y) <= 0
                        T1 = T1 + 1;
                        area = [area cellArea(x) cellArea(y)];
                        position = [position cellPos(x) cellPos(y)];
                        trackedCells(x) = 10;
                        trackedCells(y) = 10;
                    end
                    
                end
                T1s(t) = T1;
                if T1 > 0
                    areaMat{t} = area;
                    
                end
                
                positions{t} = position;
            end
            
            if cellNumber < newCellNumber
                trackedCells(newCellNumber) = 3;
                for newCell = (cellNumber + 1):newCellNumber
                    divisionPositions{t,newCell} = cellPos(newCell);
                end
            end
            trackedCells = trackedCells - 1;
            cellNumber = newCellNumber;
            adjacencyMatrix = newAdjacencyMatrix;
            N (t) = 1;
            t = t + 1;
            disp([category{1} ': ' num2str(currentRun) ' of ' num2str(totalSimulations) ' time = ' num2str(t)])
            tempInput = [inputFileLocation(1:end-9) sprintf('%05d',t) '.txt'];
            
        end
        
        T1TransitionsPer100Divisions{catNum, repNum} = sum(T1s) ./ (cellNumber - 7)
        timesteps{catNum, repNum} = t  
        
        t = 1;
    
    currentRun = currentRun + 1;
    end
    
    
end
