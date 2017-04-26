function flag = saveSimulation(label, settings)

% Obtain path information
pathDatafile = strrep(settings.thruData, '$', label);
pathData = strrep(settings.dirStats, '$', label);
list = dir(pathData);
idx = find(contains({list.name},'00000'));

if exist(pathDatafile, 'file')&&~(settings.force == 2)
    flag = 1;
    disp([label ' already processed.'])
    return
end

if isempty(idx)
    flag = -1;
    disp(['Data not found for ' label])
    return
end

nameStructure = strrep(list(idx).name, '00000', 'xxxxx');

disp(['Reading raw data for ' label])
rawDetails = convertSimulationintoMatArray([pathData, nameStructure], 0);

rawDetails(end) = [];

disp(['Converting raw data into mat files for ' label])
for i = length(rawDetails):-1:1
    clear cellCenterstmp neighborstmp
    
    for j = length(rawDetails{i}):-1:1
        tmp = rawDetails{i}(j).NeighborCells;
        tmp = strrep(tmp,'{','');
        tmp = strrep(tmp,'}','');
        neighborstmp{j} = sscanf(tmp,'%g') + 1;
        
        tmp = rawDetails{i}(j).CellCenter;
        tmp = strrep(tmp,'(','');
        tmp = strrep(tmp,')','');
        tmp = strrep(tmp,',',' ');
        cellCenterstmp(j,:) = sscanf(tmp, '%f');
    end
    
    neighbors{i} = neighborstmp;
    cellCenters{i} = cellCenterstmp;
    edgeCell{i} = str2double({rawDetails{i}.IsBoundrayCell});
    polyClass{i} = str2double({rawDetails{i}.NumOfNeighbors});
    cellArea{i} = str2double({rawDetails{i}.CellArea});
    cellPerimeter{i} = str2double({rawDetails{i}.CellPerim});
    growthProgress{i} = str2double({rawDetails{i}.GrowthProgress});
    memNodes{i} = str2double({rawDetails{i}.CurrentActiveMembrNodes});
    intNodes{i} = str2double({rawDetails{i}.CurrentActiveIntnlNode});
    cellNumber(i) = length(edgeCell{i});
end

disp(['Saving mat file for ' label])
save(pathDatafile, 'rawDetails','neighbors','cellCenters','edgeCell', ...
    'polyClass','cellArea','cellPerimeter','growthProgress','memNodes', ...
    'intNodes','cellNumber');

flag = 1;