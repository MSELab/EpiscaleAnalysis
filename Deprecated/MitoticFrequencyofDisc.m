clear all
close all

%% Declaration
searchTerms = {'N0'};
           
binSize = 50;

mitoticCutoff = 0.85;

%% Initialization
settings = prepareWorkspace();
[labels, labelIndices] = getLabels(settings, searchTerms, 3);
mitoticCellNumber = nan(4000, length(labels));
allCellNumber = nan(4000, length(labels));
mitoticFrequency = nan(4000, length(labels));
percentCellsDivided = nan(55, length(labels));
simulationTimestep = 100 / 2000; %100 hours per 2000 outputs

%% Data Extraction
for j = length(labels):-1:1
    disp(['Analyzing: ' labels{j}])
    load([settings.matDir labels{j} '.mat'], 'growthProgress');
    for t = length(growthProgress):-1:1
        growth = growthProgress{t};
        mitoticCellNumber(t, j) = sum(growth > mitoticCutoff);
        allCellNumber(t, j) = length(growth);
        mitoticFrequency(t, j) = mitoticCellNumber(t, j) / allCellNumber(t, j) * 100;
    end
    tBin = 1;
    for t = 1:binSize:(length(growthProgress) - binSize)
        cellsDivided = allCellNumber(t + binSize, j) - allCellNumber(t, j);
        percentCellsDivided(tBin, j) = cellsDivided / allCellNumber(t, j) * 100;
        tBin = tBin + 1;
    end
end

%% Plot mitotic frequency
close all
% Clean and process data
sampleSize = sum(~isnan(mitoticFrequency), 2);
meanMitoticFrequency = nanmean(mitoticFrequency, 2);
stdMitoticFrequency = nanstd(mitoticFrequency, 1, 2);
stdMitoticFrequency(isnan(meanMitoticFrequency)) = [];
meanMitoticFrequency(isnan(meanMitoticFrequency)) = [];
f = fit(((0:length(meanMitoticFrequency)-1)*5)',meanMitoticFrequency,'exp1');

% Plot data
plot((0:length(meanMitoticFrequency)-1)*50, meanMitoticFrequency);
%errorbar((1:4000)*5, meanMitoticFrequency, stdMitoticFrequency);
xlabel('Time (AU)')
ylabel('Percent of Cells Dividing')
axis([0 14000 0 15]);

%% Plot sample size
close all
plot((0:length(sampleSize)-1)*5, sampleSize);
xlabel('Time (AU)')
ylabel('Sample Size')
axis([0 14000 0 20]);

%% Plot percentage of newly divided cells
close all
% Clean and process data
meanCellsDivided = nanmean(percentCellsDivided, 2);
stdCellsDivided = nanstd(percentCellsDivided, 1, 2);
stdCellsDivided(isnan(meanCellsDivided)) = [];
meanCellsDivided(isnan(meanCellsDivided)) = [];

dataMax = (max(meanCellsDivided(:) + stdCellsDivided(:))*1.3)/(binSize * 5/100);

% Plot data
hFigure = figure();
ts = (0.5:length(meanCellsDivided)-0.5)*5*binSize/100;
hErrorBar = errorbar(ts, meanCellsDivided/(binSize * 5/100), stdCellsDivided);
%plot(ts, meanCellsDivided, ts, 6.2*exp(-ts*0.018));
hXLabel = xlabel('Time (hours)');
hYLabel = ylabel(['% cells dividing / hour']);
axis([-5 140 0 dataMax]);

% Format figure
set(hErrorBar                       , ...
  'LineStyle'       , '-'       , ...
  'Color'           , [0 0 0]  	, ...
  'LineWidth'       , 1       	, ...
  'Marker'          , '.'    	, ...
  'MarkerSize'      , 9      	, ...
  'MarkerEdgeColor' , [0 0 0]   , ...
  'MarkerFaceColor' , [0 0 0]   ...
);

% hAxes(1).XTick = relevantBins;
% hAxes(2).XTick = relevantBins;
% hAxes(1).YTick = 0.8:0.2:1.4;
% hAxes(2).YTick = 5.5:0.2:6.5;

% axis(hAxes(1),[min(relevantBins)-0.5 max(relevantBins)+0.5 0.8 1.4])
% axis(hAxes(2),[min(relevantBins)-0.5 max(relevantBins)+0.5 5.5 6.5])

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'times'   , ...
    'FontSize'      , 12      	 ...
);

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'times'   , ...
    'FontSize'      , 12      	 ,...
    'Color'           , [0 0 0]  	...
);

set(gca, ...
	'LineWidth'     , 1             , ...
    'Box'           , 'on'          , ...
    'FontName'      , 'times'       , ...
    'FontSize'      , 12            , ...
    'TickLength'    , [.025 .025]	, ...
    'TickDir'       , 'in'          ...
);

set(gca, ...
    'XTick'         , 0:20:140      ...
);

set(gca,'TickDir','in')
hFigure.PaperUnits = 'inches';
hFigure.PaperPosition = [0 0 4.5 3];
hFigure.PaperPositionMode = 'manual';
print([ settings.outFigureDir 'DividingCellFraction.png'],'-dpng','-r300')
print([ settings.outFigureDir 'DividingCellFraction.eps'],'-depsc2')

%% Plot total cells in disc vs experimental data
close all
meanCellNumber = nanmean(allCellNumber, 2);
stdCellNumber = nanstd(allCellNumber, 1, 2);
ts = (0:(length(meanCellNumber)-1)) * simulationTimestep;
experimentalCellNumber = 20*exp(6*(1-exp(-0.03*ts)));
plot(ts, gradient(meanCellNumber'), ts, gradient(experimentalCellNumber));
axis([0 140 0 inf]);
legend({'Simulation','Experiment'})
xlabel('Time (hours)')
ylabel(['Total Cell Number'])

%% Plot total cells in disc vs experimental data
close all
meanCellNumber = nanmean(allCellNumber, 2);
stdCellNumber = nanstd(allCellNumber, 1, 2);

% Plot data
hFigure = figure();
ts = (0.5:length(meanCellsDivided)-0.5)*5*binSize/100;
hErrorBar = errorbar(linspace(0,200,4000), meanCellNumber', stdCellNumber');
hXLabel = xlabel('Time (hours)');
hYLabel = ylabel(['Total Cell Number']);
dataMax = (max(meanCellNumber(:) + meanCellNumber(:))*1.4)/(binSize * 5/100);
axis([-5 140 0 dataMax]);

% Format figure
set(hErrorBar                       , ...
  'LineStyle'       , '-'       , ...
  'Color'           , [0 0 0]  	, ...
  'LineWidth'       , 1       	, ...
  'Marker'          , '.'    	, ...
  'MarkerSize'      , 9      	, ...
  'MarkerEdgeColor' , [0 0 0]   , ...
  'MarkerFaceColor' , [0 0 0]   ...
);

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'times'   , ...
    'FontSize'      , 12      	 ...
);

set([hXLabel, hYLabel]   , ...
	'FontName'      , 'times'   , ...
    'FontSize'      , 12      	 ,...
    'Color'           , [0 0 0]  	...
);

set(gca, ...
	'LineWidth'     , 1             , ...
    'Box'           , 'on'          , ...
    'FontName'      , 'times'       , ...
    'FontSize'      , 12            , ...
    'TickLength'    , [.025 .025]	, ...
    'TickDir'       , 'in'          ...
);

set(gca, ...
    'XTick'         , 0:20:140      ...
);

set(gca,'TickDir','in')
hFigure.PaperUnits = 'inches';
hFigure.PaperPosition = [0 0 4.5 3];
hFigure.PaperPositionMode = 'manual';
print([ settings.outFigureDir 'TotalCellNumber.png'],'-dpng','-r300')
print([ settings.outFigureDir 'TotalCellNumber.eps'],'-depsc2')