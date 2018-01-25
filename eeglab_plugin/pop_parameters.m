function [EEG, com] = pop_parameters(EEG)
% Pops-up a window that takes required parameters and then runs preprocess()
% function. 
%
% Usage:
%   >> EEG = pop_parameters ( EEG ); % pop up window
%
% Inputs:
%   EEG     - EEGLab EEG structure.
%
% Outputs:
%   EEG     -  EEGLab EEG structure where the data is preprocessed with 
%   given arguments from the pop-up window. A new field
%   EEG.automagic will contain information about parameters used
%   and the channels that have been interpolated during the
%   automatic detection of bad channels.
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

com = ''; 

% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_parameters;
	return;
end;	



%--------------------------Set default parameters
%-----------------------------------------------------------
default_params = ConstantGlobalValues.default_params;
DEFAULT_keyword = ConstantGlobalValues.DEFAULT_keyword;


%--------------------------Create Gui
%-----------------------------------------------------------
[uilist, positions, verpos] = getUIControls();
[~, ~, allhandlers] = ...
    supergui('geomhoriz', positions, 'geomvert', verpos,'uilist', uilist, ...
    'title', 'Preprocessing inputs');


%--------------------------Set callbacks
%-----------------------------------------------------------
params = struct;
euradio = findHandlerFromList(allhandlers, 'notcheu');
usradio = findHandlerFromList(allhandlers, 'notchus');
otherradio = findHandlerFromList(allhandlers, 'notchother');
notchedit = findHandlerFromList(allhandlers, 'notchedit');
lowcheck = findHandlerFromList(allhandlers, 'lowcheckin');
lowfreq = findHandlerFromList(allhandlers, 'lowfreqin');
loworder = findHandlerFromList(allhandlers, 'loworderin');
highcheck = findHandlerFromList(allhandlers, 'highcheckin');
highfreq = findHandlerFromList(allhandlers, 'highfreqin');
highorder = findHandlerFromList(allhandlers, 'highorderin');
chancritcheck = findHandlerFromList(allhandlers, 'chancritcheck');
chancritin = findHandlerFromList(allhandlers, 'chancritin');
linenosecritcheck = findHandlerFromList(allhandlers, 'linenosecritcheck');
linenosecritin = findHandlerFromList(allhandlers, 'linenosecritin');
burstcritcheck = findHandlerFromList(allhandlers, 'burstcritcheck');
burstcritin = findHandlerFromList(allhandlers, 'burstcritin');
windowcritcheck = findHandlerFromList(allhandlers, 'windowcritcheck');
windowcritin = findHandlerFromList(allhandlers, 'windowcritin');
rarcheck = findHandlerFromList(allhandlers, 'rarcheck');
icacheck = findHandlerFromList(allhandlers, 'icacheck');
pcacheck = findHandlerFromList(allhandlers, 'pcacheck');
lambdain = findHandlerFromList(allhandlers, 'lambdain');
tolin = findHandlerFromList(allhandlers, 'tolerancein');
maxiterin = findHandlerFromList(allhandlers, 'maxiterin');
ok = findHandlerFromList(allhandlers, 'ok');
interpol = findHandlerFromList(allhandlers, 'interpolpopup');
refchan = findHandlerFromList(allhandlers, 'refedit');
reduce_chans = findHandlerFromList(allhandlers, 'reducechancheck');
eog_chans = findHandlerFromList(allhandlers, 'eogchans');
exclud_chans = findHandlerFromList(allhandlers, 'excludchans');
eog_chans_check = findHandlerFromList(allhandlers, 'eogchanscheck');
default = findHandlerFromList(allhandlers, 'default_butt');

euradio.set('callback', @euradiocallback);
usradio.set('callback', @usradiocallback);
otherradio.set('callback', @otherradiocallback);
notchedit.set('callback', @notcheditcallback);
lowcheck.set('callback', @lowcheckcallback);
highcheck.set('callback', @highcheckcallback);
chancritcheck.set('callback', @chancritcheckcallback);
linenosecritcheck.set('callback', @linenosecritcheckcallback);
burstcritcheck.set('callback', @burstcritcheckcallback);
windowcritcheck.set('callback', @windowcritcheckcallback);
icacheck.set('callback', @icacheckcallback);
pcacheck.set('callback', @pcacheckcallback);
eog_chans_check.set('callback', @eogregressioncallback);
reduce_chans.set('callback', @reducechancallback);
ok.set('callback', @okcallback);
default.set('callback', @defaultcallback);
    
% Notch Filter callback
% -------------------------------------------
function euradiocallback(PushButton, EventData)
    if(get(euradio, 'Value'))
        set(usradio, 'Value', 0);
        set(otherradio, 'Value', 0);
        set(notchedit, 'String', num2str(default_params.filter_params.notch_eu));
    end
end

function usradiocallback(PushButton, EventData)
    if(get(usradio, 'Value'))
        set(euradio, 'Value', 0);
        set(otherradio, 'Value', 0);
        set(notchedit, 'String', num2str(default_params.filter_params.notch_us));
    end
end

function otherradiocallback(PushButton, EventData)
    if(get(usradio, 'Value'))
        set(euradio, 'Value', 0);
        set(usradio, 'Value', 0);
        set(notchedit, 'String', num2str(default_params.filter_params.notch_other));
    end
end

function notcheditcallback(PushButton, EventData)
    notch_freq = str2double(get(notchedit, 'String'));
    if(notch_freq == default_params.filter_params.notch_eu)
        set(euradio, 'Value', 1);
        set(usradio, 'Value', 0);
        set(otherradio, 'Value', 0);
    elseif(notch_freq == default_params.filter_params.notch_us)
        set(usradio, 'Value', 1);
        set(euradio, 'Value', 0);
        set(otherradio, 'Value', 0);
    else
        set(otherradio, 'Value', 1);
        set(euradio, 'Value', 0);
        set(usradio, 'Value', 0);
    end
end

% Low pass callback
% -------------------------------------------
function lowcheckcallback(PushButton, EventData)
    switch_components();
end

% High pass callback
% -------------------------------------------
function highcheckcallback(PushButton, EventData)
    switch_components();
end

% Channel Rejection criterias callback
% -------------------------------------------
function chancritcheckcallback(PushButton, EventData)
    switch_components();
end
function linenosecritcheckcallback(PushButton, EventData)
    switch_components();
end
function burstcritcheckcallback(PushButton, EventData)
    switch_components();
end
function windowcritcheckcallback(PushButton, EventData)
    switch_components();
end
function reducechancallback(PushButton, EventData)
    switch_components();
end
function eogregressioncallback(PushButton, EventData)
    switch_components();
end

% ICA and PCA callback
% -------------------------------------------
function icacheckcallback(PushButton, EventData)
    if(get(icacheck, 'Value'))
        set(pcacheck, 'value', 0)
        set(lambdain, 'enable', 'off', 'String', ...
            format_default(num2str(DEFAULT_keyword)));
        set(tolin, 'enable', 'off', 'String', ...
            format_default(num2str(default_params.pca_params.tol)));
        set(maxiterin, 'enable', 'off', 'String', ...
            format_default(num2str(default_params.pca_params.maxIter)));
    end
end

function pcacheckcallback(PushButton, EventData)
    if( get(pcacheck, 'Value') )
        set(lambdain, 'enable', 'on');
        set(tolin, 'enable', 'on');
        set(maxiterin, 'enable', 'on');
        set(icacheck, 'value', 0)
    else
        set(lambdain, 'enable', 'off', 'String', ...
            format_default(num2str(DEFAULT_keyword)));
        set(tolin, 'enable', 'off', 'String', ...
            format_default(num2str(default_params.pca_params.tol)));
        set(maxiterin, 'enable', 'off', 'String', ...
            format_default(num2str(default_params.pca_params.maxIter)));
    end
end

% OK button callback. It gathers input and start preprocessing
% -------------------------------------------
function okcallback(PushButton, EventData)
    perform_reduce_channels = ...
        get(reduce_chans, 'Value');
    
    exclud_channels = str2num(get(exclud_chans, 'String'));
    if( perform_reduce_channels && isempty(exclud_channels))
        waitfor(msgbox(['A list of channel indices seperated by space or',...
            ' comma must be given to determine channels to be excluded'],...
            'Error','error'));
        return;
    end
    eeg_system.tobe_excluded_chans = exclud_channels;
    
    ica_bool = get(icacheck, 'Value');

    high_order = [];
    if( get(highcheck, 'Value') )
        high_order = str2double(get(highorder, 'String'));
    end
    if(isnan(high_order) )
        high_order = default_params.filter_params.high_order;
    end


    low_order = [];
    if( get(lowcheck, 'Value') )
        low_order = str2double(get(loworder, 'String'));
    end
    if(isnan(low_order))
        low_order = default_params.filter_params.high_order;
    end

    if( get(chancritcheck, 'Value') )
        chancrit_val = str2double(get(chancritin, 'String'));
    else
        chancrit_val = 'off';
    end
    if( isempty(chancrit_val) || isnan(chancrit_val))
       chancrit_val = default_params.channel_rejection_params.channel_criterion;
    end

    if( get(linenosecritcheck, 'Value') )
        linenosecrit_val = str2double(get(linenosecritin, 'String'));
    else
        linenosecrit_val = 'off';
    end
    if( isempty(linenosecrit_val) || isnan(linenosecrit_val))
       linenosecrit_val = default_params.channel_rejection_params.line_noise_criterion; ;
    end

    if( get(burstcritcheck, 'Value') )
        burstcrit_val = str2double(get(burstcritin, 'String'));
    else
        burstcrit_val = 'off';
    end
    if( isempty(burstcrit_val) || isnan(burstcrit_val))
       burstcrit_val = default_params.channel_rejection_params.burst_criterion;
    end

    if( get(windowcritcheck, 'Value') )
        windowcrit_val = str2double(get(windowcritin, 'String'));
    else
        windowcrit_val = 'off';
    end
    if( isempty(windowcrit_val) || isnan(windowcrit_val))
       windowcrit_val = default_params.channel_rejection_params.window_criterion;
    end

    rar_bool = get(rarcheck, 'Value');
    
    if( get(pcacheck, 'Value') )
        lambda = str2double(get(lambdain, 'String'));
        tol = str2double(get(tolin, 'String'));
        maxIter = str2double(get(maxiterin, 'String'));
        if(isnan(lambda) )
            lambda = default_params.pca_params.lambda; 
        end
    else
        lambda = -1;
        tol = -1;
        maxIter = -1;
    end

    if(isempty(tol) || isnan(tol))
        tol = default_params.pca_params.tol;
    end

    if( isempty(maxIter) || isnan(maxIter)) 
        maxIter = default_params.pca_params.maxIter;
    end


    idx = get(interpol, 'Value');
    methods = get(interpol, 'String');
    method = methods{idx};

    perform_eog_regression = get(eog_chans_check, 'Value');
    eog_channels = str2num(get(eog_chans, 'String'));
    if( perform_eog_regression && isempty(eog_channels))
        waitfor(msgbox(['A list of channel indices seperated by space or',...
            ' comma must be given to determine EOG channels'],...
            'Error','error'));
        return;
    end
    eeg_system.eog_chans = eog_channels;
    eeg_system.name = '';
    
    notch_freq = str2num(get(notchedit, 'String'));
    if(isempty(notch_freq))
        notch_freq = -1; % Skip notch filter
        waitfor(...
            msgbox('Notch filter is left empty and therefore will be skipped.'))
    end
    
    ref_chan = str2num(get(refchan, 'String'));
    if(isempty(ref_chan))
        waitfor(msgbox(['Please specify the channel index of the reference ',...
            ' channel contraining 0s'],...
            'Error','error'));
        return;
    end
    eeg_system.ref_chan = ref_chan;
    
    params.eeg_system = eeg_system;
    params.perform_eog_regression = perform_eog_regression;
    params.perform_reduce_channels = perform_reduce_channels;
    params.filter_params.high_order = high_order;
    params.filter_params.low_order = low_order;
    params.filter_params.notch_freq = notch_freq;
    params.channel_rejection_params.channel_criterion = chancrit_val;
    params.channel_rejection_params.line_noise_criterion = linenosecrit_val;
    params.channel_rejection_params.burst_criterion = burstcrit_val;
    params.channel_rejection_params.window_criterion = windowcrit_val;
    params.channel_rejection_params.rar = rar_bool;
    params.pca_params.lambda = lambda;
    params.pca_params.tol = tol;
    params.pca_params.maxIter = maxIter;
    params.ica_params.bool = ica_bool;
    params.interpolation_params.method = method;
    close gcbf
end

% Default button callback. It sets all values of the gui to default
% -------------------------------------------
function defaultcallback(PushButton, EventData)
    
    % Filterings
    set(euradio, 'Value', 1);
    set(usradio, 'Value', 0);
   
    set(highcheck, 'Value', 1);
    set(lowcheck, 'Value', 0);
    set(highorder, 'String', ...
        format_default(DEFAULT_keyword));
    set(highfreq, 'String', ...
        format_default(default_params.filter_params.high_freq));

    % Channel rejection
    if( ~strcmp(default_params.channel_rejection_params.channel_criterion, 'off'))
        set(chancritcheck, 'Value', 1);       
    else
        set(chancritcheck, 'Value', 0);
    end
    set(chancritin, 'String', format_default(default_params.channel_rejection_params.channel_criterion));

    if( ~strcmp(default_params.channel_rejection_params.line_noise_criterion, 'off'))
        set(linenosecritcheck, 'Value', 1);
    else
        set(linenosecritcheck, 'Value', 0);
    end
    set(linenosecritin, 'String', format_default(default_params.channel_rejection_params.line_noise_criterion));

    if( ~strcmp(default_params.channel_rejection_params.burst_criterion, 'off'))
        set(burstcritcheck, 'Value', 1);
    else
        set(burstcritcheck, 'Value', 0);
    end
    set(burstcritin, 'String', format_default(default_params.channel_rejection_params.burst_criterion));
    
    if( ~strcmp(default_params.channel_rejection_params.window_criterion, 'off'))
        set(windowcritcheck, 'Value', 1);
    else
        set(windowcritcheck, 'Value', 0);
    end
    set(windowcritin, 'String', format_default(default_params.channel_rejection_params.window_criterion));
    
    set(rarcheck, 'Value', default_params.channel_rejection_params.rar);
    
    % ICA
    set(icacheck, 'Value', default_params.ica_params.bool);
        
    % PCA
    if( isempty(default_params.pca_params.lambda) || default_params.pca_params.lambda ~= -1)
        set(pcacheck, 'Value', 1);
        format_default(set(lambdain, 'String', ...
            DEFAULT_keyword));
        set(tolin, 'String', ...
            format_default(default_params.pca_params.tol));
        set(maxiterin, 'String', ...
            format_default(default_params.pca_params.maxIter));
    else
        set(pcacheck, 'Value', 0);
        set(lambdain, 'String', '');
        set(tolin, 'String', '');
        set(maxiterin, 'String', '');
    end

    % Reduce channels
    set(exclud_chans, 'String', num2str(default_params.channel_reduction_params.tobe_excluded_chans));
    set(reduce_chans, 'Value', default_params.channel_reduction_params.perform_reduce_channels);
        
    % EOG channels
    set(eog_chans, 'String', num2str(default_params.eog_regression_params.eog_chans));
    set(eog_chans_check, 'Value', default_params.eog_regression_params.perform_eog_regression);
    
    % Interpolation
    IndexC = strfind(interpol.String, ...
        default_params.interpolation_params.method);
    index = find(not(cellfun('isempty', IndexC)));
    set(interpol, 'Value', index);

    % Reference channel
    set(refchan, 'String', default_params.eeg_system.ref_chan);
    
    switch_components();
end

% Activate or desactivate ui elements accordingly
% ----------------------------------------------------
function switch_components()
    if(get(euradio, 'Value'))
        set(usradio, 'Value', 0);
    end
    if(get(usradio, 'Value'))
        set(euradio, 'Value', 0);
    end

    if( get(highcheck, 'Value') )
        set(highorder, 'enable', 'on');
        set(highfreq, 'enable', 'on');
    else
        set(highorder, 'enable', 'off', 'String', ...
            format_default(DEFAULT_keyword));
        set(highfreq, 'enable', 'off', 'String', ...
            format_default(default_params.filter_params.high_freq));
    end

    if( get(lowcheck, 'Value') )
        set(loworder, 'enable', 'on');
        set(lowfreq, 'enable', 'on');
    else
        set(loworder, 'enable', 'off', 'String', ...
            format_default(default_params.filter_params.low_order));
        set(lowfreq, 'enable', 'off', 'String', ...
           format_default(default_params.filter_params.low_freq));
    end

    if( get(chancritcheck, 'Value') )
        set(chancritin, 'enable', 'on');
    else
        set(chancritin, 'enable', 'off', 'String', ...
            	default_params.channel_rejection_params.channel_criterion);
    end

    if( get(linenosecritcheck, 'Value') )
        set(linenosecritin, 'enable', 'on');
    else
        set(linenosecritin, 'enable', 'off', 'String', ...
            	default_params.channel_rejection_params.line_noise_criterion);
    end

    if( get(burstcritcheck, 'Value') )
        set(burstcritin, 'enable', 'on');
    else
        set(burstcritin, 'enable', 'off', 'String', ...
            	default_params.channel_rejection_params.burst_criterion);
    end
    
    if( get(windowcritcheck, 'Value') )
        set(windowcritin, 'enable', 'on');
    else
        set(windowcritin, 'enable', 'off', 'String', ...
            	default_params.channel_rejection_params.window_criterion);
    end

    if( get(pcacheck, 'Value') )
        set(lambdain, 'enable', 'on');
        set(tolin, 'enable', 'on');
        set(maxiterin, 'enable', 'on');
        set(icacheck, 'value', 0)
    else
        set(lambdain, 'enable', 'off', 'String', ...
            format_default(num2str(DEFAULT_keyword)));
        set(tolin, 'enable', 'off', 'String', ...
            format_default(num2str(default_params.pca_params.tol)));
        set(maxiterin, 'enable', 'off', 'String', ...
            format_default(num2str(default_params.pca_params.maxIter)));
    end

    if(get(icacheck, 'Value'))
        set(pcacheck, 'value', 0)
        set(lambdain, 'enable', 'off', 'String', ...
            format_default(num2str(DEFAULT_keyword)));
        set(tolin, 'enable', 'off', 'String', ...
            format_default(num2str(default_params.pca_params.tol)));
        set(maxiterin, 'enable', 'off', 'String', ...
            format_default(num2str(default_params.pca_params.maxIter)));
    end
    
    if( get(reduce_chans, 'Value') )
        set(exclud_chans, 'enable', 'on');
    else
        set(exclud_chans, 'enable', 'off', 'String', ...
            	num2str(default_params.channel_reduction_params.tobe_excluded_chans));
    end

    if( get(eog_chans_check, 'Value') )
        set(eog_chans, 'enable', 'on');
    else
        set(eog_chans, 'enable', 'off', 'String', ...
            	num2str(default_params.eog_regression_params.eog_chans));
    end
end

% Put all initial values to default
defaultcallback();

% This makes the code stop until we make sure the pop up window is closed
waitfor(allhandlers{1})

% If cancel was clicked on
if( isempty(fieldnames(params)) ||  isempty(EEG.data))
    disp('Cannot preprocess without parameters or dataset.');
    return
end

% Preprocess EEG with given parameters. Keep all information in a field
% called 'EEG.automagic'
% -------------------------
[EEG_result, ~] = preprocess(EEG, params);
if(isempty(EEG_result))
    return;
end

auto_badchans =  EEG_result.auto_badchans;
EEG = rmfield(EEG_result, 'auto_badchans');
EEG.automagic.params = params;
EEG.automagic.auto_badchans = auto_badchans;

% return the string command
% -------------------------
com = sprintf('[EEG] = pop_parameters(EEG)');

end


function [uilist, uipositions, verpos] = getUIControls()
% Create uiconstrols for each line

% Notch Filter
% ---------------------------------------
notch_text.style = { {'Style','text',...
            'String','Notch Filter:'} };
notch_text.pos = 1;

notch_input.style = { {} {'Style','radio',...
            'String','Europe (50Hz)', 'tag', 'notcheu', 'Value', 1}  {'Style','radio',...
            'String','US (60Hz)', 'tag', 'notchus'} {'Style','radio',...
            'String','Other...', 'tag', 'notchother'} {'Style','edit',...
            'String','50', 'tag', 'notchedit', 'Enable', 'on'}};
notch_input.pos = [1 1 1 1 1];

% High pass filter
% ---------------------------------------
high_text.style = {{'Style','text',...
            'String','High Pass Filter:'}};
high_text.pos = 1;

high_label.style = {{} {'Style','text',...
            'String','Frequency'} {'Style','text',...
            'String','Order'}};
high_label.pos = [1 1 1];

high_inputs.style = { {'Style','checkbox',...
            'String','(Recommended)', 'tag', 'highcheckin', 'Value', 1} {'Style','edit',...
            'String','0.5', 'tag', 'highfreqin'} {'Style','edit',...
            'String','Default', 'tag', 'highorderin'} };
high_inputs.pos = [1 1 1];
 
% Low pass filter
% ---------------------------------------
low_text.style = { {'Style','text',...
            'String','Low Pass Filter:'} };
low_text.pos = 1;

low_label.style = {{} {'Style','text',...
            'String','Frequency'} {'Style','text',...
            'String','Order'}};
low_label.pos = [1 1 1];

low_inputs.style = { {'Style','checkbox',...
            'String','', 'Value', 0, 'tag', 'lowcheckin'} {'Style','edit',...
            'String','', 'tag', 'lowfreqin', 'Enable', 'off'} {'Style','edit',...
            'String','', 'tag', 'loworderin', 'Enable', 'off'} };
low_inputs.pos = [1 1 1];

% Channel rejection criterias
% ---------------------------------------
channel_rejection_text.style = { {'Style','text',...
            'String','Channel rejection criterias:'} };
channel_rejection_text.pos = 1;

channel_rejection_label.style = {{} {'Style','text',...
            'String','Threshold'}};
channel_rejection_label.pos = [1 1];

channel_rejection_input_chan.style = { {'Style','checkbox',...
            'String','Channel Criterion', 'tag', 'chancritcheck', 'Value', 1} {'Style','edit',...
            'String','3', 'tag', 'chancritin'}};
channel_rejection_input_chan.pos = [1 1];        

channel_rejection_input_linenoise.style = { {'Style','checkbox',...
            'String','Line Noise Criterion', 'tag', 'linenosecritcheck', 'Value', 1} {'Style','edit',...
            'String','4', 'tag', 'linenosecritin'}};
channel_rejection_input_linenoise.pos = [1 1]; 

channel_rejection_input_burst.style = { {'Style','checkbox',...
            'String','Burst Criterion', 'tag', 'burstcritcheck', 'Value', 1} {'Style','edit',...
            'String','4', 'tag', 'burstcritin'}};
channel_rejection_input_burst.pos = [1 1]; 

channel_rejection_input_win.style = { {'Style','checkbox',...
            'String','Window Criterion', 'tag', 'windowcritcheck', 'Value', 1} {'Style','edit',...
            'String','4', 'tag', 'windowcritin'}};
channel_rejection_input_win.pos = [1 1]; 

channel_rejection_input_rar.style = { {'Style','checkbox',...
            'String','Robust Average Referencing', 'tag', 'rarcheck', 'Value', 0} };
channel_rejection_input_rar.pos = 1; 
% ICA
% ---------------------------------------
ica_checkbox.style = { {'Style','checkbox',...
            'String','ICA', 'tag', 'icacheck', 'Value', 0} };
ica_checkbox.pos = 1; 

% PCA
% ---------------------------------------
pca_checkbox.style = { {'Style','checkbox',...
            'String','PCA', 'tag', 'pcacheck', 'Value', 1} };
pca_checkbox.pos = 1; 

pca_lambda.style = { {} {'Style','text',...
            'String','lambda'} {'Style','edit',...
            'String','Default', 'tag', 'lambdain'} };
pca_lambda.pos = [1 1 1]; 

pca_tolerance.style = { {} {'Style','text',...
            'String','tolerance'} {'Style','edit',...
            'String','1e-07', 'tag', 'tolerancein'} };
pca_tolerance.pos = [1 1 1]; 

pca_maxiter.style = { {} {'Style','text',...
            'String','maxIter'} {'Style','edit',...
            'String','1000', 'tag', 'maxiterin'} };
pca_maxiter.pos = [1 1 1]; 

% Interpolation mode
% ---------------------------------------
interpolation_text.style = {{'Style','text',...
            'String','Interpolation'}  {'Style','popupmenu',...
            'String',{'spherical', 'invdist', 'spacetime'}, ...
            'tag', 'interpolpopup', 'Value', 1} };
interpolation_text.pos = [1 1];

% Reference channel
% ---------------------------------------
refchan.style = {{'Style','text',...
            'String','Reference channel'}  {'Style','edit',...
            'String', '', 'tag', 'refedit'} };
refchan.pos = [1 1];

% Reduce number of channels
% ---------------------------------------
reduce_chan_chechbox.style = { {'Style','checkbox',...
            'String','Reduce Number of Channels (Only for EGI systems)', ...
            'tag', 'reducechancheck', 'Value', 1} {'Style','edit',...
            'String','', 'tag', 'excludchans'}};
reduce_chan_chechbox.pos = [1 1]; 

% EOG channels
% ---------------------------------------
eog.style = {{'Style','checkbox',...
            'String','EOG Channels', ...
            'tag', 'eogchanscheck', 'Value', 1}  {'Style','edit',...
            'String','', 'tag', 'eogchans'} };
eog.pos = [1 2];

% OK, Default and Cancel button
% ---------------------------------------
okcancel.style = {{ 'width' 80 'align' 'left' 'Style', 'pushbutton', ...
    'string', 'Cancel', 'tag' 'cancel' 'callback', 'close gcbf' } ...
    { 'width' 120 'align' 'left' 'Style', 'pushbutton', ...
    'string', 'Set to Default', 'tag' 'default_butt' }...
    { 'width' 80 'align' 'right' 'stickto' 'on' ...
    'Style', 'pushbutton', 'tag', 'ok', 'string', 'OK' } };
okcancel.pos = [1 1 1];
            
% Return both lists of uis and their positions
% --------------------------------------------
verpos = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
uipositions = {notch_text.pos notch_input.pos high_text.pos ...
    high_label.pos high_inputs.pos low_text.pos ...
    low_label.pos low_inputs.pos ...
    channel_rejection_text.pos channel_rejection_label.pos ...
    channel_rejection_input_chan.pos channel_rejection_input_linenoise.pos ...
    channel_rejection_input_burst.pos channel_rejection_input_win.pos ...
    channel_rejection_input_rar.pos ica_checkbox.pos pca_checkbox.pos ...
    pca_lambda.pos pca_tolerance.pos pca_maxiter.pos interpolation_text.pos ...
    refchan. pos reduce_chan_chechbox.pos eog.pos okcancel.pos};
uilist = [notch_text.style notch_input.style high_text.style ...
    high_label.style high_inputs.style low_text.style ...
    low_label.style low_inputs.style channel_rejection_text.style ...
    channel_rejection_label.style channel_rejection_input_chan.style ...
    channel_rejection_input_linenoise.style channel_rejection_input_burst.style...
    channel_rejection_input_win.style channel_rejection_input_rar.style ...
    ica_checkbox.style pca_checkbox.style pca_lambda.style pca_tolerance.style ...
    pca_maxiter.style interpolation_text.style refchan.style ...
    reduce_chan_chechbox.style eog.style okcancel.style];

end

function uielem = findHandlerFromList(allhandlers, tag)
indices = cellfun(@(x) isa(x, 'matlab.ui.control.UIControl') && ...
    strcmp(x.Tag, tag), allhandlers);
uielem = allhandlers{indices};
end

function val = format_default(val)
    if( val == -1)
        val = [];
    end
end