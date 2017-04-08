close all
clear all

initialInputDir = 'F:\Wenzhao Data (T1)\polygon output\';
searchTerms = {'Growth_2to4'};

labels = getLabels(initialInputDir, searchTerms);

for j = 1:length(labels)
    
    disp(['Analyzing number ' num2str(j) ' of ' num2str(length(labels))]);
    
    data = importdata([initialInputDir labels{j}], ' ');
    
    clear polyClassNormal polyClassMitotic polyClassEdge
    
    for i = 1:length(data)
        tempStr = data{i};
        delimeters = findstr(tempStr,'#');
        polyClassNormal(i,:) = categorizeText(tempStr(1:(delimeters(1)-1)));
        polyClassMitotic(i,:) = categorizeText(tempStr((delimeters(1)+1):(delimeters(2)-1)));
        polyClassEdge(i,:) = categorizeText(tempStr((delimeters(2)+1):end));
    end
    
    rawNumN{j} = polyClassNormal;
    rawNumM{j} = polyClassMitotic;
    rawNumE{j} = polyClassEdge;
    
    cellsN{j} = sum(polyClassNormal, 2);
    cellsM{j} = sum(polyClassMitotic, 2);
    cellsE{j} = sum(polyClassEdge, 2);
    
    fractionN{j} = polyClassNormal ./ repmat(cellsN{j}, [1,10]);
    fractionM{j} = polyClassMitotic ./ repmat(cellsM{j}, [1,10]);
    fractionE{j} = polyClassEdge ./ repmat(cellsE{j}, [1,10]);
    j = j + 1;
end
