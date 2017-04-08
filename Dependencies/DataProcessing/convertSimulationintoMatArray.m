function [ simulatonArray ] = convertSimulationintoMatArray( namingConvention, initialTime )
% This converts Epi-Scale simulation datafiles into MATLAB structures,
% starting at the initial time and ending with the last simulation file.

if nargin < 2
    initialTime = 0;
end

t = initialTime;
fileName = processDatafileName(namingConvention, t);
while exist(fileName, 'file')
    % Break for empty files
    list = dir(fileName);
    if list.bytes <= 0
       break 
    end
    
    % Extract data at specific time
    simulatonArray{t + 1} = parseDatafile(fileName);
    
    % Prepare for next timestep
    t = t + 1;
    fileName = processDatafileName(namingConvention, t);
end

end

