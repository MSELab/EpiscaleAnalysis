function frame = annotateFrame(frame, coords, neighbors, opacity, T1Cells, settings)
% Generate frame skeleton
[frame, skeleton] = makeSkeleton(frame, coords);

% Annotate T1 transitions
[cellCoords, gainloss] = T1Validity(coords, T1Cells(:, opacity > 0), neighbors);
frame = fillCell(frame, skeleton, cellCoords(gainloss == 0, :), settings.gainedColor);
frame = fillCell(frame, skeleton, cellCoords(gainloss == 1, :), settings.lostColor);

end