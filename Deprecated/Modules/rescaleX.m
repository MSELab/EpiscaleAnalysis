function [timeAdd, timeMultiply] = rescaleX(f, xs, ys)

% minLength = min(length(xs), length(ys));
% xs = xs(1:minLength);
% ys = ys(1:minLength);
finalSize = min([size(xs, 2) size(ys, 2)]);
xs = xs(1:finalSize);
ys = ys(1:finalSize);
SSR = @(x) nansum((f((xs+x(1))*x(2))-ys).^2);

x = fminsearch(SSR,[0, 1]);
timeAdd = x(1);
timeMultiply = x(2);

end

