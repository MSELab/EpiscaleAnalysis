function [ simulatonArray, T1Pos, cellPos ] = convertSimtoArrayWithT1( namingConvention, initialTime )
% This converts Epi-Scale simulation datafiles into MATLAB structures,
% starting at the initial time and ending with the last simulation file.

t = initialTime;
fileName = processDatafileName(namingConvention, t);
while exist(fileName, 'file')
    % Extract data at specific time
    simulatonArray{t + 1} = parseDatafile(fileName);
    
    % Prepare for next timestep
    t = t + 1;
    fileName = processDatafileName(namingConvention, t);
end

end

