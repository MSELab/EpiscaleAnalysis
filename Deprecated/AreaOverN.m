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
    ,'Growth_2to4_7_' ...
    ,'Growth_2to4_8_' ...
    ,'Growth_2to4_9_' ...
    }';

warning ('off','all');

colors = {'k','m','b','r','c','k','m','b','r','c'};

%outputTimes = [250, 500, 1000, 1500, 2000, 9999]

t = 2000;

for i = 1:9
    
    inputFileLocation = [initialInputDir labels{i}];
    
    m = 1;
        
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
        
        matrixOfStringArrays = cellfun(@(x) strrep(x,')',''),{cellData.CellCenter},'UniformOutput',false);
        matrixOfStringArrays = cellfun(@(x) strrep(x,'(',''),matrixOfStringArrays,'UniformOutput',false);
        matrixOfStringArrays = cellfun(@(x) strrep(x,',',' '),matrixOfStringArrays,'UniformOutput',false);
        cellsToDelete = cellfun('isempty', matrixOfStringArrays);
        matrixOfStringArrays(cellsToDelete) = [];
        areaTemp(cellsToDelete) = [];
        growthTemp(cellsToDelete) = [];
        [cellNumber] = length(growthTemp);
        
        areaOverGrowthTemp = areaTemp ./ (growthTemp + 1);
        
        strcatmat = strjoin(matrixOfStringArrays,' ');
        numbermatrix = sscanf(strcatmat,'%f');
        tempnumbermat = reshape(numbermatrix, [3, cellNumber]);
        
        cellxs = squeeze(tempnumbermat(1, :));
        cellys = squeeze(tempnumbermat(2, :));
        
        xs = cellxs - 25;
        ys = cellys - 25;
        rTemp = (xs.^2 + ys.^2).^0.5;
        
        rTempNorm = rTemp ./ max(rTemp(:));
        
        %activeTemp = growthTemp < 0.90 & growthTemp > 0.05;
        activeTemp = growthTemp > -1;
        
        k = 1;
        for rBin = [0,0.2;0.2,0.3;0.3,0.4;0.4,0.5;0.5,0.6;0.6,0.7;0.7,0.8;0.8,0.9;0.9,1]'
            rposition(k) = mean(rBin);
            meanArea(i,k,m) = mean(areaTemp(rTempNorm>=rBin(1)&rTempNorm<rBin(2)));
            stdArea(i,k,m) = std(areaTemp(rTempNorm>=rBin(1)&rTempNorm<rBin(2)));
            mitTemp = growthTemp > 0.92;
            meanMit(i,k,m) = mean(mitTemp(rTempNorm>=rBin(1)&rTempNorm<rBin(2)));
            stdMit(i,k,m) = std(mitTemp(rTempNorm>=rBin(1)&rTempNorm<rBin(2)));
            k = k + 1;
        end
    
end

%% Analysis

% stdArea2 = squeeze(std(meanArea,1));
% meanArea = squeeze(mean(meanArea,1));
% 
% stdMit = squeeze(std(meanMit,1));
% meanMit = squeeze(mean(meanMit,1));
% 
% stdArea3 = zeros(size(stdArea));
% 
% 
%     stdArea3 = stdArea .^2;
%     stdArea3 = squeeze(sum(stdArea3,1));
% stdArea3 = stdArea3 .^ 0.5;
% current = figure; 
% subplot(2,5,1)
% for i = 1:5
%        
%     subplot(2,5,i)
%     errorbar(rposition, meanArea(:,i)*5, stdArea2(:,i))
% axis([0, 1, 1.5, 3.3]);
% xlabel('Relative distance','FontSize', 12, 'FontName','Arial');
% if i == 1
%     ylabel('Area (um^2)', 'FontSize', 12, 'FontName','Arial');
% end
% end
% 
% subplot(2,5,6)
% maximum = [0.35, 0.35, 0.09, 0.09, 0.09];
% for i = 1:5
%     subplot(2,5,i+5)
%     errorbar(rposition, meanMit(:,i)*100, stdMit(:,i)*100)
%     axis([0, 1, 0, 35]);
%     xlabel('Relative distance','FontSize', 12, 'FontName','Arial');
%     if i == 1
%         ylabel('Mitotic Frequency (%)', 'FontSize', 12, 'FontName','Arial');
%     end
% end
% 
% set(current, 'PaperUnits','inches','PaperPosition', [0, 0, 12, 4]);
%   print(['Figure7HighRes2.png'],'-dpng','-r300')
