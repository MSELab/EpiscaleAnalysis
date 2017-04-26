function adjMat = adjacencyArray2Mat(adjArray)
adjMat = zeros(length(adjArray), 'logical');

for i = 1:length(adjArray)
    adjMat(i,adjArray{i}) = 1;
end

end