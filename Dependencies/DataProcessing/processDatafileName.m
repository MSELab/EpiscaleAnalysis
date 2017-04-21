function [ processedName ] = processDatafileName( baseName, timepoint )
% This function converts the base-names generated in getLabels to a
% filename at a specific timepoint for Epi-Scale datafiles.

processedName = strrep(baseName, 'xxxxx', num2str(timepoint, '%05d'));
processedName = strrep(processedName, 'xxxx', num2str(timepoint, '%04d'));
processedName = strrep(processedName, 'xxx', num2str(timepoint, '%03d'));
processedName = strrep(processedName, 'xx', num2str(timepoint, '%02d'));
processedName = strrep(processedName, 'x', num2str(timepoint, '%01d'));

end

