close all

folder = 'I:\Project 2 Episcale\SimulationRawOutput\DetailedStats\';
files = dir(folder);

files(1:2) = [];
names = {files.name};
bytes = [files.bytes];

decreasingSize = gradient(bytes) > 0;

for i = find(bytes <= 0)
    i
    copyfile([folder names{i-1}],[folder names{i}])
%     tmpName = names{i};
%     numbers(i) = str2num(tmpName(21:25));
end
% 
% a = 1:length(names);
% 
% plot(a ./ (numbers + 1))