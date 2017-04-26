function frame = fillCell(frame, skeleton, coord, color)
for i = 1:size(coord, 1)
    cc = imfill(skeleton,round(coord(i,[2,1])));
    cc(skeleton) = 0;
    for c = 1:3
        tmpFrame = frame(:,:,c);
        tmpFrame(cc) = color(c);
        frame(:,:,c) = tmpFrame;
    end
end