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
    cellData = extractStructure(inputFileLocation);
    
    [cellNumber, totalTime] = size(cellData);
    
    cellAreas = reshape(str2double({cellData.CellArea}), [cellNumber, totalTime]);
    cellGP = reshape(str2double({cellData.GrowthProgress}), [cellNumber, totalTime]);
    
    matrixOfStringArrays = {cellData.CellCenter};
    matrixOfStringArrays(cellfun('isempty', matrixOfStringArrays)) = {'NaN,NaN,NaN'};
    matrixOfStringArrays = cellfun(@(x) strrep(x,')',''),matrixOfStringArrays,'UniformOutput',false);
    matrixOfStringArrays = cellfun(@(x) strrep(x,'(',''),matrixOfStringArrays,'UniformOutput',false);
    matrixOfStringArrays = cellfun(@(x) strrep(x,',',' '),matrixOfStringArrays,'UniformOutput',false);
    
    strcatmat = strjoin(matrixOfStringArrays,' ');
    numbermatrix = sscanf(strcatmat,'%f');
    tempnumbermat = reshape(numbermatrix, [3, cellNumber, totalTime]);
    
    cellxs = squeeze(tempnumbermat(1, :, :));
    cellys = squeeze(tempnumbermat(2, :, :));
    
    xs = cellxs - 25;
    ys = cellys - 25;
    rs = (xs.^2 + ys.^2).^0.5;
    
    activeCells = cellGP < 0.90 & cellGP > 0.05;
    
    scatter(rs(activeCells), cellAreas(activeCells));
    axisSet(1) = min(rs(:));
    axisSet(2) = max(rs(:));
    axisSet(3) = min(cellAreas(:));
    axisSet(4) = max(cellAreas(:));
    v = VideoWriter('areaOverTime');
    open(v);
    for t = 1:totalTime
        rTemp = rs(:,t)';
        areaTemp = cellAreas(:,t)';
        growthTemp = cellGP(:,t)';
        activeTemp = growthTemp < 0.90 & growthTemp > 0.05;
        scatter(rTemp(activeTemp), areaTemp(activeTemp),16,k,'filled');
        axis(axisSet);
        drawnow;
        t
        writeVideo(v,gcf)
    end
    close(v)
end