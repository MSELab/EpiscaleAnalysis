j = 1;
dataSize = [0, 0, length(labels)];
for i = 1:length(labels)
    dataSizetemp = size(fractionM{i});
    dataSize(1) = max(dataSize(1), dataSizetemp(1));
    dataSize(2) = max(dataSize(2), dataSizetemp(2));
end

Mitotic = NaN(dataSize);
nonMitotic = NaN(dataSize);

%% Plot non-mitotic data without errorbars
close all
for i = 1:length(labels)
    Mitotic(1:size(fractionM{i},1),:,j) = fractionM{i};
    nonMitotic(1:size(fractionM{i},1),:,j) = fractionN{i};
    j = j + 1;
    plot(fractionN{i});
    axis([0,2000,0,1]);
end

%% Plot mitotic data with errorbars
close all
meanMitotic = squeeze(nanmean(Mitotic,3));
stdMitotic = squeeze(nanstd(Mitotic,0,3));
errorbar(meanMitotic,stdMitotic);
legend({'1 sided','2 sided','3 sided','4 sided','5 sided','6 sided','7 sided','8 sided','9 sided','10 sided'})
axis([0,2000,0,1]);

%% Plot non-mitotic data with errorbars
close all
meanNonMitotic = squeeze(nanmean(nonMitotic,3));
stdNonMitotic = squeeze(nanstd(nonMitotic,0,3));
errorbar(meanNonMitotic,stdNonMitotic);
legend({'1 sided','2 sided','3 sided','4 sided','5 sided','6 sided','7 sided','8 sided','9 sided','10 sided'})
axis([0,2000,0,1]);

%% Plot non-mitotic data with shaded errorbars
close all
colors = {'w', 'w', 'm', 'c', 'b', 'g', 'r', 'k', 'w', 'w'};

for i = [3,8,4,5,7,6]
    shadedErrorBar((1:2000)/100,meanNonMitotic(1:2000,i),stdNonMitotic(1:2000,i),colors{i});
    hold on
    axis([0,20,0,1]);
end

%% Output plot
print('Figure1b_1_8_16.png','-dpng','-r2400')