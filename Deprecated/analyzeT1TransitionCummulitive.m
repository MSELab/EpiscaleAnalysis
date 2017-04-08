timeofT1Transitions = T1s;
simulationDuration = N;
growthRate = [1.5, 1.5, 1.5, 2, 2, 2, 2, 2, 2, 2.5, 2.5, 2.5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 6];
analysisBin = [1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 7]; 
cummT1 = cumsum(timeofT1Transitions, 2) / 2;
color = {'m','c','g','b','k','y','r'};

[cellDivisions, ~] = gradient(cellNumberMatrix);
cellDivisions(size(cellNumberMatrix)) = 0;
cellDivisions = cellDivisions * 2;
cellDivisions(cellDivisions<0)=0;

m = 1;
binSize = 300;

close all
clear allT1Rates

maxVal = 0;

for j = 1:4
    iCount = 1;
    tempT1 = NaN(sum(analysisBin == j),4000);
    tempDiv = zeros(sum(analysisBin == j),4000);
    T1per100Divisions = NaN(sum(analysisBin == j),4000);
    for i = find(analysisBin == j)
        tempN = simulationDuration(i,:);
        tempT1(iCount,tempN==1) = cumsum(timeofT1Transitions(i,tempN==1));
        tempDiv(iCount,tempN==1) = cumsum(cellDivisions(i,tempN==1));
        T1per100Divisions(iCount, tempN==1) = 100 * tempT1(iCount,tempN==1) ./ tempDiv(iCount,tempN==1);
        iCount = iCount + 1;
    end

    meanRate = nanmean(T1per100Divisions,1);
    stdRate = nanstd(T1per100Divisions,0,1);

    tempDiv(tempDiv==0) = nan;
    
    meanDiv = nanmean(tempDiv,1);
    stdDiv = nanstd(tempDiv,0,1);
    
    meanT1 = nanmean(tempT1,1);
    stdT1 = nanstd(tempT1,0,1);

    meanVal = meanRate;
    stdVal = stdRate;
    
    shadedErrorBar(1:length(meanT1), meanVal, stdVal, color{m});
    hold on
    m = m + 1;
    maxVal = max(maxVal,(max(max(meanVal+stdVal))+0.5));
    %legend({'50% magenta','67% cyan','83% green','100% blue','133% black'});
    
    meanRate3D(j,1:length(nanmean(T1per100Divisions,2))) = T1per100Divisions(:,2000);
end
axis([0,2000,0,maxVal]);

meanRate3D (meanRate3D == 0) = nan;

clf
current = figure;
h=notBoxPlot(meanRate3D',[1.5,2,2.5,3]);

% for i = 1:size(allT1Rates,2)
%     allT1Rates(:, i) = allT1Ratesc(:, i)/max(allT1Rates(:, i));
% end
% close all
% bar(averageTime, allT1Rates')
% legend({'50%','67%','83%','100%','133%'});
%         

xlabel('Average initial growth constant (x 10^-^3)', 'FontSize', 16);
ylabel('T1 transitions per 100 divisions', 'FontSize', 16);
axis([1,3.5,8,16]);

set(current, 'PaperUnits','inches','PaperPosition', [0, 0, 6, 3.5]);
% set(gca,'XTickLabel',[1:0.5:3.5], 'FontSize',14,'FontName','Arial')
% set(gca,'YTickLabel',[8:2:16], 'FontSize',14,'FontName','Arial')

print(['Figure6LowerRes.png'],'-dpng','-r2400');
