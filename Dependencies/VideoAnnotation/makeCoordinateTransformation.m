function tform = makeCoordinateTransformation(frame, settings)

frame = frame(:,:,1);
boundsx = find(any(frame==0,1)); % Left and right edge of image (x1, x2)
boundsy = find(any(frame==0,2)); % Top and bottom edge of image (y1, y2)
imgBB = [boundsx(1), boundsx(end), boundsy(end), boundsy(1)];

refPts = [settings.refBB([1,3]); settings.refBB([1,4]); settings.refBB([2,3]); settings.refBB([2,4])];
imgPts = [imgBB([1,3]); imgBB([1,4]); imgBB([2,3]); imgBB([2,4])];
tform = fitgeotrans(refPts,imgPts,'similarity');