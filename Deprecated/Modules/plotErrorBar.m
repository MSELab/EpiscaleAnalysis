function h = plotErrorBar(x,y)
y1 = y(:,1);
y2 = y(:,2);
h = errorbar(x,y1,y2);