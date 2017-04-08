function annotateVideoFrame( inputPath, outputPath, conversion, T1Locations, CellLocations, RoI )
circleSize = 1 / conversion.scale / 6;

% Load image
rawImage = imread(inputPath);

% Draw Cells transitions
cellNumber = size(CellLocations,2);
pixelCellLocations = round(CellLocations / conversion.scale + repmat(conversion.origin',[1, cellNumber]));
annotatedImage = insertShape(rawImage, 'filledcircle', [pixelCellLocations; ones(1, cellNumber)*round(circleSize)]', 'opacity', 1, 'Color',[255 255 0]);

% Draw T1 transitions
if ~isempty(T1Locations)
    cellNumber = size(T1Locations,2);
    pixelT1Locations = round(T1Locations / conversion.scale + repmat(conversion.origin',[1, cellNumber]));
    annotatedImage = insertShape(annotatedImage, 'filledcircle', [pixelT1Locations; ones(1, cellNumber)*round(circleSize*4)]', 'opacity', 0.6, 'Color','red');
    annotatedImage = insertShape(annotatedImage, 'filledcircle', [pixelT1Locations; ones(1, cellNumber)*round(circleSize/2)]', 'opacity', 1, 'Color','red');
end

% Show position of RoI
if RoI > 0
    annotatedImage = insertShape(annotatedImage, 'circle', [conversion.origin RoI / conversion.scale], 'opacity', 0.8, 'LineWidth',5, 'Color','green');
end

% Save Image
imwrite(annotatedImage, outputPath);

end

