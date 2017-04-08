function array1to10 = categorizeText( inputString )

array1to10 = zeros(1,10);
if ~isempty(inputString)
    commaLocations = findstr(inputString, ',');
    if ~isempty(commaLocations)
        if length(commaLocations)>1
            for m = 1:length(commaLocations)-1
                index = str2num(inputString(commaLocations(m)-1));
                if(index==0)
                    index = 10;
                end
                cellNumber = str2num(inputString((commaLocations(m)+1):(commaLocations(m+1)-2)));
                array1to10(index) = cellNumber(1);
            end
        end
        index = str2num(inputString(commaLocations(end)-1));
        if index == 0
            index = 10;
        end
        lastNum = str2num(inputString((commaLocations(end)+1):end));
        array1to10(index) = lastNum;
    end
end
end

