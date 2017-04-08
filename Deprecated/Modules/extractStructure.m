function cellData = extractStructure( inputString )
 
t = 1;
while exist([inputString num2str(t, '%05d') '.txt'],'file')
    inputDir = [inputString num2str(t, '%05d') '.txt'];
    data = importdata(inputDir);
    
    for i = 1:length(data)
        tempString = data{i};
        if ~isempty(tempString)
            colon = strfind(tempString, ':');
            field = strtrim(tempString(1:(colon-1)));
            values = tempString((colon+1):end);
            if strcmp(field, 'CellRank')
                cellRank = str2num(values) + 1;
            else
                cellData(cellRank, t).(field) = values;
            end
        end
    end
    t = t + 1
end
end
