% Loads data for experiment label. Specific fields include:
% rawDetails
% neighbors
% cellCenters
% edgeCell
% polyClass
% cellArea
% cellPerimeter
% growthProgress
% memNodes
% intNodes
% cellNumber

function [data, flag] = getData(label, fields, settings)
if nargin < 2
    fields = {};
end
if nargin < 3
    settings = getSettings;
end

% Obtain path information
pathDatafile = strrep(settings.thruData, '$', label);

if ~exist(pathDatafile, 'file')
    flag = 0;
    data = [];
    return
end

if ~isempty(fields)
    data = load(pathDatafile, fields{:});
else
    data = load(pathDatafile);
end

flag = 1;