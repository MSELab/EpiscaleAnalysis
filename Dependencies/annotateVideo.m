function flag = annotateVideo(label, settings)
settings.outputFrameRate = 5;

%% Initialization
if nargin < 2
    settings = getSettings();
end

%% Lazy parameter declaration
refBB = settings.refBB;
radiusCC = settings.radiusCC;
opacityCC = settings.opacityCC;

settings.annotateT1Time = 200;
settings.T1Color = 'red';
settings.lostColor =  'red';
settings.gainedColor =  'cyan';
settings.T1Opacity = 0.3;
settings.T1Radius = 24;

settings.thruAnimation = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\Data\$\pngFiles\';
settings.thruAnnotation = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\Data\$\pngAnnotated\';
settings.outAnimation = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\Data\$_annotated';
settings.thruData = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\PooledData\$_Raw.mat';
settings.thruT1 = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\PooledData\$_T1.mat';

%% Obtain data path
pathAnimation = strrep(settings.thruAnimation, '$', label);
pathAnnotation = strrep(settings.thruAnnotation, '$', label);
pathVideo = strrep(settings.outAnimation, '$', label);
pathData = strrep(settings.thruData, '$', label);
pathT1 = strrep(settings.thruT1, '$', label);
mkdir(pathAnnotation);

list = dir(pathAnimation);
idx = find(contains({list.name},'0.png'));
idx = idx(1);

if isempty(idx)
    flag = -1;
    disp(['Data not found for ' label])
    return
end

% Lazy method for determining number of zeros
zeroIdx{1} = strfind(list(idx).name, '00000.png');
zeroIdx{2} = strfind(list(idx).name, '0000.png');
zeroIdx{3} = strfind(list(idx).name, '000.png');
zeroIdx{4} = strfind(list(idx).name, '00.png');
zeroIdx{5} = strfind(list(idx).name, '0.png');

forms = find(~cellfun('isempty',zeroIdx));

switch forms(1)
    case 1
        nameStructure = strrep(list(idx).name, '00000.png', 'xxxxx.png');
    case 2
        nameStructure = strrep(list(idx).name, '0000.png', 'xxxx.png');
    case 3
        nameStructure = strrep(list(idx).name, '000.png', 'xxx.png');
    case 4
        nameStructure = strrep(list(idx).name, '00.png', 'xx.png');
    case 5
        nameStructure = strrep(list(idx).name, '0.png', 'x.png');
    otherwise
        flag = -3;
        disp(['Naming pattern not found for: ' label])
        return
end

%% Load data
disp(['Reading raw data for ' label])

data = load(pathData, 'cellCenters', 'neighbors');
data2 = load(pathT1, 'T1_cells', 'T1_time');

%% Obtain bounding box for last frame
lastFrameidx = 0;
for i = 1:length(list)
    tmpPath = [pathAnimation processDatafileName(nameStructure, i)];
    if exist(tmpPath, 'file')
        lastFrameidx = i;
    else
        break
    end
end

lastFrame = imread([pathAnimation processDatafileName(nameStructure, lastFrameidx)]);
lastFrame = lastFrame(:,:,1);
lastFrame = uint8(lastFrame == 0);

stats = regionprops(lastFrame, 'BoundingBox');

%% Obtain bounding box for first frame
firstFrame = imread([pathAnimation processDatafileName(nameStructure, 0)]);
firstFrame = firstFrame(:,:,1);
boundsx = find(any(firstFrame==0,1)); % Left and right edge of image (x1, x2)
boundsy = find(any(firstFrame==0,2)); % Top and bottom edge of image (y1, y2)
imgBB = [boundsx(1), boundsx(end), boundsy(end), boundsy(1)];

%% Obtain coordinate transformation
refPts = [refBB([1,3]); refBB([1,4]); refBB([2,3]); refBB([2,4])];
imgPts = [imgBB([1,3]); imgBB([1,4]); imgBB([2,3]); imgBB([2,4])];
tform = fitgeotrans(refPts,imgPts,'similarity');

frameNumber = length(data.cellCenters);

%% Prepare to write output
mkdir('annotatedFrame')
v = VideoWriter([pathVideo '.mp4'], 'MPEG-4');
v.FrameRate = 7;
open(v);

%% Annotate frames
for t = 0:lastFrameidx
    currentTimepoint = t * settings.outputFrameRate + 1;
    
    if currentTimepoint > length(data.cellCenters)
       break 
    end
    
    % Read in frame
    tmpPath = [pathAnimation processDatafileName(nameStructure, t)];
    if ~exist(tmpPath, 'file')
        break
    end
    
    disp(['Annotating ' label ' Frame ' num2str(t)]);
    frameRaw = imread(tmpPath);
    frame = frameRaw;
    
    % Put neighbors on image
    cellCenters = data.cellCenters{currentTimepoint};
        cellCentersNew = zeros(size(cellCenters), 'double');
    [cellCentersNew(:,1), cellCentersNew(:,2)] = ...
        tform.transformPointsForward(cellCenters(:,1), cellCenters(:,2));
    
    neighbors = data.neighbors{currentTimepoint};
    for i = 1:length(neighbors)
        neighborPositions = cellCentersNew(neighbors{i},1:2);
        allPositions = neighborPositions;
        allPositions(:,3:4) = repmat(cellCentersNew(i,1:2), [length(neighbors{i}), 1]);
        frame = insertShape(frame,'Line',allPositions,'Opacity',opacityCC);
    end
    
    % Put cell centers on image
    cellCentersCircles = cellCentersNew;
    cellCentersCircles(:,3) = radiusCC;
    frame = insertShape(frame, 'FilledCircle', cellCentersCircles,'Opacity',opacityCC);
    
    % Annotate T1 transitions
    T1Time = abs(data2.T1_time - currentTimepoint);
    opacity = (settings.annotateT1Time - T1Time) / settings.annotateT1Time * settings.T1Opacity;
    
    opacity(opacity < 0) = 0;
    for j = find(opacity > 0)'
        % Make sure that the motif for the T1 transition is not broken
        T1Cells = data2.T1_cells([1,3,2,4],j);
        if any(T1Cells > length(neighbors))
            continue
        end
        
        if  ~(any(neighbors{T1Cells(1)} == T1Cells(2)) && ...
        	any(neighbors{T1Cells(2)} == T1Cells(3)) && ...
          	any(neighbors{T1Cells(3)} == T1Cells(4)) && ...
           	any(neighbors{T1Cells(4)} == T1Cells(1)))
            continue
        end
        
        % Render the lines between connected cells (reveal motif)
        for i = data2.T1_cells(:,j)'
            if i > length(neighbors)
                continue
            end
            currentNeighbors = intersect(neighbors{i},data2.T1_cells(:,j));
            currentNeighbors(currentNeighbors > length(neighbors)) = [];
            
            if isempty(currentNeighbors)
                continue
            end
            
            allPositions = cellCentersNew(currentNeighbors,1:2);
            allPositions(:,3:4) = repmat(cellCentersNew(i,1:2), [length(currentNeighbors), 1]);
            frame = insertShape(frame,'Line',allPositions,'Color',settings.T1Color);
        end
        idx = data2.T1_cells(:,j);
        neighborPositions = cellCentersNew(idx(idx<=size(cellCentersNew, 1)),1:2);
        frame = insertShape(frame, 'FilledCircle', cellCentersCircles(idx(1:2),:),'Opacity',opacityCC,'Color',settings.gainedColor);
        frame = insertShape(frame, 'FilledCircle', cellCentersCircles(idx(3:4),:),'Opacity',opacityCC,'Color',settings.lostColor);
        frame = insertShape(frame, 'FilledCircle', [mean(neighborPositions,1), settings.T1Radius],'Color',settings.T1Color, 'Opacity',opacity(j));
    end
    
    % Write video
    frame = imcrop(frame, stats.BoundingBox);
    imwrite(frame,[pathAnnotation processDatafileName(nameStructure, t)]);
    writeVideo(v, frame);
end

close (v)

flag = 1;