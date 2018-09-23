function [EEG_out, EOG_out] = perform_cleanrawdata(EEG_in, EOG_in, varargin)
% perform_cleanrawdata makes channel rejection using cleanrawdata()
%   This function does not change the output values if and only if
%   BurstCriterion and WindowCriterion are deactiavted (it is the case by 
%   default). In this case, only indices of the bad channels are kept to 
%   be removed in a later step of the preprocessing. If the two mentiond 
%   criteria are selected however, the channels are already removed, data 
%   is cleaned and high passed filtered as specified in cleanrawdata(), 
%   and noisy windows are removed. Then the same time windows are removed 
%   from the EOG data for coherence and possibe further EOG regression
%   which requires same length signals.
%   
%   [EEG_out, EOG_out] = perform_cleanrawdata(EEG_in, EOG_in, varargin)
%
%   EEG_in is the input EEG structure.
%
%   EOG_in is the input EOG structure.
%
%   varargin is an optional structure required as in cleanrawdata()
%
%   If params is ommited default values are used.
%
%   Default values are specified by cleanrawdata().
%
% Copyright (C) 2017  Amirreza Bahreini, amirreza.bahreini@uzh.ch
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

EEG_out = EEG_in;
EOG_out = EOG_in;
EEG_out.automagic.asr.performed = 'no';
if isempty(varargin{:})
    return; end

defaults = DefaultParameters.ASRParams;
p = inputParser;
addParameter(p,'ChannelCriterion', defaults.ChannelCriterion);
addParameter(p,'LineNoiseCriterion', defaults.LineNoiseCriterion);
addParameter(p,'BurstCriterion', defaults.BurstCriterion);
addParameter(p,'WindowCriterion', defaults.WindowCriterion);
addParameter(p,'Highpass', defaults.Highpass);  
parse(p, varargin{:});
params.ChannelCriterion = p.Results.ChannelCriterion;
params.LineNoiseCriterion = p.Results.LineNoiseCriterion;
params.BurstCriterion = p.Results.BurstCriterion;
params.WindowCriterion = p.Results.WindowCriterion;
params.Highpass = p.Results.Highpass; %#ok<STRNU>

toRemove = EEG_in.automagic.preprocessing.toRemove;
removedMask = EEG_in.automagic.preprocessing.removedMask;
badChans = [];

fprintf('Detecting bad channels using routines of clean_raw_data()...\n');
[~, EEGCleaned] = evalc('clean_artifacts(EEG_in, params)');

% If only channels are removed, remove them from the original EEG so
% that the effect of high pass filtering is not there anymore
newToRemove = toRemove;
if(isfield(EEGCleaned, 'etc'))
    etcfield = EEGCleaned.etc;
    if(isfield(EEGCleaned.etc, 'clean_channel_mask'))
        newMask = removedMask;
        oldMask = removedMask;
        newMask(~newMask) = ~etcfield.clean_channel_mask;
        badChans = setdiff(find(newMask), find(oldMask));

        newToRemove = union(toRemove, badChans);
    end
    EEG_out.etc = etcfield;

    % Remove the same time-windows from the EOG channels
   if(isfield(EEGCleaned.etc, 'clean_sample_mask'))
       EEG_out = EEGCleaned;

       if(isfield(EEGCleaned.etc, 'clean_channel_mask'))
            removedMask = newMask;
            newToRemove = toRemove;
        end

       removed = EEGCleaned.etc.clean_sample_mask;
       firsts = find(diff(removed) == -1) + 1;
       seconds = find(diff(removed) == 1);
       if(removed(1) == 0)
           firsts = [1, firsts];
       end
       if(removed(end) == 0)
           seconds = [seconds, length(removed)];
       end
       remove_range = [firsts; seconds]'; %#ok<NASGU>
       [~, EOG_out] = evalc('pop_select(EOG_in, ''nopoint'', remove_range)');
   end
end

% Add the info to the output structure
EEG_out.automagic.asr.performed = 'yes';
EEG_out.automagic.asr.badChans = badChans;
EEG_out.automagic.preprocessing.toRemove = newToRemove;
EEG_out.automagic.preprocessing.removedMask = removedMask;