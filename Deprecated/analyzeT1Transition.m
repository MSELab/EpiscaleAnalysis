timeofT1Transitions = T1s;
simulationDuration = N;
growthRate = [1.5, 1.5, 1.5, 2, 2, 2, 2, 2, 2, 2.5, 2.5, 2.5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 6];
analysisBin = [1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 7]; 
cummT1 = cumsum(timeofT1Transitions, 2) / 2;
color = {'m','c','g','b','k','y','r'};


clf

for j = 1:4
    clear cummT1mean cummT1std
    iCount = 1;
    tempT1 = NaN(sum(analysisBin == j),4000);
    m = 1;
    for i = find(analysisBin == j)
        tempN = simulationDuration(i,:);
        tempT1(iCount,tempN==1) = cumsum(timeofT1Transitions(i,tempN==1));%./cellNumberMatrix(i,tempN==1));
        
        handle{m,j}=plot(1:sum(tempN==1),tempT1(iCount,tempN==1),color{j});
        %axis([0, 2000, 0, 2]);
        hold on
        m = m + 1;
    end
    %cummT1mean(j, :) = squeeze(nanmean(tempT1,1));
    %cummT1std(j, :) = squeeze(nanstd(tempT1,0,1));
end
        