% Generates skeleton diagram from paraview output.
% Mode 1: This mode breaks when cells overlap
% Mode 2: Uses watershed algorithm with cells as seeds

function [frame, skeleton] = makeSkeleton(frameRaw, coords, mode)
if nargin < 2
    mode = 1;
end
if nargin < 3
    mode = 2;
end
settings.sigma = 0.1;

%% Obtain tissue outline
frameLogical = frameRaw(:,:,1) == 0;
frameLogical = imfill(frameLogical, 'holes');
tissueOutline = imdilate(frameLogical, strel('disk', 20));
tissueOutline = imerode(tissueOutline, strel('disk', 20));

switch mode
    case 1 % Use binary skeleton operation
        skeleton = bwmorph(~frameLogical,'skel',Inf);
        
    case 2 % Use watershed with cell centers as seeds
        frameDouble = double(frameLogical);
        seeds = frameLogical * 0;
        
        coords = round(coords);
        coords = min(coords(:,[2,1]), size(frameDouble));
        coords = max(coords(:,[1,2]), [1,1]);
        
        idx = sub2ind(size(frameDouble), coords(:,1), coords(:,2));
        seeds(idx) = 1;
        
        frameDouble = imgaussfilt(frameDouble, settings.sigma);
        frameDouble = frameDouble + min(frameDouble(:));
        frameDouble = frameDouble / max(frameDouble(:));
        frameDouble(idx) = max(frameDouble(:));
        
        labelMatrix = watershed(1 - frameDouble);
        
        skeleton = labelMatrix == 0;
        
    otherwise
        error('Not a correct skeletalization mode')
end

skeleton(~tissueOutline) = 0;
skeleton(bwmorph(tissueOutline,'remove')) = 1;
skeleton = imdilate(skeleton, strel('disk', 1));

frame = uint8(repmat(~skeleton, [1,1,3])) * 255;
