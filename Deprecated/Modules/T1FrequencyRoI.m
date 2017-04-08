function [ varargout ] = T1FrequencyRoI( varargin )
% Input cell arrays for the positions of T1 transitions and all cells.
% Calculate the frequency of T1 transitions.
%
% [ T1perHour, R2, startTime, endTime, T1InRange ] = T1FrequencyRoI( T1Position, position )
% [ T1perHour ] = T1FrequencyRoI( T1Position, position, edgeCell )
% [ T1perHour ] = T1FrequencyRoI( T1Position, position, edgeCell, T1Settings )
%

T1Settings.simulationTimescale = 100 / 2000; % 100 hours per 2000 timesteps

% For RoI analysis
T1Settings.startTime = 1300;
T1Settings.endTime = 1600;
T1Settings.regionOfInterest = 4;

% For cell number analysis
T1Settings.analysisTime = 5000;
T1Settings.minimumTime = 500;
T1Settings.minCellNumber = 75;
T1Settings.cellsToAnalyze = 60;

switch nargin
    case 2
        T1Position = varargin{1};
        position = varargin{2};
        edgeCell = [];
    case 3
        T1Position = varargin{1};
        position = varargin{2};
        edgeCell = varargin{3};
    case 4
        T1Position = varargin{1};
        position = varargin{2};
        edgeCell = varargin{3};
        importedSettings = varargin{4};
        T1Settings = catstruct(T1Settings, importedSettings);
end

T1perHour = NaN;
R2 = NaN;
startTime = T1Settings.startTime;
endTime = T1Settings.endTime;

if isempty(T1Position) || isempty(position) % Make sure data is present
    disp('No data present');
    return
end

if isempty(edgeCell) % If edge cells not supplied, go by distance RoI
    
    for t = startTime:endTime
        
        cellPositions = position{t};
        T1Positions = T1Position{t};
        maxR = max(cellPositions);
        if length(T1Positions) > 10
            error('Too many T1 transitions')
        end
        
        % Break simulation if RoI is too small
        if maxR < T1Settings.regionOfInterest
            %         warning('disc is too small');
            return
        end
        if isempty(T1Positions)
            T1InRange(t) = 0;
        else
            T1InRange(t) = sum(T1Positions < T1Settings.regionOfInterest);
        end
    end
    
else % If edge cells  supplied, go by cell number
    
    startTime = length(position);
    endTime = length(position) - 1;
    for t = 1:length(position) % Find the start and end of analysis
        cellPositions = position{t};
        edgeCells = edgeCell{t};
        cellNumber = length(cellPositions) - sum(edgeCells);
        
        if cellNumber >= T1Settings.minCellNumber
            startTime = t;
            endTime = min([t+T1Settings.analysisTime, length(position)]);
            break
        end
    end
    
    for t = startTime:endTime
        cellPositions = position{t};
        T1Positions = T1Position{t};
        sortedPositions = sort(cellPositions);
        positionCutoff = sortedPositions(T1Settings.cellsToAnalyze);
        if isempty(T1Positions)
            T1InRange(t) = 0;
        else
            T1InRange(t) = sum(T1Positions < positionCutoff);
        end
    end
    
end

if (endTime - startTime) < T1Settings.minimumTime
    disp(['Simulation too short (last time: ' num2str(endTime) ')']);
    varargout{1} = T1perHour;
    varargout{2} = R2;
    varargout{3} = startTime;
    varargout{4} = endTime;
    varargout{5} = -1;
    return
end

r2Temp = fitlm(startTime:endTime,cumsum(T1InRange(startTime:endTime)));
R2 = r2Temp.Rsquared.Ordinary;

analysisTimeInHours = (endTime - startTime) * T1Settings.simulationTimescale;
T1perHour = sum(T1InRange(startTime:endTime)) / analysisTimeInHours;

varargout{1} = T1perHour;
varargout{2} = R2;
varargout{3} = startTime;
varargout{4} = endTime;
varargout{5} = T1InRange;


end

