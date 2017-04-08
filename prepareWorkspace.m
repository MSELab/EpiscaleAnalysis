function settings = prepareWorkspace(settings)
% Run this at the beginning of each Epi-Stim simulation post-processing
% script. This identifies the dependancy folders, and sets folders for
% inputs and output.

close all
fclose('all');
if nargin < 1
    settings = getSettings();
end
cd(settings.activeDir);

% Add dependancy folders to path
addpath(genpath(settings.depExt), genpath(settings.depInt));

end