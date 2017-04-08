clear all
close all

%% Parameter Declaration
settings = prepareWorkspace();
searchTerms = {'Constant_0.6to1.2_Num501'};
inputDir = 'C:\tempAnimationBuild\Constant_0.4to0.8_Num204\';
outputDir = 'C:\tempAnimationBuild\AnnotatedConstant_0.4to0.8_Num204\';
mkdir(outputDir);
namingConvention = 'Constant_0.4to0.8_Num204.';
initialPositions = [23.75 26.25 23.864 26.136] - 25; % in the form minx maxx miny maxy
% All math should be done in actual units and converted into pixels later
% scale is in AU per pixel
% origin is the location of the origin in pixels

countedFrames = 0;

%% Select spatial axis
frame = imread([inputDir namingConvention num2str(0, '%04d') '.png']);
rawImage = frame;
frame(1400:end,1:600, :) = 255;
frame = 765 - sum(frame, 3);
xProject = sum(frame, 1);
yProject = sum(frame, 2);
xsPNG = sum(xProject > 0) - 1;
ysPNG = sum(yProject > 0) - 1;
xsACT = initialPositions(2) - initialPositions(1);
ysACT = initialPositions(4) - initialPositions(3);
xScale = xsACT / xsPNG;
yScale = ysACT / ysPNG;
conversion.scale = mean([xScale, yScale]);
originACT = [0 0];
tmp1 = regionprops(yProject > 0, 'centroid');
tmp2 = regionprops(xProject > 0, 'centroid');
tmp3 = [tmp2.Centroid, tmp1.Centroid];
originPNG = tmp3([1,4]);
conversion.origin = originPNG;

%% Analysis
rawDetails = convertSimulationintoMatArray([settings.inDetailsDir 'detailedStat_GrowthConstant_0.4to0.8_Num204_xxxxx.txt'], 0);
[cellx, celly, T1x, T1y] = IdentifyT1Transitions2D( rawDetails );

%% Annotations
imwrite(rawImage, [outputDir namingConvention num2str(0, '%04d') '.png']);
for i = 1:2000
    i
    initialT1Window = max([1,i-10]);
    finalT1Window = min([2001,i+10]);
    
    tempT1x = [];
    tempT1y = [];
    for j = initialT1Window:finalT1Window
        tempx = mean(T1x{j},1);
        tempy = mean(T1y{j},1);
        
        tempT1x = [tempT1x tempx(:)'];
        tempT1y = [tempT1y tempy(:)'];
    end
    
    tempCellx = cellx{i+1};
    tempCelly = celly{i+1};
    
    
    
    if length(tempCellx) >= 100 && countedFrames < 600
        countedFrames = countedFrames + 1;
        cellPositions = sqrt(tempCellx.^2 + tempCelly.^2);
        sortedPositions = sort(cellPositions);
        RoI = sortedPositions(60);
        tempR = sqrt(tempT1x.^ + tempT1y.^2);
        tempT1x(tempR>RoI) = [];
        tempT1y(tempR>RoI) = [];
    else
        RoI = 0;
    end
    
    inputPath = [inputDir namingConvention num2str(i, '%04d') '.png'];
    outputPath = [outputDir namingConvention num2str(i, '%04d') '.png'];

    annotateVideoFrame(inputPath, outputPath, conversion, [tempT1x; -tempT1y], [tempCellx; -tempCelly], RoI)
end








