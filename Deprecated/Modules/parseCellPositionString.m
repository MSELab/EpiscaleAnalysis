function [ r, rNorm ] = parseCellPositionString( cellPositionStrings )

cellNumber = length(cellPositionStrings);

matrixOfStringArrays = cellfun(@(x) strrep(x,')',''),{cellPositionStrings},'UniformOutput',false);
matrixOfStringArrays = cellfun(@(x) strrep(x,'(',''),matrixOfStringArrays,'UniformOutput',false);
matrixOfStringArrays = cellfun(@(x) strrep(x,',',' '),matrixOfStringArrays,'UniformOutput',false);
cellsToDelete = cellfun('isempty', matrixOfStringArrays);
matrixOfStringArrays(cellsToDelete) = [];

strcatmat = strjoin(matrixOfStringArrays{1},' ');
numbermatrix = sscanf(strcatmat,'%f');
tempnumbermat = reshape(numbermatrix, [3, cellNumber]);

cellxs = squeeze(tempnumbermat(1, :));
cellys = squeeze(tempnumbermat(2, :));

xs = cellxs - 25;
ys = cellys - 25;
r = (xs.^2 + ys.^2).^0.5;

rNorm = r ./ max(r(:));
        
end

