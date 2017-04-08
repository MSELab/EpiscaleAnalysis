function [ adjacencyMatrix ] = makeAdjacencyMatrix( neighborStringMatrix )

cellNumber = length(neighborStringMatrix);

adjacencyMatrix = zeros(cellNumber);

emptyIndices = cellfun(@(x) isempty(x), neighborStringMatrix);
for kk = find(emptyIndices)
    neighborStringMatrix{kk} = '0';
end
neighborStringMatrix = strrep(neighborStringMatrix,'}','');
neighborStringMatrix = strrep(neighborStringMatrix,'{','');

for activeCell = 1:cellNumber
    neighbortemp = sscanf(neighborStringMatrix{activeCell}, '%i')' + 1;
    if max(neighbortemp) > cellNumber
        error('Input file has neighbor numbers outside of the scope of the domain.');
    end
    for j = neighbortemp
        adjacencyMatrix(activeCell, j) = true;
    end
end
end

