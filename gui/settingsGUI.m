function varargout = settingsGUI(varargin)
% SETTINGSGUI MATLAB code for settingsGUI.fig
%      SETTINGSGUI, by itself, creates a new SETTINGSGUI or raises the existing
%      singleton*.
%
%      H = SETTINGSGUI returns the handle to a new SETTINGSGUI or the handle to
%      the existing singleton*.
%
%      SETTINGSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETTINGSGUI.M with the given input arguments.
%
%      SETTINGSGUI('Property','Value',...) creates a new SETTINGSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before settingsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to settingsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
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

% Last Modified by GUIDE v2.5 19-Sep-2018 15:34:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @settingsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @settingsGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before settingsGUI is made visible.
function settingsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to settingsGUI (see VARARGIN)

if( nargin - 3 ~= 2 )
    error('wrong number of arguments. params and ds rate must be given as arguments.')
end

%set(handles.settingsfigure, 'units', 'normalized', 'position', [0.05 0.2 0.6 0.8])
%set(handles.settingspanel, 'units', 'normalized', 'position', [0.05 0.1 0.8 0.9])
children = handles.settingsfigure.Children;
for child_idx = 1:length(children)
    child = children(child_idx);
    set(child, 'units', 'normalized')
    for grandchild_idx = 1:length(child.Children)
       grandchild = child.Children(grandchild_idx);
       set(grandchild, 'units', 'normalized')
    end
end

% Get arguments
params = varargin{1};
assert(isa(params, 'struct'));
VisualisationParams = varargin{2};
CGV = ConstantGlobalValues;

% Put them in the handle
handles.params = params;
handles.VisualisationParams = VisualisationParams;
handles.CGV = CGV;

assert( isempty(handles.params.PCAParams) || ...
    isempty(handles.params.ICAParams), ...
    'Either pca or ica, not both together.');

% Set the gui components according to params
handles = set_gui(handles, params, VisualisationParams);
handles = switch_components(handles);


% Choose default command line output for settingsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes settingsGUI wait for user response (see UIRESUME)
% uiwait(handles.settingsfigure);


function handles = set_gui(handles, params, VisualisationParams)
DEFAULT_KEYWORD = handles.CGV.DEFAULT_KEYWORD;
CalcQualityParams = VisualisationParams.CalcQualityParams;
dsRate = VisualisationParams.dsRate;

if ~isempty(params.FilterParams)
    if ~isempty(params.FilterParams.high)
        set(handles.highcheckbox, 'Value', 1);
        if isempty(params.FilterParams.high.order)
            set(handles.highpassorderedit, 'String', DEFAULT_KEYWORD);
        else
            set(handles.highpassorderedit, 'String', params.FilterParams.high.order);
        end
        
        if isempty(params.FilterParams.high.freq)
            set(handles.highedit, 'String', DEFAULT_KEYWORD);
        else
            set(handles.highedit, 'String', params.FilterParams.high.freq);
        end
    else
        set(handles.highcheckbox, 'Value', 0);
        set(handles.highpassorderedit, 'String', '')
        set(handles.highedit, 'String', '');
    end

    if ~isempty(params.FilterParams.low)
        set(handles.lowcheckbox, 'Value', 1);
        if isempty(params.FilterParams.low.order)
            set(handles.lowpassorderedit, 'String', DEFAULT_KEYWORD);
        else
            set(handles.lowpassorderedit, 'String', params.FilterParams.low.order);
        end
        
        if isempty(params.FilterParams.low.freq)
            set(handles.lowedit, 'String', DEFAULT_KEYWORD);
        else
            set(handles.lowedit, 'String', params.FilterParams.low.freq);
        end
    else
        set(handles.lowcheckbox, 'Value', 0);
        set(handles.lowpassorderedit, 'String', '')
        set(handles.lowedit, 'String', '');
    end
    
    set(handles.notchcheckbox, 'Value', ~isempty(params.FilterParams.notch));
else
    set(handles.highcheckbox, 'Value', 0);
    set(handles.lowcheckbox, 'Value', 0);
    set(handles.highpassorderedit, 'String', '')
    set(handles.highedit, 'String', '');
    set(handles.lowpassorderedit, 'String', '')
    set(handles.lowedit, 'String', '');
    set(handles.notchedit, 'String', 'off')
    set(handles.otherradio, 'Value', 1)
end

% Set Quality Rating Parameters. This can't be disabled
set(handles.overalledit, 'String', mat2str(CalcQualityParams.overallThresh));
set(handles.timeedit, 'String', mat2str(CalcQualityParams.timeThresh));
set(handles.channelthresholdedit, 'String', mat2str(CalcQualityParams.chanThresh));

set(handles.icacheckbox, 'Value', ~isempty(params.ICAParams));
if ~isempty(params.ICAParams)
    set(handles.largemapcheckbox, 'Value', params.ICAParams.largeMap)
    if ~isempty(params.ICAParams.high)
        set(handles.icahighpasscheckbox, 'Value', 1);
        if isempty(params.ICAParams.high.order)
            set(handles.icahighpassorderedit, 'String', DEFAULT_KEYWORD);
        else
            set(handles.icahighpassorderedit, 'String', params.ICAParams.high.order);
        end
        
        if isempty(params.ICAParams.high.freq)
            set(handles.icahighpassedit, 'String', DEFAULT_KEYWORD);
        else
            set(handles.icahighpassedit, 'String', params.ICAParams.high.freq);
        end
    else
        set(handles.highcheckbox, 'Value', 0);
        set(handles.icahighpassorderedit, 'String', '')
        set(handles.icahighpassedit, 'String', '');
    end
else
    set(handles.largemapcheckbox, 'Value', 0)
    set(handles.icahighpasscheckbox, 'Value', 0)
    set(handles.icahighpassedit, 'String', '')
    set(handles.icahighpassorderedit, 'String', '')
end

if ~isempty(params.ASRParams)
    if( ~strcmp(params.ASRParams.Highpass, 'off'))
        set(handles.asrhighcheckbox, 'Value', 1);
    else
        set(handles.asrhighcheckbox, 'Value', 0);
    end
    set(handles.asrhighedit, 'String', ...
            mat2str(params.ASRParams.Highpass));
        
    if( ~strcmp(params.ASRParams.LineNoiseCriterion, 'off'))
        set(handles.linenoisecheckbox, 'Value', 1);
    else
        set(handles.linenoisecheckbox, 'Value', 0);
    end
    set(handles.linenoiseedit, 'String', ...
            params.ASRParams.LineNoiseCriterion);
        
    if( ~strcmp(params.ASRParams.ChannelCriterion, 'off'))
        set(handles.channelcriterioncheckbox, 'Value', 1);
    else
        set(handles.channelcriterioncheckbox, 'Value', 0);
    end
    set(handles.channelcriterionedit, 'String', ...
            params.ASRParams.ChannelCriterion);
        
    if( ~strcmp(params.ASRParams.BurstCriterion, 'off'))
        set(handles.burstcheckbox, 'Value', 1);
    else
        set(handles.burstcheckbox, 'Value', 0);
    end
    set(handles.burstedit, 'String', ...
            params.ASRParams.BurstCriterion);
        
    if( ~strcmp(params.ASRParams.WindowCriterion, 'off'))
        set(handles.windowcheckbox, 'Value', 1);
    else
        set(handles.windowcheckbox, 'Value', 0);
    end
    set(handles.windowedit, 'String', ...
            params.ASRParams.WindowCriterion);    
else
    set(handles.asrhighcheckbox, 'Value', 0);
    set(handles.asrhighedit, 'String', '');
    
    set(handles.linenoisecheckbox, 'Value', 0);
    set(handles.linenoiseedit, 'String', '');
        
    set(handles.channelcriterioncheckbox, 'Value', 0);
    set(handles.channelcriterionedit, 'String', '');
        
    set(handles.burstcheckbox, 'Value', 0);
    set(handles.burstedit, 'String', '');
        
    set(handles.windowcheckbox, 'Value', 0);
    set(handles.windowedit, 'String', '');
end
set(handles.rarcheckbox, 'Value', ~isempty(params.PrepParams));

if ~isempty(params.FilterParams.notch)
    setLineNoise(params.FilterParams.notch.freq, handles);
elseif (~isempty(params.PrepParams))
    if isfield(params.PrepParams, 'lineFrequencies') && ~isempty(params.PrepParams.lineFrequencies)
        setLineNoise(params.PrepParams.lineFrequencies(1), handles);
    end
else
    setLineNoise([], handles);
end

if( ~isempty(params.HighvarParams))
    set(handles.highvarcheckbox, 'Value', 1);
    set(handles.highvaredit, 'String', mat2str(params.HighvarParams.sd));
else
    set(handles.highvarcheckbox, 'Value', 0);
    set(handles.highvaredit, 'String', '');
end

if ~isempty(params.PCAParams)
    set(handles.pcacheckbox, 'Value', 1);
    if( isempty(params.PCAParams.lambda))
        set(handles.lambdaedit, 'String', DEFAULT_KEYWORD);
    else
        set(handles.lambdaedit, 'String', params.PCAParams.lambda);
    end
        set(handles.toledit, 'String', params.PCAParams.tol);
        set(handles.maxIteredit, 'String', params.PCAParams.maxIter);
else
    set(handles.pcacheckbox, 'Value', 0);
    set(handles.lambdaedit, 'String', '');
    set(handles.toledit, 'String', '');
    set(handles.maxIteredit, 'String', '');
end
IndexC = strfind(handles.interpolationpopupmenu.String, ...
    params.InterpolationParams.method);
index = find(not(cellfun('isempty', IndexC)));
set(handles.interpolationpopupmenu, 'Value', index);


set(handles.eogcheckbox, 'Value', ...
    params.EOGRegressionParams.performEOGRegression)

contents = cellstr(get(handles.dspopupmenu,'String'));
index = find(contains(contents, int2str(dsRate)));
set(handles.dspopupmenu, 'Value', index);

handles = switch_components(handles);

function handles = get_inputs(handles)
params = handles.params;
VisualisationParams = handles.VisualisationParams;

ICAParams = params.ICAParams;
if get(handles.icacheckbox, 'Value')
    if isempty(ICAParams)
        ICAParams = struct();end
    ICAParams.largeMap = get(handles.largemapcheckbox, 'Value');
    
    high = params.ICAParams.high;
    if( get(handles.icahighpasscheckbox, 'Value'))
        if isempty(high)
            high = struct();
        end
        res = str2double(get(handles.icahighpassorderedit, 'String'));
        if ~isnan(res)
            high.order = res; 
        else
            high.order = [];
        end

        res = str2double(get(handles.icahighpassedit, 'String'));
        if ~isnan(res)
            high.freq = res; 
        else
            high.freq = [];
        end
    else
        high = struct([]);
    end
    ICAParams.high = high;
    clear res;
else
    ICAParams = struct([]);
end

high = params.FilterParams.high;
if( get(handles.highcheckbox, 'Value'))
    if isempty(high)
        high = struct();
    end
    res = str2double(get(handles.highpassorderedit, 'String'));
    if ~isnan(res)
        high.order = res; 
    else
        high.order = [];
    end
    
    res = str2double(get(handles.highedit, 'String'));
    if ~isnan(res)
        high.freq = res; 
    else
        high.freq = [];
    end
else
    high = struct([]);
end
clear res;

low = params.FilterParams.low;
if( get(handles.lowcheckbox, 'Value'))
    if isempty(low)
        low = struct();end
    res = str2double(get(handles.lowpassorderedit, 'String'));
    if ~isnan(res)
        low.order = res;
    else
        low.order = [];
    end
    
    res = str2double(get(handles.lowedit, 'String'));
    if ~isnan(res)
        low.freq = res;
    else
        low.freq = [];
    end
else
    low = struct([]);
end
clear res;

notch = params.FilterParams.notch;
if( get(handles.notchcheckbox, 'Value'))
    if isempty(notch)
        notch = struct(); end
    res = str2double(get(handles.notchedit, 'String'));
    if ~isnan(res)
        notch.freq = res;
    else
        notch.freq = [];
    end
    clear res;
else
    notch = struct([]);
end


% Get Quality Rating Parameters.
CalcQualityParams = VisualisationParams.CalcQualityParams;
overallThresh = str2num(get(handles.overalledit, 'String'));
timeThresh = str2num(get(handles.timeedit, 'String'));
chanThresh = str2num(get(handles.channelthresholdedit, 'String'));
if ~isnan(overallThresh)
    CalcQualityParams.overallThresh = overallThresh;
end
if ~isnan(timeThresh)
    CalcQualityParams.timeThresh = timeThresh;
end
if ~isnan(chanThresh)
    CalcQualityParams.chanThresh = chanThresh;
end

ASRParams = params.ASRParams;
if( get(handles.asrhighcheckbox, 'Value') )
    highpass_val = str2num(get(handles.asrhighedit, 'String'));
    if(length(highpass_val) ~= 2)
        popup_msg(['High pass parameter for ASR must be an array of'...
            ' length 2 like [0.25 0.75]'], 'Error');
        error(['High pass parameter for ASR must be an array of '...
            'length 2 like [0.25 0.75]']);
    end
    if( ~isnan(highpass_val))
        ASRParams.Highpass = highpass_val; end
else
    if ~isempty(ASRParams)
        ASRParams.Highpass = 'off'; end
end

if( get(handles.linenoisecheckbox, 'Value') )
    linenoise_val = str2double(get(handles.linenoiseedit, 'String'));
    if( ~isnan(linenoise_val))
        ASRParams.LineNoiseCriterion = linenoise_val; end
else
    if ~isempty(ASRParams)
        ASRParams.LineNoiseCriterion = 'off'; end
end


if( get(handles.channelcriterioncheckbox, 'Value') )
    ChannelCriterion = str2double(get(handles.channelcriterionedit, 'String'));
    if( ~isnan(ChannelCriterion))
        ASRParams.ChannelCriterion = ChannelCriterion; end
else
    if ~isempty(ASRParams)
        ASRParams.ChannelCriterion = 'off'; end
end



if( get(handles.burstcheckbox, 'Value') )
    BurstCriterion = str2double(get(handles.burstedit, 'String'));
    if ~isnan(BurstCriterion)
        ASRParams.BurstCriterion = BurstCriterion; end
else
    if ~isempty(ASRParams)
        ASRParams.BurstCriterion = 'off'; end
end


if( get(handles.windowcheckbox, 'Value') )
    WindowCriterion = str2double(get(handles.windowedit, 'String'));
    if ~isnan(WindowCriterion)
        ASRParams.WindowCriterion = WindowCriterion; end
else
    if ~isempty(ASRParams)
        ASRParams.WindowCriterion = 'off'; end
end

if (    strcmp(ASRParams.LineNoiseCriterion, 'off') && ...
        strcmp(ASRParams.ChannelCriterion, 'off') && ...
        strcmp(ASRParams.BurstCriterion, 'off') && ...
        strcmp(ASRParams.WindowCriterion, 'off') && ... 
        strcmp(ASRParams.Highpass, 'off'))
    ASRParams = struct([]);
end

PrepParams = params.PrepParams;
rar_check = get(handles.rarcheckbox, 'Value');
if (rar_check && isempty(PrepParams))
    PrepParams = struct();
elseif ~rar_check
    PrepParams = struct([]);
end

if ~isempty(PrepParams)
   if( ~isfield(PrepParams, 'lineFrequencies') || isempty(PrepParams.lineFrequencies))
        res = str2double(get(handles.notchedit, 'String'));
        if ~isnan(res)
            PrepParams.lineFrequencies = res;
        else
            PrepParams = rmfield(PrepParams, 'lineFrequencies');
        end
        clear res;
    end 
end

HighvarParams = params.HighvarParams;
if (get(handles.highvarcheckbox, 'Value'))
     sd = str2double(get(handles.highvaredit, 'String'));
     if ~isnan(sd)
        HighvarParams.sd = sd; end
else
    HighvarParams = struct([]);
end

PCAParams = params.PCAParams;
if( get(handles.pcacheckbox, 'Value') )
    lambda = str2double(get(handles.lambdaedit, 'String'));
    tol = str2double(get(handles.toledit, 'String'));
    maxIter = str2double(get(handles.maxIteredit, 'String'));
    if isempty(PCAParams)
        PCAParams = struct(); end
    if ~isnan(lambda)
        PCAParams.lambda = lambda;
    else
        PCAParams.lambda = [];
    end
    if ~isnan(tol)
        PCAParams.tol = tol;
    else
        PCAParams.tol = [];
    end
    if ~isnan(maxIter)
        PCAParams.maxIter = maxIter;
    else
        PCAParams.maxIter = [];
    end
else
    PCAParams = struct([]);
end

idx = get(handles.interpolationpopupmenu, 'Value');
methods = get(handles.interpolationpopupmenu, 'String');
method = methods{idx};

h = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
mainGUI_handle = guidata(h);

% Get EOG regression
EOGRegressionParams = params.EOGRegressionParams;
EOGRegressionParams.performEOGRegression = get(handles.eogcheckbox, 'Value');
EOGRegressionParams.eogChans = str2num(get(handles.eogedit, 'String'));
if( ~get(mainGUI_handle.egiradio, 'Value') && ...
        get(handles.eogcheckbox, 'Value') && ...
        isempty(get(handles.eogedit, 'String')))
    popup_msg(['A list of channel indices seperated by space or',...
        ' comma must be given to determine EOG channels'],...
        'Error');
    error(['A list of channel indices seperated by space or',...
        ' comma must be given to determine EOG channels']);
end

% Get the downsampling rate
idx = get(handles.dspopupmenu, 'Value');
dsrates = get(handles.dspopupmenu, 'String');
ds = str2double(dsrates{idx});

handles.VisualisationParams.dsRate = ds;
handles.VisualisationParams.CalcQualityParams = CalcQualityParams;
handles.params.FilterParams.high = high;
handles.params.FilterParams.low = low;
handles.params.FilterParams.notch = notch;
handles.params.ASRParams = ASRParams;
handles.params.EOGRegressionParams = EOGRegressionParams;
handles.params.PrepParams = PrepParams;
handles.params.HighvarParams = HighvarParams;
handles.params.PCAParams = PCAParams;
handles.params.ICAParams = ICAParams;
handles.params.InterpolationParams.method = method;

function handles = switch_components(handles)

h = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
mainGUI_handle = guidata(h);
if(~ get(mainGUI_handle.egiradio, 'Value') && ...
        get(handles.eogcheckbox, 'Value'))
    set(handles.eogedit, 'enable', 'on');
else
    set(handles.eogedit, 'enable', 'off');
end
if( get(handles.highcheckbox, 'Value') )
    set(handles.highpassorderedit, 'enable', 'on');
    set(handles.highedit, 'enable', 'on');
else
    set(handles.highpassorderedit, 'enable', 'off');
    set(handles.highpassorderedit, 'String', '');
    set(handles.highedit, 'enable', 'off');
end

if( get(handles.lowcheckbox, 'Value') )
    set(handles.lowpassorderedit, 'enable', 'on');
    set(handles.lowedit, 'enable', 'on');
else
    set(handles.lowpassorderedit, 'enable', 'off');
    set(handles.lowpassorderedit, 'String', '');
    set(handles.lowedit, 'enable', 'off');
end

if( get(handles.asrhighcheckbox, 'Value') )
    set(handles.asrhighedit, 'enable', 'on');
else
    set(handles.asrhighedit, 'enable', 'off');
    set(handles.asrhighedit, 'String', '');
end

if( get(handles.linenoisecheckbox, 'Value') )
    set(handles.linenoiseedit, 'enable', 'on');
else
    set(handles.linenoiseedit, 'enable', 'off');
    set(handles.linenoiseedit, 'String', '');
end

if( get(handles.channelcriterioncheckbox, 'Value') )
    set(handles.channelcriterionedit, 'enable', 'on');
else
    set(handles.channelcriterionedit, 'enable', 'off');
    set(handles.channelcriterionedit, 'String', '');
end

if( get(handles.burstcheckbox, 'Value') )
    set(handles.burstedit, 'enable', 'on');
else
    set(handles.burstedit, 'enable', 'off');
    set(handles.burstedit, 'String', '');
end

if( get(handles.windowcheckbox, 'Value') )
    set(handles.windowedit, 'enable', 'on');
else
    set(handles.windowedit, 'enable', 'off');
    set(handles.windowedit, 'String', '');
end

if( get(handles.icacheckbox, 'Value'))
    set(handles.largemapcheckbox, 'enable', 'on');
    
    set(handles.icahighpasscheckbox, 'enable', 'on');
    if( get(handles.icahighpasscheckbox, 'Value') )
        set(handles.icahighpassedit, 'enable', 'on');
        set(handles.icahighpassorderedit, 'enable', 'on');
    else
        set(handles.icahighpassedit, 'enable', 'off');
        set(handles.icahighpassedit, 'String', '');
        set(handles.icahighpassorderedit, 'enable', 'off');
    end
else
    set(handles.largemapcheckbox, 'enable', 'off');
    set(handles.icahighpasscheckbox, 'enable', 'off');
    set(handles.icahighpasscheckbox, 'value', 0);
    set(handles.icahighpassedit, 'enable', 'off');
    set(handles.icahighpassorderedit, 'enable', 'off');
end

if( get(handles.pcacheckbox, 'Value') )
    set(handles.lambdaedit, 'enable', 'on');
    set(handles.toledit, 'enable', 'on');
    set(handles.maxIteredit, 'enable', 'on');
else
    set(handles.lambdaedit, 'enable', 'off');
    set(handles.toledit, 'enable', 'off');
    set(handles.maxIteredit, 'enable', 'off');
    set(handles.lambdaedit, 'String', '');
    set(handles.toledit, 'String', '');
    set(handles.maxIteredit, 'String', '');
end

if( get(handles.highvarcheckbox, 'Value'))
    set(handles.highvaredit, 'enable', 'on')
else
    set(handles.highvaredit, 'enable', 'off')
end


if( get(handles.rarcheckbox, 'Value'))
    set(handles.preppushbutton, 'enable', 'on')
else
    set(handles.preppushbutton, 'enable', 'off')
end

% --- Executes on button press in defaultpushbutton.
function defaultpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to defaultpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = set_gui(handles, handles.CGV.DefaultParams, ...
    handles.CGV.DefaultVisualisationParams);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in linenoisecheckbox.
function linenoisecheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to linenoisecheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    recs = handles.CGV.RecParams;
    set(handles.linenoiseedit, 'String', recs.ASRParams.LineNoiseCriterion)
end
handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of linenoisecheckbox


% --- Executes on button press in burstcheckbox.
function burstcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to burstcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    recs = handles.CGV.RecParams;
    set(handles.burstedit, 'String', recs.ASRParams.BurstCriterion)
    
    % Warn the user if two filterings are about to happen
    if( get(handles.asrhighcheckbox, 'Value') && get(handles.highcheckbox, 'Value') &&...
            (get(handles.burstcheckbox, 'Value') || ...
            get(handles.windowcheckbox, 'Value')))
        popup_msg(['Warning! This will make the preprocessing apply two high',...
            'pass filtering in your data. Please make sure you know what you are ',...
            'about to do'], 'WARNING')
    end
end
handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of burstcheckbox


% --- Executes on button press in channelcriterioncheckbox.
function channelcriterioncheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to channelcriterioncheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    recs = handles.CGV.RecParams;
    set(handles.channelcriterionedit, 'String', recs.ASRParams.ChannelCriterion)
end
handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of channelcriterioncheckbox

% --- Executes on button press in pcacheckbox.
function pcacheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to pcacheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(get(handles.pcacheckbox, 'Value') && get(handles.icacheckbox, 'Value'))
    set(handles.icacheckbox, 'Value', 0);
end
if get(hObject,'Value')
    recs = handles.CGV.RecParams;
    if isempty(recs.PCAParams.lambda)
        set(handles.lambdaedit, 'String', handles.CGV.DEFAULT_KEYWORD)
    else
        set(handles.lambdaedit, 'String', mat2str(recs.PCAParams.lambda))
    end
    set(handles.toledit, 'String', mat2str(recs.PCAParams.tol))
    set(handles.maxIteredit, 'String', mat2str(recs.PCAParams.maxIter))
end
handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of pcacheckbox

% --- Executes on button press in icacheckbox.
function icacheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to icacheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(get(handles.pcacheckbox, 'Value') && get(handles.icacheckbox, 'Value'))
    set(handles.pcacheckbox, 'Value', 0);
end

if (get(hObject,'Value') == get(hObject,'Max'))
    if ~isempty(handles.CGV.RecParams.ICAParams.high)
        set(handles.icahighpasscheckbox, 'Value', 1);
        val = num2str((handles.CGV.RecParams.ICAParams.high.freq));
        val_order = num2str((handles.CGV.RecParams.ICAParams.high.order));
        set(handles.icahighpassedit, 'String', val)
        if( isempty( val_order) )
            set(handles.icahighpassorderedit, 'String', handles.CGV.DEFAULT_KEYWORD);
        else
            set(handles.icahighpassorderedit, 'String', val_order);
        end
    else
        set(handles.icahighpasscheckbox, 'Value', 0);
    end
else
    set(handles.icahighpassedit, 'String', '');
    set(handles.icahighpassorderedit, 'String', '');
end

handles = switch_components(handles);

handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in okpushbutton.
function okpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    handles = get_inputs(handles);
catch
    return;
end
% Update handles structure
guidata(hObject, handles);

close('settingsGUI');

function handles = setLineNoise(freq, handles)

filt_cst = handles.CGV.PreprocessingCsts.FilterCsts;
if(~ isempty(freq) && freq == filt_cst.NOTCH_EU)
    set(handles.euradio, 'Value', 1)
    set(handles.notchedit, 'String', num2str(freq))
elseif(~ isempty(freq) && freq == filt_cst.NOTCH_US)
    set(handles.usradio, 'Value', 1)
    set(handles.notchedit, 'String', num2str(freq))
elseif(~isempty(freq))
    set(handles.otherradio, 'Value', 1)
    set(handles.notchedit, 'String', num2str(freq))
else
    set(handles.otherradio, 'Value', 1)
    set(handles.notchedit, 'String', '')
end

% --- Executes on button press in cancelpushbutton.
function cancelpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close('settingsGUI')

% --- Executes when user attempts to close settingsfigure.
function settingsfigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to settingsfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
if( isempty(h))
    h = mainGUI;
end
handle = guidata(h);
handle.params = handles.params;
handle.VisualisationParams = handles.VisualisationParams;
guidata(handle.mainGUI, handle);

delete(hObject);



function highpassorderedit_Callback(hObject, eventdata, handles)
% hObject    handle to highpassorderedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of highpassorderedit as text
%        str2double(get(hObject,'String')) returns contents of highpassorderedit as a double


% --- Executes during object creation, after setting all properties.
function highpassorderedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highpassorderedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lowpassorderedit_Callback(hObject, eventdata, handles)
% hObject    handle to lowpassorderedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowpassorderedit as text
%        str2double(get(hObject,'String')) returns contents of lowpassorderedit as a double


% --- Executes during object creation, after setting all properties.
function lowpassorderedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowpassorderedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Hint: get(hObject,'Value') returns toggle state of icacheckbox


function lambdaedit_Callback(hObject, eventdata, handles)
% hObject    handle to lambdaedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambdaedit as text
%        str2double(get(hObject,'String')) returns contents of lambdaedit as a double


% --- Executes during object creation, after setting all properties.
function lambdaedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambdaedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function toledit_Callback(hObject, eventdata, handles)
% hObject    handle to toledit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of toledit as text
%        str2double(get(hObject,'String')) returns contents of toledit as a double


% --- Executes during object creation, after setting all properties.
function toledit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toledit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxIteredit_Callback(hObject, eventdata, handles)
% hObject    handle to maxIteredit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxIteredit as text
%        str2double(get(hObject,'String')) returns contents of maxIteredit as a double


% --- Executes during object creation, after setting all properties.
function maxIteredit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxIteredit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in interpolationpopupmenu.
function interpolationpopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to interpolationpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns interpolationpopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from interpolationpopupmenu


% --- Executes during object creation, after setting all properties.
function interpolationpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interpolationpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Outputs from this function are returned to the command line.
function varargout = settingsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in highpasspopupmenu.
function highpasspopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to highpasspopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns highpasspopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from highpasspopupmenu


% --- Executes during object creation, after setting all properties.
function highpasspopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highpasspopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lowpasspopupmenu.
function lowpasspopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to lowpasspopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lowpasspopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lowpasspopupmenu


% --- Executes during object creation, after setting all properties.
function lowpasspopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowpasspopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function linenoiseedit_Callback(hObject, eventdata, handles)
% hObject    handle to linenoiseedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of linenoiseedit as text
%        str2double(get(hObject,'String')) returns contents of linenoiseedit as a double


% --- Executes during object creation, after setting all properties.
function linenoiseedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linenoiseedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function burstedit_Callback(hObject, eventdata, handles)
% hObject    handle to burstedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of burstedit as text
%        str2double(get(hObject,'String')) returns contents of burstedit as a double


% --- Executes during object creation, after setting all properties.
function burstedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to burstedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channelcriterionedit_Callback(hObject, eventdata, handles)
% hObject    handle to channelcriterionedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelcriterionedit as text
%        str2double(get(hObject,'String')) returns contents of channelcriterionedit as a double


% --- Executes during object creation, after setting all properties.
function channelcriterionedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelcriterionedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rarcheckbox.
function rarcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to rarcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.params.PrepParams = struct();
else
    handles.params.PrepParams = struct([]);
end
handles = switch_components(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in windowcheckbox.
function windowcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to windowcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    recs = handles.CGV.RecParams;
    set(handles.windowedit, 'String', mat2str(recs.ASRParams.WindowCriterion))
    
    % Warn the user if two filterings are about to happen
    if( get(handles.asrhighcheckbox, 'Value') && get(handles.highcheckbox, 'Value') &&...
            (get(handles.burstcheckbox, 'Value') || ...
            get(handles.windowcheckbox, 'Value')))
        popup_msg(['Warning! This will make the preprocessing apply two high',...
            'pass filtering in your data. Please make sure you know what you are ',...
            'about to do'], 'WARNING')
    end
end
handles = switch_components(handles);

% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of windowcheckbox



function windowedit_Callback(hObject, eventdata, handles)
% hObject    handle to windowedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windowedit as text
%        str2double(get(hObject,'String')) returns contents of windowedit as a double


% --- Executes during object creation, after setting all properties.
function windowedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in preppushbutton.
function preppushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to preppushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(~exist('pop_fileio', 'file'))
    add_eeglab_path();
    % Add path for 10_20 system
end

% Check and download if Robust Average Referencing does not exist
if( ~ exist('performReference.m', 'file'))
    download_rar();
end

% Create a dummy EEG structure to trick prep default function!
EEG = eeg_emptyset();
EEG.srate = 1024; % Dummy number!
EEG.data = zeros(1000, 1000); % Dummy dimensions!
EEG.chanlocs = struct();
EEG.chaninfo = struct();
rar_params = handles.params.PrepParams;
                                    
userData = struct('boundary', [], 'detrend', [], ...
    'lineNoise', [], 'reference', [], ...
    'report', [],  'postProcess', []);
stepNames = fieldnames(userData);
for k = 1:length(stepNames)
    defaults = getPrepDefaults(EEG, stepNames{k});
    [theseValues, errors] = checkStructureDefaults(rar_params, ...
        defaults);
    if ~isempty(errors)
        error('pop_prepPipeline:BadParameters', ['|' ...
            sprintf('%s|', errors{:})]);
    end
    userData.(stepNames{k}) = theseValues;
end

if ~isfield(rar_params, 'detrendChannels') || ...
        (isfield(rar_params, 'detrendChannels') && ...
        rar_params.detrendChannels ~= userData.detrend.detrendChannels.value)
    userData.detrend.detrendChannels.value = -1;
end

if ~isfield(rar_params, 'referenceChannels') || ...
        (isfield(rar_params, 'referenceChannels') && ...
        rar_params.referenceChannels ~= ...
        userData.reference.referenceChannels.value)
    userData.reference.referenceChannels.value = -1;
end

if ~isfield(rar_params, 'evaluationChannels') || ...
        (isfield(rar_params, 'evaluationChannels') && ...
        rar_params.evaluationChannels ~= ...
        userData.reference.evaluationChannels.value)
    userData.reference.evaluationChannels.value = -1;
end

if ~isfield(rar_params, 'rereferencedChannels') || ...
        (isfield(rar_params, 'rereferencedChannels') && ...
        rar_params.rereferencedChannels ~= ...
        userData.reference.rereferencedChannels.value)
    userData.reference.rereferencedChannels.value = -1;
end

if ~isfield(rar_params, 'lineNoiseChannels') || ...
        (isfield(rar_params, 'lineNoiseChannels') && ...
        rar_params.lineNoiseChannels ~= ...
        userData.lineNoise.lineNoiseChannels.value)
    userData.lineNoise.lineNoiseChannels.value = -1;
end

if ~isfield(rar_params, 'detrendCutoff') || ...
        (isfield(rar_params, 'detrendCutoff') && ...
        rar_params.detrendCutoff ~= userData.detrend.detrendCutoff.value)
    userData.detrend.detrendCutoff.value = [];
end

if ~isfield(rar_params, 'localCutoff') || ...
        (isfield(rar_params, 'localCutoff') && ...
        rar_params.localCutoff ~= userData.globaltrend.localCutoff.value)
    userData.globaltrend.localCutoff.value = [] ;
end

if ~isfield(rar_params, 'globalTrendChannels') || ...
        (isfield(rar_params, 'globalTrendChannels') && ...
        rar_params.globalTrendChannels ~= ...
        userData.globaltrend.globalTrendChannels.value)
    userData.globaltrend.globalTrendChannels.value = [];
end

if ~isfield(rar_params, 'Fs') || ...
        (isfield(rar_params, 'Fs') && rar_params.Fs ~= userData.lineNoise.Fs.value)
    userData.lineNoise.Fs.value = [];
end

if ~isfield(rar_params, 'lineFrequencies') || ...
        (isfield(rar_params, 'lineFrequencies') && ...
        rar_params.lineFrequencies ~= userData.lineNoise.lineFrequencies.value)
    userData.lineNoise.lineFrequencies.value = [];
end

if ~isfield(rar_params, 'fPassBand') || ...
        (isfield(rar_params, 'fPassBand') && ...
        rar_params.fPassBand ~= userData.lineNoise.fPassBand.value)
    userData.lineNoise.fPassBand.value = [];
end

if ~isfield(rar_params, 'srate') || ...
        (isfield(rar_params, 'srate') && ...
        rar_params.srate ~= userData.reference.srate.value)
    userData.reference.srate.value = [];
end

[~, rar_params, okay] = evalc('MasterGUI([],[],userData, EEG)');

if okay
    % This is not set by the gui anyways
    if isfield(rar_params, 'samples')
        rar_params = rmfield(rar_params, 'samples');
    end
    
    % This is not set by the gui anyways
    if isfield(rar_params, 'channelLocations')
        rar_params = rmfield(rar_params, 'channelLocations');
    end
    
    % This is not set by the gui anyways
    if isfield(rar_params, 'channelInformation')
        rar_params = rmfield(rar_params, 'channelInformation');
    end
    
    % Lists that are -1 are not set by the gui
    if isfield(rar_params, 'detrendChannels') && ...
            rar_params.detrendChannels == -1
        rar_params = rmfield(rar_params, 'detrendChannels');
    end
    
    % Lists that are -1 are not set by the gui
    if isfield(rar_params, 'lineNoiseChannels') && ...
            rar_params.lineNoiseChannels == -1
        rar_params = rmfield(rar_params, 'lineNoiseChannels');
    end
    
    % Lists that are -1 are not set by the gui
    if isfield(rar_params, 'referenceChannels') && ...
            rar_params.referenceChannels == -1
        rar_params = rmfield(rar_params, 'referenceChannels');
    end
    
    % Lists that are -1 are not set by the gui
    if isfield(rar_params, 'evaluationChannels') && ...
            rar_params.evaluationChannels == -1
        rar_params = rmfield(rar_params, 'evaluationChannels');
    end
    
    % Lists that are -1 are not set by the gui
    if isfield(rar_params, 'rereferencedChannels') && ...
            rar_params.rereferencedChannels == -1
        rar_params = rmfield(rar_params, 'rereferencedChannels');
    end
    
    if isfield(rar_params, 'detrendCutoff') && ...
            isempty(rar_params.detrendCutoff)
        rar_params = rmfield(rar_params, 'detrendCutoff');
    end
    
    if isfield(rar_params, 'localCutoff') && ...
            isempty(rar_params.localCutoff)
        rar_params = rmfield(rar_params, 'localCutoff');
    end
    
    if isfield(rar_params, 'globalTrendChannels') && ...
            isempty(rar_params.globalTrendChannels)
        rar_params = rmfield(rar_params, 'globalTrendChannels');
    end
    
    if isfield(rar_params, 'Fs') && isempty(rar_params.Fs)
        rar_params = rmfield(rar_params, 'Fs');
    end
    
    if isfield(rar_params, 'lineFrequencies') && ...
            isempty(rar_params.lineFrequencies)
        rar_params = rmfield(rar_params, 'lineFrequencies');
    end
    
    if isfield(rar_params, 'fPassBand') && isempty(rar_params.fPassBand)
        rar_params = rmfield(rar_params, 'fPassBand');
    end
    
    if isfield(rar_params, 'srate') && isempty(rar_params.srate)
        rar_params = rmfield(rar_params, 'srate');
    end
end

clear defaults;
stepNames = fieldnames(userData);
for k = 1:length(stepNames)
    defaults = getPrepDefaults(EEG, stepNames{k});
    [theseValues, errors] = checkDefaults(rar_params, rar_params, defaults);
    if ~isempty(errors)
        popup_msg(['Wrong parameters for prep: ', ...
            sprintf('%s', errors{:})], 'Error');
        return;
    end
    userData.(stepNames{k}) = theseValues;
end

handles.params.PrepParams = rar_params;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in largemapcheckbox.
function largemapcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to largemapcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of largemapcheckbox


% --- Executes on button press in asrhighcheckbox.
function asrhighcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to asrhighcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of asrhighcheckbox
if get(hObject,'Value')
    recs = handles.CGV.RecParams;
    set(handles.asrhighedit, 'String', mat2str(recs.ASRParams.Highpass))
    
    % Warn the user if two filterings are about to happen
    if( get(handles.asrhighcheckbox, 'Value') && ...
            get(handles.highcheckbox, 'Value') && ...
            (get(handles.burstcheckbox, 'Value') || ...
            get(handles.windowcheckbox, 'Value')))
        popup_msg(['Warning! This will make the preprocessing apply two high',...
            'pass filtering in your data. Please make sure what you are ',...
            'about to do'], 'WARNING')
    end
end
handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);


function asrhighedit_Callback(hObject, eventdata, handles)
% hObject    handle to asrhighedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of asrhighedit as text
%        str2double(get(hObject,'String')) returns contents of asrhighedit as a double


% --- Executes during object creation, after setting all properties.
function asrhighedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to asrhighedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dspopupmenu.
function dspopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to dspopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dspopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dspopupmenu


% --- Executes during object creation, after setting all properties.
function dspopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dspopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in eogcheckbox.
function eogcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to eogcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch_components(handles);
% Hint: get(hObject,'Value') returns toggle state of eogcheckbox



function eogedit_Callback(hObject, eventdata, handles)
% hObject    handle to eogedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eogedit as text
%        str2double(get(hObject,'String')) returns contents of eogedit as a double


% --- Executes during object creation, after setting all properties.
function eogedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eogedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function notchedit_Callback(hObject, eventdata, handles)
% hObject    handle to notchedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
freq = str2double(get(hObject,'String'));
setLineNoise(freq, handles)
% Hints: get(hObject,'String') returns contents of notchedit as text
%        str2double(get(hObject,'String')) returns contents of notchedit as a double


% --- Executes during object creation, after setting all properties.
function notchedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notchedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lowedit_Callback(hObject, eventdata, handles)
% hObject    handle to lowedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowedit as text
%        str2double(get(hObject,'String')) returns contents of lowedit as a double


% --- Executes during object creation, after setting all properties.
function lowedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in lowcheckbox.
function lowcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to lowcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    val = num2str((handles.CGV.RecParams.FilterParams.low.freq));
    val_order = num2str((handles.CGV.RecParams.FilterParams.low.order));
    set(handles.lowedit, 'String', val)
    if( isempty( val_order) )
        set(handles.lowpassorderedit, 'String', handles.CGV.DEFAULT_KEYWORD);
    else
        set(handles.lowpassorderedit, 'String', val_order);
    end
else
    set(handles.lowedit, 'String', '');
    set(handles.lowpassorderedit, 'String', '');
end

handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of lowcheckbox



function highedit_Callback(hObject, eventdata, handles)
% hObject    handle to highedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of highedit as text
%        str2double(get(hObject,'String')) returns contents of highedit as a double


% --- Executes during object creation, after setting all properties.
function highedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in highcheckbox.
function highcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to highcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    val = num2str((handles.CGV.RecParams.FilterParams.high.freq));
    val_order = num2str((handles.CGV.RecParams.FilterParams.high.order));
    set(handles.highedit, 'String', val)
    if( isempty( val_order) )
        set(handles.highpassorderedit, 'String', handles.CGV.DEFAULT_KEYWORD);
    else
        set(handles.highpassorderedit, 'String', val_order);
    end
    
    % Warn the user if two filterings are about to happen
    if( get(handles.asrhighcheckbox, 'Value') && get(handles.highcheckbox, 'Value') &&...
            (get(handles.burstcheckbox, 'Value') || ...
            get(handles.windowcheckbox, 'Value')))
        popup_msg(['Warning! This will make the preprocessing apply two high',...
            'pass filtering in your data. Please make sure what you are ',...
            'about to do'], 'WARNING')
    end
else
    set(handles.highedit, 'String', '');
    set(handles.highpassorderedit, 'String', '');
end

handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of highcheckbox


% --- Executes when selected object is changed in notchbuttongroup.
function notchbuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in notchbuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FilterCsts = handles.CGV.PreprocessingCsts.FilterCsts;
switch get(hObject, 'Tag')
   case 'euradio'
      set(handles.notchedit, 'String', num2str(FilterCsts.NOTCH_EU))
   case 'usradio'
      set(handles.notchedit, 'String', num2str(FilterCsts.NOTCH_US))
    case 'otherradio'
      set(handles.notchedit, 'String', num2str(FilterCsts.notch_other))
end


% --- Executes on button press in highvarcheckbox.
function highvarcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to highvarcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    recs = handles.CGV.RecParams;
    set(handles.highvaredit, 'String', mat2str(recs.HighvarParams.sd))
end
handles = switch_components(handles);

% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of highvarcheckbox



function highvaredit_Callback(hObject, eventdata, handles)
% hObject    handle to highvaredit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of highvaredit as text
%        str2double(get(hObject,'String')) returns contents of highvaredit as a double


% --- Executes during object creation, after setting all properties.
function highvaredit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highvaredit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function overalledit_Callback(hObject, eventdata, handles)
% hObject    handle to overalledit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overalledit as text
%        str2double(get(hObject,'String')) returns contents of overalledit as a double


% --- Executes during object creation, after setting all properties.
function overalledit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overalledit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeedit_Callback(hObject, eventdata, handles)
% hObject    handle to timeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeedit as text
%        str2double(get(hObject,'String')) returns contents of timeedit as a double


% --- Executes during object creation, after setting all properties.
function timeedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function channelthresholdedit_Callback(hObject, eventdata, handles)
% hObject    handle to channelthresholdedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelthresholdedit as text
%        str2double(get(hObject,'String')) returns contents of channelthresholdedit as a double


% --- Executes during object creation, after setting all properties.
function channelthresholdedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelthresholdedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in icahighpasscheckbox.
function icahighpasscheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to icahighpasscheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of icahighpasscheckbox
if (get(hObject,'Value') == get(hObject,'Max'))
    val = num2str((handles.CGV.RecParams.ICAParams.high.freq));
    val_order = num2str((handles.CGV.RecParams.ICAParams.high.order));
    set(handles.icahighpassedit, 'String', val)
    if( isempty( val_order) )
        set(handles.icahighpassorderedit, 'String', handles.CGV.DEFAULT_KEYWORD);
    else
        set(handles.icahighpassorderedit, 'String', val_order);
    end
else
    set(handles.icahighpassedit, 'String', '');
    set(handles.icahighpassorderedit, 'String', '');
end

handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);


function icahighpassedit_Callback(hObject, eventdata, handles)
% hObject    handle to icahighpassedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of icahighpassedit as text
%        str2double(get(hObject,'String')) returns contents of icahighpassedit as a double


% --- Executes during object creation, after setting all properties.
function icahighpassedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to icahighpassedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function icahighpassorderedit_Callback(hObject, eventdata, handles)
% hObject    handle to icahighpassorderedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of icahighpassorderedit as text
%        str2double(get(hObject,'String')) returns contents of icahighpassorderedit as a double


% --- Executes during object creation, after setting all properties.
function icahighpassorderedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to icahighpassorderedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in euradio.
function euradio_Callback(hObject, eventdata, handles)
% hObject    handle to euradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of euradio


% --- Executes on button press in notchcheckbox.
function notchcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to notchcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of notchcheckbox
