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
binSize = 100;

close all

clear allT1Rates averageTime averageT1 stdT1 allT1Std

for j = 1:4
    iCount = 1;
    tempT1 = NaN(sum(analysisBin == j),4000);
    tempDiv = zeros(sum(analysisBin == j),4000);
    for i = find(analysisBin == j)
        tempN = simulationDuration(i,:);
        tempT1(iCount,tempN==1) = timeofT1Transitions(i,tempN==1);
        tempDiv(iCount,tempN==1) = cellDivisions(i,tempN==1);
        iCount = iCount + 1;
    end
    timeBin = 1;
    clear stdT1Rate averageT1Rate averageTime
    for t = [1, binSize:binSize:1999]
        times = t:(t+binSize);
        totalT1 = nansum(tempT1(:,times),2);
        totaldivisions = nansum(tempDiv(:,times),2);
        T1per100Divisions = 100 * totalT1 ./ totaldivisions;
        averageT1Rate(timeBin) = nanmean(T1per100Divisions);
        stdT1Rate(timeBin) = nanstd(T1per100Divisions);
        averageT1(timeBin) = nanmean(totalT1);
        stdT1(timeBin) = nanstd(totalT1);
        averageTime(timeBin) = mean(times);
        timeBin = timeBin + 1;
    end
    
    allT1Rates(j, :) = averageT1;
    allT1Std(j, :) = stdT1;
    
    subplot(1,5,m)
    %errorbar(averageTime, averageT1, stdT1Rate, color{m});
    hold on
    m = m + 1;
    
end
% for i = 1:size(allT1Rates,2)
%     allT1Rates(:, i) = allT1Rates(:, i)/max(allT1Rates(:, i));
% end
close all
figure1 = figure;
for m = 4:-1:1
   shadedErrorBar(averageTime/20, allT1Rates(m,:)'/(binSize/20),allT1Std(m,:)'/binSize*20,color{m});
   hold on
end
%legend({'50% Growth Rate','67% Growth Rate','83% Growth Rate','100% Growth Rate','133% Growth Rate'});

xlabel('Time (hours)', 'FontSize', 24, 'FontName','Arial');
ylabel('T1 transitions per hour', 'FontSize', 24, 'FontName','Arial');
axis([0,100,0,9]);

set(figure1, 'PaperUnits','inches','PaperPosition', [0, 0, 6, 4]);
% set(gca,'XTickLabel',[1:0.5:3.5], 'FontSize',14,'FontName','Arial')
% set(gca,'YTickLabel',[8:2:16], 'FontSize',14,'FontName','Arial')

%print(['Figure6bLowerRes.png'],'-dpng','-r2400');
        