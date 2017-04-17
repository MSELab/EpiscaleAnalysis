close all
clearvars

load('Summary.mat')

cellNumber = nan(length(Data), 10000);

for i = 1:length(Data)
    tmp = Data{i}.cellNumber;
    cellNumber(i,1:length(tmp)) = tmp;
end

cellNumber = cellNumber(:,any(~isnan(cellNumber),1));
plot(cellNumber')

frames = sum(~isnan(cellNumber),2);
N = nanmax(cellNumber,[],2);

minTime = sum(cellNumber<300,2);

minTime((metadata.g_ave==.8))

%%
C = [1.5,3;2,40;100,450;0,10;2,20;200,450;0,21]'
nrows = 25
rlist = candexch(C,nrows)

nfactors = 7
nruns = 250
[dCE] = cordexch(nfactors,nruns,'linear','bounds',C)