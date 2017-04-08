settings = prepareWorkspace();

% Get the first 
fileData =  dir([settings.inDetailsDir,'*00000*']);
labels = {fileData.name}';
copies = cellfun(@(str) strfind(str, '('), labels,'UniformOutput',false);
copyIndex = cellfun(@(cell) isempty(cell), copies, 'UniformOutput',false);
copyLabels = labels(~cell2mat(copyIndex));

copyBaseLabels = regexprep(copyLabels, '_00000 \(\w\).txt','');
copyBaseLabels = regexprep(copyBaseLabels, 'detailedStat_','');
copyBaseLabels = unique(copyBaseLabels')';

for i = copyBaseLabels'
    fileData =  dir([settings.inAnimationDir '*' i{1} '*.vtk']);
    filesToMove = {fileData.name};
    for j = filesToMove
        source = [settings.inAnimationDir j{1}];
        destination = [settings.archiveCopyVTK j{1}];
        movefile(source, destination);
        disp(['Moved ' j{1} ' successfully']);
    end
end