function rejected = high_variance_channel_rejection(EEG, varargin)
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

data = EEG.data;
rejected = find(nanstd(data,[],2) > sd_threshold);

