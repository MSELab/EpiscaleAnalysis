% Determines which T1 transitions should be displayed

function [cellCoords, gainloss] = T1Validity(coords, T1Cells, neighbors)
cellCoords = [];

for i = 1:size(T1Cells, 2) % check each T1 transition
    % Make sure the T1 transition does not contain cells that do not exist
    if any(T1Cells(:,i) > length(neighbors))
        continue
    end
    
    % Make sure that the motif for the T1 transition is not broken
    for j = 1:4
        for k = 1:4
            neighbors_jk(j,k) = sum(neighbors{T1Cells(j,i)} == T1Cells(k,i));
        end
    end
    
    if  any(sum(neighbors_jk,2) < 2)
        continue
    end
    
    cellCoords = cat(1, cellCoords, coords(T1Cells(:,i), 1:2));
end

T1Total = size(cellCoords, 1) / 4;
if mod(T1Total, 1)
    error('T1 transition number should be an integer')
end

gainloss = repmat([1,1,0,0], [1, T1Total]);