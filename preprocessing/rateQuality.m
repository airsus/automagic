function R = rateQuality (Q, varargin)
% rates datasets, based on quality measures calculated with calcQuality()
% Inputs: A structure Q with the following fields:

% OHA   - The ratio of data points that exceed the absolute value a certain
%         voltage amplitude
% THV   - The ratio of time points in which % the standard deviation of the
%         voltage measures across all channels exceeds a certain threshold
% CHV   - The ratio of channels in which % the standard deviation of the
%         voltage measures across all time points exceeds a certain threshold
% MAV   - unthresholded mean absolute voltage of the dataset (not used in
%         the current version)
%
%   The input is an EEG structure with optional parameters that can be
%   passed within a structure: (e.g. struct('',50))
%   'Qmeasures'           - a cell array indicating on which metrics the
%                           datasets should be rated {'OHA','THV','CHV'}
%   'overallGoodCutoff'   - cutoff for "Good" quality based on OHA [0.1]
%   'overallBadCutoff'    - cutoff for "Bad" quality based on OHA [0.2]
%   'timeGoodCutoff'      - cutoff for "Good" quality based on THV [0.1]
%   'timeBadCutoff'       - cutoff for "Bad" quality based on THV [0.2]
%   'channelGoodCutoff'   - cutoff for "Good" quality based on CHV [0.15]
%   'channelBadCutoff'    - cutoff for "Bad" quality based on CHV [0.3]
%
% Copyright (C) 2018  Andreas Pedroni, anpedroni@gmail.com
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
% Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
defaults = DefaultParameters.rateQuality_params;

p = inputParser;
addParameter(p,'overallGoodCutoff', defaults.overallGoodCutoff,@isnumeric );
addParameter(p,'overallBadCutoff', defaults.overallBadCutoff,@isnumeric );

addParameter(p,'timeGoodCutoff', defaults.timeGoodCutoff,@isnumeric );
addParameter(p,'timeBadCutoff', defaults.timeBadCutoff,@isnumeric );

addParameter(p,'channelGoodCutoff', defaults.channelGoodCutoff,@isnumeric );
addParameter(p,'channelBadCutoff', defaults.channelBadCutoff,@isnumeric );

addParameter(p,'Qmeasure', defaults.Qmeasure, @isstr );

parse(p, varargin{:});
settings = p.Results;

if nargin < 1
    disp('No quality metrics to base a rating on')
end

%% create empty cells
ratingO = {};
ratingC = {};
ratingT = {};

% Categorize wrt OHA

if any(strfind(settings.Qmeasure,'OHA'))
    if Q.OHA < settings.overallGoodCutoff
        ratingO = 'good' ;
    elseif Q.OHA >= settings.overallGoodCutoff && Q.OHA < settings.overallBadCutoff
        ratingO = 'ok'  ;
    else
        ratingO = 'bad'  ;
    end
end

% Categorize wrt THV
if any(strfind(settings.Qmeasure,'THV'))
    if Q.THV < settings.timeGoodCutoff
        ratingT = 'good' ;
    elseif Q.THV >= settings.timeGoodCutoff && Q.THV < settings.timeBadCutoff
        ratingT = 'ok'  ;
    else
        ratingT = 'bad'  ;
    end
end

% Categorize wrt CHV
if any(strfind(settings.Qmeasure,'CHV'))
    if Q.CHV < settings.channelGoodCutoff
        ratingC = 'good' ;
    elseif Q.CHV >= settings.channelGoodCutoff && Q.CHV < settings.channelBadCutoff
        ratingC = 'ok'  ;
    else
        ratingC = 'bad'  ;
    end
end


%% combine ratings with the rule that the rating depends on the worst rating

if ismember('bad',[ratingO,ratingT,ratingC])
    rating = 'bad';
elseif ismember('ok',[ratingO,ratingT,ratingC])
    rating = 'ok';
else
    rating = 'good';
end

%% Output
R.rating = rating;

R.Qmeasure = settings.Qmeasure;
R.overallGoodCutoff = settings.overallGoodCutoff;
R.overallBadCutoff = settings.overallBadCutoff;
R.timeGoodCutoff = settings.timeGoodCutoff;
R.timeBadCutoff = settings.timeBadCutoff;
R.channelGoodCutoff = settings.channelGoodCutoff;
R.channelBadCutoff = settings.channelBadCutoff;
R.Q = Q; % here are the parameters of the calcQuality. don't know if this should be here?
end