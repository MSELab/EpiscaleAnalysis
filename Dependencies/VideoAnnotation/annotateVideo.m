function flag = annotateVideo(label, mode, settings)
settings.outputFrameRate = 5;

%% Initialization
if nargin < 2
   mode = 1; 
end
if nargin < 3
    settings = getSettings();
end

%% Obtain data path.
[path, pathFlag] = getpaths(settings, label);
if pathFlag ~= 1
    flag = pathFlag;
    return
end

%% Load data
disp(['Reading raw data for ' label])

data = load(path.Data, 'cellCenters', 'neighbors');
data2 = load(path.T1, 'T1_cells', 'T1_time');

%% Obtain bounding box for last frame
lastFrameidx = lastIdx(path);

lastFrame = imread([path.Animation processDatafileName(path.nameStructure, lastFrameidx)]);
lastFrame = lastFrame(:,:,1);
lastFrame = uint8(lastFrame == 0);

stats = regionprops(lastFrame, 'BoundingBox');

%% Obtain coordinate transformation
firstFrame = imread([path.Animation processDatafileName(path.nameStructure, 0)]);
tform = makeCoordinateTransformation(firstFrame, settings);

%% Prepare to write output
mkdir('annotatedFrame')
v = VideoWriter([path.Video '.mp4'], 'MPEG-4');
v.FrameRate = 7;
open(v);

%% Annotate frames
for t = 0:lastFrameidx
    currentTimepoint = t * settings.outputFrameRate + 1;
    
    if currentTimepoint > length(data.cellCenters)
        break
    end
    
    % Read in frame
    tmppath = [path.Animation processDatafileName(path.nameStructure, t)];
    if ~exist(tmppath, 'file')
        break
    end
    
    disp(['Annotating ' label ' Frame ' num2str(t)]);
    frameRaw = imread(tmppath);
    
    % Arrange metadata
    cellCenters = data.cellCenters{currentTimepoint};
    cellCentersNew = zeros(size(cellCenters), 'double');
    [cellCentersNew(:,1), cellCentersNew(:,2)] = ...
        tform.transformPointsForward(cellCenters(:,1), cellCenters(:,2));
    neighbors = data.neighbors{currentTimepoint};
    T1Time = abs(data2.T1_time - currentTimepoint);
    opacity = (settings.annotateT1Time - T1Time) / settings.annotateT1Time * settings.T1Opacity;
    opacity(opacity < 0) = 0;
    
    % Annotate frame
    frame = annotateFrame(frameRaw, cellCentersNew, neighbors, opacity, data2.T1_cells, settings);
    
    % Write video
    frame = imcrop(frame, stats.BoundingBox);
    imwrite(frame,[path.Annotation processDatafileName(path.nameStructure, t)]);
    writeVideo(v, frame);
end

close (v)

flag = 1;