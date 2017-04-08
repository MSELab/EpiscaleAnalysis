function varargout = getLabels(varargin)
% This function is used to generate a list of filenames for analysis of
% Epi-Stim simulation output.
% dataType: [1] = polygon, 2 = datafile, 3 = .mat file
% if searchTerms is empty, return all unique hits, otherwise, only those
% with the text term. (default is empty)

% labels = getLabels(settings)
% labels = getLabels(settings)
% labels = getLabels(settings, searchTerms)
% labels = getLabels(settings, searchTerms, dataType)
% [labels labelIndices] = getLabels(__)

% Parse inputs
switch nargin
    case 0
        settings = prepareWorkspace();
        searchTerms = {};
        dataType = 1;
    case 1
        settings = varargin{1};
        searchTerms = {};
        dataType = 1;
    case 2
        settings = varargin{1};
        searchTerms = varargin{2};
        dataType = 1;
    case 3
        settings = varargin{1};
        searchTerms = varargin{2};
        dataType = varargin{3};
end

if ~isstruct(settings)
    error('Settings must be a structure')
end

% Handle single-string searches
if ~iscell(searchTerms)
    searchTerms = {searchTerms};
end

switch dataType
    case 1 % find polygon-class text files
        labels =  dir(settings.inPolyDir);
        labels = [{labels.name}];
        dataFiles = cellfun(@(str) strfind(str, '.txt'), labels,'UniformOutput',false);
        dataFiles = cellfun(@(cell) isempty(cell), dataFiles, 'UniformOutput',false);
        labels(cell2mat(dataFiles)) = [];
        labels = unique(labels')';
        
    case 2 % find initial time-point of datafiles
        fileData =  dir([settings.inDetailsDir,'*00000*.txt']);
        labels = {fileData.name}';
        labels = cellfun(@(str) strrep(str, '00000','xxxxx'), labels,'UniformOutput',false);
        
    case 3 % find .mat files without errors
        load(settings.matLog, 'simulationLog');
        labels = {simulationLog.Name}';
%         errors = {simulationLog.Error};
%         noError = ~cell2mat(cellfun(@(cell) isempty(cell), errors, 'UniformOutput',false));
%         labels(noError) = [];
        
end

labelIndices = [];
% use search terms to extract only relevant simulations, or return all
% simulations
if ~isempty(searchTerms)
    releventIndices = [];
    numberOfIndices = 0;
    for i = 1:length(searchTerms)
        newIndices = find(~cellfun(@isempty,strfind(labels,searchTerms{i})))';
        releventIndices = [releventIndices newIndices];
        if numberOfIndices < numberOfIndices + length(newIndices)
            labelIndices((numberOfIndices+1):(numberOfIndices + length(newIndices))) = i;
            numberOfIndices = numberOfIndices + length(newIndices);
        end
    end
    labels = labels(releventIndices);
end

nOutputs = nargout;
switch nOutputs
    case 1
        varargout{1} = labels;
    case 2
        varargout{1} = labels;
        varargout{2} = labelIndices;
end

end

