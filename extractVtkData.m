function [Pos, cellRank, ExtForce] = extractVtkData(fr, dirName)
% settings = prepareWorkspace();

fnum = sprintf('%5.5d', fr);
fileformat = '.vtk';
fname = [dirName, fnum, fileformat];
fID = fopen(fname);

Pos = [];
tline = fgetl(fID);

isReading = 1;
isWriting = 0;
while ischar(tline)
    
    %disp(tline);
    if ( strfind(tline, 'POINTS'))
        isWriting = 1;
        %disp('here');
    end
    
    tline = fgetl(fID);
    
    if (isWriting )
        A = str2num(tline);
        if (size(A)==[1,3])
            Pos = [Pos; A];
        end
    end
    
    
    if (strfind(tline, 'CELLS'))
        isReading = 0;
        isWriting = 0;
    end
    
    if (~isReading && ~isWriting)
        break;
    end  
        
        %pause;
end

fclose(fID);



fID = fopen(fname);

cellRank = [];
tline = fgetl(fID);

isReading = 1;
isWriting = 0;
while ischar(tline)
    
    %disp(tline);
    if ( strfind(tline, 'cellRank'))
        tline = fgetl(fID);
        isWriting = 1;
        %disp('here');
    end
    
    tline = fgetl(fID);
    
    if (isWriting )
        B = str2num(tline);
        %if (size(A)==[1,3])
       % B
            cellRank = [cellRank; B];
        %end
    end
    
    
    if (strfind(tline, 'tension'))
        isReading = 0;
        isWriting = 0;
    end
    
    if (~isReading && ~isWriting)
        break;
    end  
        
        %pause;
end

fclose(fID);


fID = fopen(fname);

ExtForce = [];
tline = fgetl(fID);

isReading = 1;
isWriting = 0;
while ischar(tline)
    
    %disp(tline);
    if ( strfind(tline, 'ExternalForce'))
        isWriting = 1;
       % disp('here');
    end
    
    tline = fgetl(fID);
    
    if (~ischar(tline))
        isReading = 0;
        isWriting = 0;
    end
    
    if (isWriting )
        A = str2num(tline);
        if (size(A)==[1,3])
            ExtForce = [ExtForce; A];
            
        end
    end
    
    
    
    if (~isReading && ~isWriting)
        break;
    end  
        
        %pause;
end

fclose(fID);

end