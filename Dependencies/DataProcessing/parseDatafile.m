function [ cellData ] = parseDatafile( inputFilepath )
% Converts the selected Epi-Scale detailed output file into a sctructure
% array, where the elements represent the stats associated with individual
% cells

% data = importdata(inputFilepath);

% Read in the datafile
fid = fopen(inputFilepath,'r');
data = textscan(fid,'%s','Delimiter',{'\n'});
data = data{1};
fclose(fid);

% Loop through each row and convert the text into a structure
cellRank = 0;
for j = 1:length(data)
    tempString = data{j};
    if ~isempty(tempString)
        colon = strfind(tempString, ':');
        field = strtrim(tempString(1:(colon-1)));
        if isempty(field)
            break
        end
        values = tempString((colon+1):end);
        if strcmp(field, 'CellRank') % Indicates the start of a new cell
            cellRank = str2num(values) + 1;
        else
            cellData(cellRank).(field) = values;
        end
    end
end

end

