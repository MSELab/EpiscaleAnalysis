clear all
close all

scalingFactor = 0.25;

initialInputDir = 'G:\ESEM Paper\ESEM simulationDatafiles\detailedStat_';
labels = { ...
    'Growth_2to4_1_' ...
    ,'Growth_2to4_2_' ...
    ,'Growth_2to4_3_' ...
    ,'Growth_2to4_4_' ...
    ,'Growth_2to4_5_' ...
    ,'Growth_2to4_6_' ...
    }';

warning ('off','all');

colors = {'k','m','b','r','c'};


for i = 1
    m = 1;
    inputFileLocation = [initialInputDir labels{i}];
    
    t = 1200;
    mitArea = [];
    intArea = [];
    
    while(exist([inputFileLocation num2str(t, '%05d') '.txt'],'file'))
        
        clear areaTemp growthTemp rTemp
        
        inputDir = [inputFileLocation num2str(t, '%05d') '.txt'];
        data = importdata(inputDir);
        cellRank = 0;
        
        clear cellData
        
        for j = 1:length(data)
            tempString = data{j};
            if ~isempty(tempString)
                colon = strfind(tempString, ':');
                field = strtrim(tempString(1:(colon-1)));
                values = tempString((colon+1):end);
                if strcmp(field, 'CellRank')
                    cellRank = str2num(values) + 1;
                else
                    cellData(cellRank).(field) = values;
                end
            end
        end
        
        areaTemp = str2double({cellData.CellArea});
        growthTemp = str2double({cellData.GrowthProgress});
        
        mitArea = [mitArea areaTemp(growthTemp>0.91)];
        intArea = [intArea areaTemp(growthTemp<0.91)];
        
%         clf
%         errorbar(1,mean(mitArea),std(mitArea));
%         hold on
%         errorbar(2,nanmean(intArea),nanstd(intArea));
%         axis([0,3,0,1])
%         
%         drawnow;
        t
  
        t = t + 1;
    end
    print(['Figure7_' num2str(i) '.png'],'-dpng','-r1200')
    close all
end