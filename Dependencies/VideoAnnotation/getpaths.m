function [path, flag] = getpaths(settings, label)

path.Animation = strrep(settings.thruAnimation, '$', label);
path.Annotation = strrep(settings.thruAnnotation, '$', label);
path.Video = strrep(settings.outAnimation, '$', label);
path.Data = strrep(settings.thruData, '$', label);
path.T1 = strrep(settings.thruT1, '$', label);
mkdir(path.Annotation);

list = dir(path.Animation);
idx = find(contains({list.name},'0.png'));
idx = idx(1);

if isempty(idx)
    flag = -1;
    disp(['Data not found for ' label])
    return
end

% Lazy method for determining number of zeros
zeroIdx{1} = strfind(list(idx).name, '00000.png');
zeroIdx{2} = strfind(list(idx).name, '0000.png');
zeroIdx{3} = strfind(list(idx).name, '000.png');
zeroIdx{4} = strfind(list(idx).name, '00.png');
zeroIdx{5} = strfind(list(idx).name, '0.png');

forms = find(~cellfun('isempty',zeroIdx));

switch forms(1)
    case 1
        path.nameStructure = strrep(list(idx).name, '00000.png', 'xxxxx.png');
    case 2
        path.nameStructure = strrep(list(idx).name, '0000.png', 'xxxx.png');
    case 3
        path.nameStructure = strrep(list(idx).name, '000.png', 'xxx.png');
    case 4
        path.nameStructure = strrep(list(idx).name, '00.png', 'xx.png');
    case 5
        path.nameStructure = strrep(list(idx).name, '0.png', 'x.png');
    otherwise
        flag = -3;
        disp(['Naming pattern not found for: ' label])
        return
end

flag = 1;