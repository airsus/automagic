function EEG_out = high_variance_channel_rejection(EEG_in, varargin)
% high_variance_channel_rejection   reject bad channels based on standard
%   deviation
%   rejected = high_variance_channel_rejection(EEG, params)
%   where rejected is a list of channels that must be removed. EEG is a
%   EEGLAB data structure. params is an optional argument with optional
%   field 'sd' to specify the threshold.
%   When params is ommited default values are used. When a field of params 
%   is ommited, default value for that field is used. 
%   Default values: params.sd = 3
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

defaults = DefaultParameters.highvar_params;
p = inputParser;
addParameter(p,'sd', defaults.sd, @isnumeric);
parse(p, varargin{:});
sd_threshold = p.Results.sd;

removed_mask = EEG_in.automagic.preprocessing.removed_mask;

[s, ~] = size(EEG_in.data);
bad_chans_mask = false(1, s); clear s;

EEG_out = EEG_in;
EEG_out.automagic.highvariance_rejection.performed = 'no';
rejected = find(nanstd(EEG_in.data,[],2) > sd_threshold);

[~, EEG_out] = evalc('pop_select(EEG_in, ''nochannel'', rejected)');

bad_chans_mask(rejected) = true;
new_mask = removed_mask;
old_mask = removed_mask;
new_mask(~new_mask) = bad_chans_mask;
bad_chans = setdiff(find(new_mask), find(old_mask));
removed_mask = new_mask; 

EEG_out.automagic.highvariance_rejection.performed = 'yes';
EEG_out.automagic.highvariance_rejection.bad_chans = bad_chans;
EEG_out.automagic.preprocessing.removed_mask = removed_mask;

