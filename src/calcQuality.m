function Q = calcQuality(EEG, bad_chans, varargin)
% Calculates quality measures of a dataset based on the following metrics:
%
% -  The ratio of data points that exceed the absolute value a certain
%    voltage amplitude (OHA)
% -  The ratio of time points in which % the standard deviation of the
%    voltage measures across all channels
%    exceeds a certain threshold (THV)
% -  The ratio of channels in which % the standard deviation of the voltage
%    measures across all time points exceeds a certain threshold (CHV)
% -  unthresholded mean absolute voltage of the dataset (MAV)
%
%   The input is an EEG structure with optional parameters that can be
%   passed within a structure: (e.g. struct('overallThres',50))
%
%   'overallThresh' - threshold of absolute amplitude [50] mV for OHA
%   'timeThresh'    - threshold of standard deviation [25] mV for THV
%   'chanThresh'    - threshold of standard deviation [25] mV for CHV
%
%    Options not modifiable from the GUI of Automagic:
%
%   'avRef'         - If no average reference should be used set this
%                     option to 0 [1]
%   'plotFig'       - When set to 1, plots a figure with the Quality
%                     measures [0]
%   'saveFig'       - When 1, saves the figure to the plotFileName [0]
%   'plotFileName'  - file name of figure to be saved {''}
%
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

%% Parse and check parameters
defaults = ConstantGlobalValues.default_visualisation_params.calcQuality_params;

p = inputParser;

addParameter(p,'overallThresh', defaults.overallThresh,@isnumeric );
addParameter(p,'timeThresh', defaults.timeThresh,@isnumeric );
addParameter(p,'chanThresh', defaults.chanThresh,@isnumeric );

addParameter(p,'plotFileName', defaults.plotFileName,@isstr );
addParameter(p,'plotFig', defaults.plotFig,@isnumeric );

addParameter(p,'saveFig', defaults.saveFig,@isnumeric );
addParameter(p,'avRef', defaults.avRef,@isnumeric );

parse(p, varargin{:});
settings = p.Results;

if nargin < 1
    disp('No data to rate')
elseif nargin < 2
    disp('No bad channel information...')
end
%% Data preparation
% Data
X = EEG.data;
% Get dimensions of data
t = size(X,2);
c = size(X,1);

% average reference
if settings.avRef 
X = X - repmat(nanmean(X,1),c,1);
end
%% Calculate the quality metrics

% overall ratio of timepoints of high amplitude
OHA = nansum(abs(X(:)) > settings.overallThresh)./(t.*c);

% ratio of timepoints of high variance
THV = nansum(std(X,[],1) > settings.timeThresh)./t;

% ratio of channels that have been interpolated
RBC = numel(bad_chans)./c;

% ratio of channels with high variance

% get index for plotting...
CIX = find(nanstd(X,[],2) > settings.chanThresh);
% get the number of channels above threshold...
CHV = numel(find(nanstd(X,[],2) > settings.chanThresh))./c;

% unthresholded mean absolute voltage
MAV = nanmean(abs(X(:)));

%% for future versions: calculate the crosss correlation between interpolated and original template maps
% apply the interpolation of the bad channels to a set of templates
% EEGtemplateMapsInterpolated = pop_interp(EEGtemplateMaps,bad_chans,'spherical');
% calculate the correlation between the template Maps and the interpolated
% maps
% CrossCorr = diag(corr(EEGtemplateMaps.data,EEGtemplateMapsInterpolated.data));
% P90 = prctile(CrossCorr,90);

%% Optional Plotting
thrOHA = reshape(abs(X(:)) > settings.overallThresh,c,t);

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

%% Output
% quality metrics
Q.OHA = OHA;
Q.THV = THV;
Q.CHV = CHV;
Q.MAV = MAV;
Q.RBC = RBC; 
end