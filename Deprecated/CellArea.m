clear all
close all

%% Declaration
searchTerms = {'N0'};
           
dtds = 36/60/60; %100 hours per 2000 outputs
colors = {'m','c','b','g','r','k'};

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);

allCellNumber = nan(5000, length(labels));
totalArea = nan(5000, length(labels));

%% Data Extraction
for j = length(labels):-1:1
    disp(['Analyzing: ' labels{j}])
    load([settings.matDir labels{j} '.mat'], 'growthProgress', 'cellArea', 'edgeCell', 'polyClass');
    for t = length(growthProgress):-1:1
        area = cellArea{t};
        edge = logical(edgeCell{t});
        growth = growthProgress{t};
        poly = polyClass{t};
        
        totalArea(t, j) = sum(area);
        
%         area(edge) = [];
        growth(edge) = [];
        poly(edge) = [];
        
        mitotic = growth > 1.0-(1.0-0.85)*exp(-1.1e-5 * (t - 1) * 36);
        
        averageArea(t, j) = mean(area);
        stdArea(t, j) = std(area);
        allCellNumber(t, j) = length(area);
        
        averageMitArea(t, j) = mean(area(mitotic));
        stdMitArea(t, j) = std(area(mitotic));
        
        total3s(t, j) = sum(poly<=3) / sum(poly>0);
        total4s(t, j) = sum(poly==4) / sum(poly>0);
        total5s(t, j) = sum(poly==5) / sum(poly>0);
        total6s(t, j) = sum(poly==6) / sum(poly>0);
        total7s(t, j) = sum(poly==7) / sum(poly>0);
        total8s(t, j) = sum(poly>=8) / sum(poly>0);
    end
end

%%
average3s = mean(total3s, 2);
average4s = mean(total4s, 2);
average5s = mean(total5s, 2);
average6s = mean(total6s, 2);
average7s = mean(total7s, 2);
average8s = mean(total8s, 2);
% average9s = mean(total9s, 2);

std3s = zeros(size(average3s)); %std(total3s, 2);
std4s = zeros(size(average3s)); %std(total4s, 2);
std5s = zeros(size(average3s)); %std(total5s, 2);
std6s = zeros(size(average3s)); %std(total6s, 2);
std7s = zeros(size(average3s)); %std(total7s, 2);
std8s = zeros(size(average3s)); %std(total8s, 2);
% std9s = std(total9s, 2);

%% Get A_dot/A
a = [];
const = 200;
for i = 1:const:(length(totalArea)-const)
    a(end + 1) = mean(totalArea(i:(i+const-1)));
end

totalArea = a;
dAds = gradient(totalArea);
% [~, dAds] = gradient(totalArea);
dAdt = dAds / (dtds * const);
A_dot_over_A = dAdt ./ totalArea;
% A_dot_over_A = gradient(dAdt ./ totalArea,5);
A_dot_over_A(1) = [];

%% Plot test graphs
close all
figure(1)
t = ((1:length(A_dot_over_A)))*dtds*const;
plot(t, A_dot_over_A,'k')
xlabel('Time (hr)')
% ylabel('Area (length^2)')
ylabel('\deltaA/A')
axis([0,inf,0,0.25])

set(gca, 'FontName', 'Arial');

print([ settings.outFigureDir 'dAoverAOverTime.png'],'-dpng','-r300')

return
figure(2)
t = (0:(size(averageArea,1))-1)*dtds;
hFig1 = shadedErrorBar(t,averageArea',stdArea','-k',1);
ylabel('Cell area (\mum^2)')
xlabel('Time (hr)')
axis([0,49,0,25])
set(gca, 'FontName', 'Arial');
print([ settings.outFigureDir 'AverageArea.png'],'-dpng','-r300')

figure(3)
t = (0:(size(averageArea,1))-1)*dtds;
hFig2 = shadedErrorBar(t,averageMitArea',stdMitArea','-k',1);
ylabel('Mitotic cell area (\mum^2)')
xlabel('Time (hr)')
axis([0,49,0,25])
set(gca, 'FontName', 'Arial');
print([ settings.outFigureDir 'AverageMitoticArea.png'],'-dpng','-r300')

figure(4)
hold on
t = (0:(size(averageArea,1))-1)*dtds;
shadedErrorBar(t,average3s,std3s,colors{1},1);
shadedErrorBar(t,average4s,std4s,colors{2},1);
shadedErrorBar(t,average5s,std5s,colors{3},1);
shadedErrorBar(t,average6s,std6s,colors{4},1);
shadedErrorBar(t,average7s,std7s,colors{5},1);
shadedErrorBar(t,average8s,std8s,colors{6},1);

ylabel('Fraction')
xlabel('Time (hr)')
axis([0,49,0,1])
set(gca, 'FontName', 'Arial');
print([ settings.outFigureDir 'PolygonClassOverTime.png'],'-dpng','-r300')



return

figure(2)
t = (0:(size(averageArea,1))-1)*dtds;
plot(t, averageArea')
xlabel('Time (hr)')
ylabel('Average Area (um^2)')
axis([0,49,0,13])

figure(3)
t = (0:(size(stdArea,1))-1)*dtds;
plot(t, stdArea')
xlabel('Time (hr)')
ylabel('Standard Deviation of Area (um^2)')
axis([0,49,0,13])

return
figure(2)
dAdt(1:10,:) = [];
plot(dAdt)

figure(3)
A_dot_over_A(1:10,:) = [];
plot(A_dot_over_A)

figure(4)
meanAdotA = nanmean(A_dot_over_A,2);
meanAdotA(isnan(meanAdotA)) = [];
t = ((1:length(meanAdotA))+9)*dtds;
plot(t, meanAdotA)
xlabel('Time (hr)')
ylabel('A_d_o_t/A (hr^-^1)')

figure(5)
meanAdotA = nanmean(A_dot_over_A,2);
meanAdotA(isnan(meanAdotA)) = [];
t = ((1:length(meanAdotA))+9)*dtds;
plot(t, imgaussfilt(meanAdotA,5))
xlabel('Time (hr)')
ylabel('A_d_o_t/A (hr^-^1), Gaussian Filter sigma = 5')
