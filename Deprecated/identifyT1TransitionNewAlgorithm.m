
close all
clear all

initialInputDir = 'F:\Wenzhao Data (T1)\ESEM simulationDatafiles\';

labels =  dir(initialInputDir);
labels = [{labels.name}];
dataFiles = cellfun(@(str) strfind(str, '_00000.txt'), labels,'UniformOutput',false);
dataFiles = cellfun(@(cell) isempty(cell), dataFiles, 'UniformOutput',false);
labels(cell2mat(dataFiles)) = [];
labels = unique(labels')';

releventIndices = 1:length(labels); %
releventIndices = find(~cellfun(@isempty,strfind(labels,'GrowthConstant_0.5')));
releventIndices = [releventIndices find(~cellfun(@isempty,strfind(labels,'GrowthConstant_0.4')))];
labels = labels(releventIndices)';

warning ('off','all');

T1s = zeros(length(labels),2000);
N = zeros(length(labels),2000);
areaMat = cell(length(labels),2000);
positions = cell(length(labels),2000);
cellNumberMatrix = zeros(length(labels),2000);
divisionPositions = cell(length(labels),2000);
cellPolygonClassMatrix = zeros(length(labels),2000,1500);
cellNeighborMatrix = cell(length(labels),2000,1500);

t = 1;
for i = 1:length(labels)
    m = 1;
    inputFileLocation = [initialInputDir labels{i}];
    tempInput = [inputFileLocation(1:end-9) sprintf('%05d',t) '.txt'];
    
    cellNumber = 0;
    while(exist(tempInput,'file'))
        
        inputDir = tempInput;
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
        
        cellPos = {cellData.CellCenter};
        cellData(cellfun(@isempty,cellPos)) = [];
        cellPos(cellfun(@isempty,cellPos)) = [];
        cellNumberMatrix(i,t) = length(cellData);
        
        newCellNumber = length(cellData);
        
        if newCellNumber < cellNumber
            break
        end
        
        growthProgress = str2double({cellData.GrowthProgress});
        edgeCell = str2double({cellData.IsBoundrayCell});
        cellArea = str2double({cellData.CellArea});
        [rTemp, ~] = parseCellPositionString(cellPos);
        rMat{i,t} = rTemp;
        discSizeMat{i,t} = max(rTemp);
        
        newAdjacencyMatrix = makeAdjacencyMatrix({cellData.NeighborCells});
        
        if cellNumber > 0
            
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
                        growthProgress(x) < 0.91 && growthProgress(y) < 0.91 && ...
                        growthProgress(x) > 0.03 && growthProgress(y) > 0.03 && ...
                        trackedCells(x) <= 0 && trackedCells(y) <= 0 
                    T1 = T1 + 1;
                    area = [area cellArea(x) cellArea(y)];
                    position = [position rTemp(x) rTemp(y)];
                    trackedCells(x) = 10;
                    trackedCells(y) = 10;
                end
                
            end
            T1s(i,t) = T1;
            if T1 > 0
                areaMat{i,t} = area;
            end
                
            positions{i,t} = position;
        end
        
        if cellNumber < newCellNumber
            trackedCells(newCellNumber) = 10;
            for newCell = (cellNumber + 1):newCellNumber
                divisionPositions{i,t,newCell} = rTemp(newCell);
            end
        end
        trackedCells = trackedCells - 1;
        cellNumber = newCellNumber;
        adjacencyMatrix = newAdjacencyMatrix;
        N (i,t) = 1;
        t = t + 1;
        disp(['Simulation: ' num2str(i) ' of ' num2str(length(labels)) ' time = ' num2str(t)])
        tempInput = [inputFileLocation(1:end-9) sprintf('%05d',t) '.txt'];
    
    end
    t = 1;
    if t > 2000
        break
    end
end
        
save('RangeExperiment','rMat','discSizeMat','labels','T1s','N','areaMat','positions','cellNumberMatrix','divisionPositions','cellPolygonClassMatrix', 'cellNeighborMatrix');