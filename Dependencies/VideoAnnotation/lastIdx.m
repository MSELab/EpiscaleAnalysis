function idx = lastIdx(path)
list = dir(path.Animation);
idx = 0;
for i = 1:length(list)
    tmppath = [path.Animation processDatafileName(path.nameStructure, i)];
    if exist(tmppath, 'file')
        idx = i;
    else
        break
    end
end