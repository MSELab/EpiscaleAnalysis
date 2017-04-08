function flag = annotateVideo(label, settings)
%% Initialization
if nargin < 2
    settings = getSettings();
end

%% Find data
pathAnimation = strrep(settings.thruAnimation, '$', label);
pathAnnotation = strrep(settings.thruAnnotation, '$', label);

list = dir(pathAnimation);
idx = find(contains({list.name},'0.png'));

if isempty(idx)
    flag = -1;
    disp(['Data not found for ' label])
    return
end

nameStructure = strrep(list(idx).name, '0', 'x');

disp(['Reading raw data for ' label])

data = getData(label, 'cellCenters');

refBB = settings.refBB;
radiusCC = settings.radiusCC;
opacityCC = settings.opacityCC;

%% Obtain bounding box for first frame
firstFrame = imread(processDatafileName(nameStructure, 0));
firstFrame = firstFrame(:,:,1);
boundsx = find(any(firstFrame==0,1)); % Left and right edge of image (x1, x2)
boundsy = find(any(firstFrame==0,2)); % Top and bottom edge of image (y1, y2)
imgBB = [boundsx(1), boundsx(end), boundsy(end), boundsy(1)];

%% Obtain coordinate transformation
refPts = [refBB([1,3]); refBB([1,4]); refBB([2,3]); refBB([2,4])];
imgPts = [imgBB([1,3]); imgBB([1,4]); imgBB([2,3]); imgBB([2,4])];
tform = fitgeotrans(refPts,imgPts,'similarity');

%% Put cell centers on image
frameNumber = length(data.cellCenters);
mkdir('annotatedFrame')
for t = 0:frameNumber
    disp(['Annotating Frame ' num2str(t)]);
    frameRaw = imread(processDatafileName(nameStructure, t));
    cellCenters = data.cellCenters{t + 1};
    cellCentersNew = zeros(size(cellCenters), 'double');
    [cellCentersNew(:,1), cellCentersNew(:,2)] = ...
        tform.transformPointsForward(cellCenters(:,1), cellCenters(:,2));
    cellCentersNew(:,3) = radiusCC;
    frame = insertShape(frameRaw, 'FilledCircle', cellCentersNew,'Opacity',opacityCC);
    imwrite(frame,[pathAnnotation processDatafileName(strrep(settings.annotationName,'$',label), t)]);
end

