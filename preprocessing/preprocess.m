function [EEG, varargout] = preprocess(data, varargin)
% preprocess  preprocess the data 
%   [result, fig] = preprocess(data, varargin)
%   where data is the EEGLAB data structure and varargin is an 
%   optional parameter which must be a structure with optional fields 
%   'filter_params', 'asr_params', 'pca_params', 'ica_params'
%   'interpolation_params', 'eog_regression_params', 'eeg_system', 
%   'channel_reduction_params' and 'original_file' to specify parameters for 
%   filtering, channel rejection, pca, ica, interpolation, EOG regression, 
%   channel locations, reducing channels and original file address 
%   respectively. The latter one is needed only if a '*.fif' file is used,
%   otherwise it can be omitted.
%   
%   To learn more about 'filter_params', 'ica_params' and 'pca_params' 
%   please see their corresponding functions perform_filter.m, 
%   perform_ica.m and perform_pca.m.
%
%   'asr_params' is an optional structure which has the same parameters as 
%   required by clean_artifacts(). For more information please
%   see clean_artifacts() in Artefact Subspace Reconstruction.
%   
%   'interpolation_params' is an optional structure with an optional field
%   'method' which can be on of the following chars: 'spherical',
%   'invdist' and 'spacetime'. The default value is
%   interpolation_params.method = 'spherical'. To learn more about these
%   three methods please see eeg_interp.m of EEGLAB.
%   
%   'eog_regression_params' has a field 'perform_eog_regression' that 
%   must be a boolean indication whether to perform EOG Regression or not. 
%   The default value is 'eog_regression_params.perform_eog_regression = 1'
%   which performs eog regression. The other field 
%   'eog_regression_params.eog_chans' must be an array of numbers 
%   indicating indices of the EOG channels in the data.
%   
%   'channel_reduction_params.perform_reduce_channels' must be a boolean 
%   indicating whether to reduce the number of channels or not. The 
%   default value is 'channel_reduction_params.perform_reduce_channels = 1'
%   'channel_reduction_params.tobe_excluded_chans' must be an array of 
%   numbers indicating indices of the channels to be excluded from the 
%   analysis
%   
%   'original_file' is necassary only in case of '*.fif' files. In that case,
%   this should be the address of the file where this EEG data is loaded
%   from.
%   
%   eeg_system must be a structure with fields 'name', 'sys10_20', 'ref_chan', 
%   'loc_file' and 'file_loc_type'.  eeg_system.name can be either 'EGI' or 
%   'Others'. eeg_system.sys10_20 is a boolean indicating whether to use 
%   10-20 system to find channel locations or not. All other following 
%   fields are optional if eeg_system.name='EGI' and can be left empty. 
%   But in the case of eeg_system.name='Others':
%   eeg_system.ref_chan is the index of the reference channel in dataset. 
%   If it's left empty, a new reference channel will be added as the last 
%   channel of the dataset where all values are zeros and this new channel 
%   will be considered as the reference channel. If eeg_system.ref_chan == -1 
%   no reference channel is added and no channel is considered as reference 
%   channel at all. eeg_system.loc_file must be the name of the file located 
%   in 'matlab_scripts' folder that can be used by pop_chanedit to find 
%   channel locations and finally eeg_system.file_loc_type must be the type 
%   of that file. Please see pop_chanedit for more information. Obviously 
%   only types supported by pop_chanedit are supported.
%   
%   If varargin is ommited, default values are used. If any of the fields
%   of varargin are ommited, corresponsing default values are used. If a
%   structure is given as 'struct([])' then the corresponding operation is
%   omitted and is not performed; for example, ica_params = struct([])
%   skips the ICA and does not perform any ICA. Wheras if ica_params =
%   struct() if ica_params is simply not given, then the default value will
%   be used.
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

%% Parse arguments
defaults = DefaultParameters;
constants = PreprocessingConstants;
p = inputParser;
addParameter(p,'eeg_system', defaults.eeg_system, @isstruct);
addParameter(p,'filter_params', defaults.filter_params, @isstruct);
addParameter(p,'prep_params', defaults.prep_params, @isstruct);
addParameter(p,'asr_params', defaults.asr_params, @isstruct);
addParameter(p,'pca_params', defaults.pca_params, @isstruct);
addParameter(p,'highvar_params', defaults.highvar_params, @isstruct);
addParameter(p,'ica_params', defaults.ica_params, @isstruct);
addParameter(p,'interpolation_params', defaults.interpolation_params, @isstruct);
addParameter(p,'eog_regression_params', defaults.eog_regression_params, @isstruct);
addParameter(p,'channel_reduction_params', defaults.channel_reduction_params, @isstruct);
addParameter(p,'original_file', constants.general_constants.original_file, @ischar);
parse(p, varargin{:});
params = p.Results;
eeg_system = p.Results.eeg_system;
filter_params = p.Results.filter_params;
asr_params = p.Results.asr_params;
prep_params = p.Results.prep_params;
highvar_params = p.Results.highvar_params;
pca_params = p.Results.pca_params;
ica_params = p.Results.ica_params;
interpolation_params = p.Results.interpolation_params; %#ok<NASGU>
eog_regression_params = p.Results.eog_regression_params;
channel_reduction_params = p.Results.channel_reduction_params;
original_file_address = p.Results.original_file; %#ok<NASGU>
assert( isempty(ica_params) || isempty(pca_params), ...
    'Can not perform both ICA and PCA.');
clear p varargin;

% Add and download necessary paths
download_and_add_paths(struct('prep_params', prep_params, ...
                              'pca_params', pca_params));
                          
% Set system dependent parameters and eeparate EEG from EOG
[EEG_ref, EOG, eeg_system, ica_params] = ...
    system_dependent_params(data, eeg_system, channel_reduction_params, ...
    eog_regression_params, ica_params);


% Remove the reference channel from the rest of preprocessing
[~, EEG_orig] = evalc('pop_select(EEG_ref, ''nochannel'', eeg_system.ref_chan)');
EEG_orig.automagic.channel_reduction.new_ref_chan = eeg_system.ref_chan;

%% Preprocessing
[s, ~] = size(EEG_orig.data);
EEG_orig.automagic.preprocessing.to_remove = [];
EEG_orig.automagic.preprocessing.removed_mask = false(1, s); clear s;

% Robust Average Referecing with Prep
[~, EEG] = evalc('perform_prep(EEG_orig, prep_params, eeg_system.ref_chan)');

% Clean EEG using Artefact Supspace Reconstruction
[~, EEG, EOG] = evalc('perform_cleanrawdata(EEG, EOG, asr_params)');

% Filtering on the whole dataset
display(PreprocessingConstants.filter_constants.run_message);
EEG = perform_filter(EEG, filter_params);
EOG = perform_filter(EOG, filter_params);

% Remove channels
to_remove = EEG.automagic.preprocessing.to_remove;
removed_mask = EEG.automagic.preprocessing.removed_mask;
[~, new_to_remove] = intersect(find(~removed_mask), to_remove);
[~, EEG] = evalc('pop_select(EEG, ''nochannel'', new_to_remove)');
removed_mask(to_remove) = 1;
to_remove = [];
EEG.automagic.preprocessing.removed_mask = removed_mask;
EEG.automagic.preprocessing.to_remove = to_remove;
clear to_remove removed_mask new_to_remove;

% Remove effect of EOG
EEG.automagic.eog_regression.performed = 'no';
if( eog_regression_params.perform_eog_regression )
    EEG_regressed = EOG_regression(EEG, EOG);
else
    EEG_regressed = EEG;
end


% PCA or ICA
EEG_regressed.automagic.ica.performed = 'no';
EEG_regressed.automagic.pca.performed = 'no';
if ( ~isempty(ica_params) )
    try
        EEG_cleared = perform_ica(EEG_regressed, ica_params);
    catch ME
        message = ['ICA is not done on this subject, continue with the next steps: ' ...
            ME.message];
        warning(message)
        EEG_cleared = EEG_regressed;
        EEG_cleared.automagic.ica.performed = 'FAILED';
        EEG_cleared.automagic.error_msg = message;
    end
elseif ( ~isempty(pca_params))
    [EEG_cleared, pca_noise] = perform_pca(EEG_regressed, pca_params);
else
    EEG_cleared = EEG_regressed;
end


% detrending
doubled_data = double(EEG_cleared.data);
res = bsxfun(@minus, doubled_data, mean(doubled_data, 2));
singled_data = single(res);
detrended = EEG_cleared;
detrended.data = singled_data;
clear doubled_data res singled_data;

% Reject channels based on high variance
if ~isempty(highvar_params)
    [~, EEG] = evalc('high_variance_channel_rejection(EEG, highvar_params)');
end
% Put back removed channels
removed_chans = find(EEG.automagic.preprocessing.removed_mask);
for chan_idx = 1:length(removed_chans)
    chan_nb = removed_chans(chan_idx);
    EEG.data = [EEG.data(1:chan_nb-1,:); ...
                  NaN(1,size(EEG.data,2));...
                  EEG.data(chan_nb:end,:)];
    EEG.chanlocs = [EEG.chanlocs(1:chan_nb-1), ...
                      EEG_orig.chanlocs(chan_nb), EEG.chanlocs(chan_nb:end)];
end
% Put back refrence channel
ref_chan = eeg_system.ref_chan;
EEG.data = [EEG.data(1:ref_chan-1,:); ...
                        zeros(1,size(EEG.data,2));...
                        EEG.data(ref_chan:end,:)];
EEG.chanlocs = [EEG.chanlocs(1:ref_chan-1), EEG_ref.chanlocs(ref_chan), ...
                    EEG.chanlocs(ref_chan:end)];                   
EEG.nbchan = size(EEG.data,1);
clear chan_nb re_chan;

% Write back output
EEG.automagic.auto_badchans = setdiff(removed_chans, eeg_system.ref_chan);
EEG.automagic.params = params;
%% Creating the final figure to save

EEG_filtered_toplot = perform_filter(EEG, filter_params);
fig1 = figure('visible', 'off');
set(gcf, 'Color', [1,1,1])
hold on
% eog figure
subplot(11,1,1)
imagesc(EOG.data);
colormap jet
caxis([-100 100])
XTicks = [] ;
XTicketLabels = [];
set(gca,'XTick', XTicks)
set(gca,'XTickLabel', XTicketLabels)
title('Filtered EOG data');
%eeg figure
subplot(11,1,2:3)
imagesc(EEG_filtered_toplot.data);
colormap jet
caxis([-100 100])
set(gca,'XTick', XTicks)
set(gca,'XTickLabel', XTicketLabels)
title('Filtered EEG data')
%eeg figure
subplot(11,1,4:5)
imagesc(EEG_filtered_toplot.data);
axe = gca;
hold on;
bads = EEG.automagic.auto_badchans;
for i = 1:length(bads)
    y = bads(i);
    p1 = [0, size(EEG_filtered_toplot.data, 2)];
    p2 = [y, y];
    plot(axe, p1, p2, 'b' ,'LineWidth', 0.5);
end
hold off;
colormap jet;
caxis([-100 100])
set(gca,'XTick', XTicks)
set(gca,'XTickLabel', XTicketLabels)
title('Detected bad channels')
% figure;
subplot(11,1,6:7)
imagesc(EEG_regressed.data);
colormap jet
caxis([-100 100])
set(gca,'XTick',XTicks)
set(gca,'XTickLabel',XTicketLabels)
title('EOG regressed out');
%figure;
subplot(11,1,8:9)
imagesc(EEG_cleared.data);
colormap jet
caxis([-100 100])
set(gca,'XTick',XTicks)
set(gca,'XTickLabel',XTicketLabels)
if (~isempty(ica_params))
    title_text = 'ICA';
elseif(~isempty(pca_params))
    title_text = 'PCA';
else
    title_text = '';
end
title([title_text ' corrected clean data'])
%figure;
if( ~isempty(fieldnames(pca_params)) && (isempty(pca_params.lambda) || pca_params.lambda ~= -1))
    subplot(11,1,10:11)
    imagesc(pca_noise);
    colormap jet
    caxis([-100 100])
    XTicks = 0:length(EEG.data)/5:length(EEG.data) ;
    XTicketLabels = round(0:length(EEG.data)/EEG.srate/5:length(EEG.data)/EEG.srate);
    set(gca,'XTick',XTicks)
    set(gca,'XTickLabel',XTicketLabels)
    title('PCA noise')
end

% Pot a seperate figure for only the original filtered data
fig2 = figure('visible', 'off');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1) * 1.5;
bottom = outerpos(2);
ax_width = outerpos(3) - ti(1) - ti(3) * 1.5;
ax_height = outerpos(4) - ti(2) * 0.5 - ti(4);
ax.Position = [left bottom ax_width ax_height];
set(gcf, 'Color', [1,1,1])
imagesc(EEG_filtered_toplot.data);
colormap jet
caxis([-100 100])
set(ax,'XTick', XTicks)
set(ax,'XTickLabel', XTicketLabels)
title_str = 'Filtered EEG data';
if (strcmp(EEG.automagic.filtering.highpass.performed, 'yes'))
    title_str = [title_str, ' highpass: ', num2str(EEG.automagic.filtering.highpass.freq) ' Hz'];
end
if (strcmp(EEG.automagic.filtering.lowpass.performed, 'yes'))
    title_str = [title_str, ' lowpass: ', num2str(EEG.automagic.filtering.lowpass.freq) ' Hz'];
end
if (strcmp(EEG.automagic.filtering.notch.performed, 'yes'))
    title_str = [title_str, ' notch: ', num2str(EEG.automagic.filtering.notch.freq) ' Hz'];
end
title(title_str, 'FontSize', 10)


varargout{1} = fig1;
varargout{2} = fig2;
