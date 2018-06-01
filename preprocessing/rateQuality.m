function Q = rateQuality(EEG,auto_badchans,man_badchans,varargin)
%   Rate the overall quality of a dataset,based on different / a combination of parameters
%   The input is an EEG structure with optional parameters:
%   
%   If varargin is ommited, default values are used. If any fields of
%   varargin is ommited, corresponsing default value is used.
%
%   Default values: params.chanloc_map = containers.Map (empty map)
%
% Copyright (C) 2018  Amirreza Bahreini, amirreza.bahreini@uzh.ch
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
tic()
defaults = DefaultParameters.qualityRating_params;

%% Parse and check parameters
p = inputParser;
addParameter(p,'overallThresh', defaults.overallThresh,@isnumeric );
addParameter(p,'overallGoodCutoff', defaults.overallGoodCutoff,@isnumeric );
addParameter(p,'overallBadCutoff', defaults.overallBadCutoff,@isnumeric );

addParameter(p,'timeThresh', defaults.timeThresh,@isnumeric );
addParameter(p,'timeGoodCutoff', defaults.timeGoodCutoff,@isnumeric );
addParameter(p,'timeBadCutoff', defaults.timeBadCutoff,@isnumeric );

addParameter(p,'chanThresh', defaults.chanThresh,@isnumeric );
addParameter(p,'channelGoodCutoff', defaults.channelGoodCutoff,@isnumeric );
addParameter(p,'channelBadCutoff', defaults.channelBadCutoff,@isnumeric );

addParameter(p,'Qmeasure', defaults.Qmeasure,@isstr );

addParameter(p,'plotFileName', defaults.plotFileName,@isstr );
addParameter(p,'plotFig', defaults.plotFig,@isnumeric );

addParameter(p,'saveFig', defaults.saveFig,@isnumeric );
addParameter(p,'avRef', defaults.avRef,@isnumeric );
addParameter(p,'cutFirstMarker', defaults.cutFirstMarker,@isnumeric );


parse(p, varargin{:});
settings = p.Results;

if nargin < 1
           disp('No data to rate')
elseif nargin < 2
            disp('No bad channel information...')
end

% Data
X = EEG.data;
% Get dimensions of data
t = size(X,2);
c = size(X,1);

% average reference
X = X - repmat(mean(X,1),c,1);

%% THRESHOLD APPROACH
% overall percentage of timepoints of high amplitude
OHA = sum(abs(X(:)) > settings.overallThresh)./(t.*c);

% percentage of timepoints of high variance
THV = sum(std(X,[],1) > settings.timeThresh)./t;

% percentage of channels that have been interpolated
bad_chans = setxor(auto_badchans,man_badchans); 

nCH = numel(bad_chans)./c; 

% standard deviation over channels
% get index for plotting... 
CIX = find(std(X,[],2) > settings.chanThresh); 
% get the number of channels above threshold... 
CHV = numel(find(std(X,[],2) > settings.chanThresh))./c; 

%% for future versions: calculate the crosss correlation between interpolated and original template maps
% apply the interpolation of the bad channels to a set of templates
% EEGtemplateMapsInterpolated = pop_interp(EEGtemplateMaps,bad_chans,'spherical');
% calculate the correlation between the template Maps and the interpolated
% maps
% CrossCorr = diag(corr(EEGtemplateMaps.data,EEGtemplateMapsInterpolated.data));
%P90 = prctile(CrossCorr,90);


%% Quality Rating
ratingO = {};
if ismember('OHA',settings.Qmeasure)
    if OHA < settings.overallGoodCutoff
        ratingO = 'good' ;
    elseif OHA >= settings.overallGoodCutoff && OHA < settings.overallBadCutoff
        ratingO = 'ok'  ;
    else
        ratingO = 'bad'  ;
    end
end

ratingT = {};
if ismember('THV',settings.Qmeasure)
    if THV < settings.timeGoodCutoff
        ratingT = 'good' ;
    elseif THV >= settings.timeGoodCutoff && THV < settings.timeBadCutoff
        ratingT = 'ok'  ;
    else
        ratingT = 'bad'  ;
    end
end

ratingC = {};
if ismember('CHV',settings.Qmeasure)
    if CHV < settings.channelGoodCutoff
        ratingC = 'good' ;
    elseif CHV >= settings.channelGoodCutoff && CHV < settings.channelBadCutoff
        ratingC = 'ok'  ;
    else
        ratingC = 'bad'  ;
    end
end

%% combine the ratings into one rating...

if ismember('bad',[ratingO,ratingT,ratingC])
    rating = 'bad';
elseif ismember('ok',[ratingO,ratingT,ratingC])
    rating = 'ok';
else
    rating = 'good';
end


%% Plotting
thrOHA = reshape(abs(X(:)) > settings.overallThresh,c,t); 

% histogram(std(EEG.EEG.data,[],1))
if settings.plotFig == 1
    
    figure('pos',[0 0 1000 500])
    subplot(2,1,1)
    % Original data
    imagesc(X,[-100  100])
    colormap('jet')
    xlabel('time')
    ylabel('channels')
    
    % Quality Measures
    subplot(2,1,2)
    
    hold on
    % time windows red
    bar((std(X,[],1) > settings.timeThresh).*c,'r')
    
    im = image(double(thrOHA));
    im.AlphaData = double(thrOHA==1);
    
    % channels over threshold
    if ~isempty(CIX)
        plot([0 t],[CIX CIX],'g')
    end
    
    if ~isempty(bad_chans)
        plot([0 t],[bad_chans bad_chans],'m')
    end
    
    ylim([0,c])
    axis ij
    xlabel('time')
    ylabel('channels')
    
    if settings.saveFig == 1
        saveas(gcf,[settings.plotFileName '.png']);
        close(gcf)
    end
    
end

%% SUM APPROACH
% unthresholded mean absolute voltage
MAV = mean(abs(X(:)));


%% Output
Q.rating = rating;
Q.Qmeasure = settings.Qmeasure;
Q.overallThresh = settings.overallThresh;
Q.timeThresh = settings.timeThresh;
Q.chanThresh = settings.chanThresh;

Q.OHA = OHA;
Q.THV = THV;
Q.CHV = CHV;
Q.MAV = MAV;
%Q.P90 = P90; 

Q.overallGoodCutoff = settings.overallGoodCutoff;
Q.overallBadCutoff = settings.overallBadCutoff;
Q.timeGoodCutoff = settings.timeGoodCutoff;
Q.timeBadCutoff = settings.timeBadCutoff;
Q.channelGoodCutoff = settings.channelGoodCutoff;
Q.channelBadCutoff = settings.channelBadCutoff;
toc()
end