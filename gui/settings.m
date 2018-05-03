function varargout = settings(varargin)
% SETTINGS MATLAB code for settings.fig
%      SETTINGS, by itself, creates a new SETTINGS or raises the existing
%      singleton*.
%
%      H = SETTINGS returns the handle to a new SETTINGS or the handle to
%      the existing singleton*.
%
%      SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETTINGS.M with the given input arguments.
%
%      SETTINGS('Property','Value',...) creates a new SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to settings_OpeningFcn via varargin.
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

% Last Modified by GUIDE v2.5 03-May-2018 17:14:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @settings_OpeningFcn, ...
                   'gui_OutputFcn',  @settings_OutputFcn, ...
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


% --- Executes just before settings is made visible.
function settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to settings (see VARARGIN)

if( nargin - 3 ~= 1 )
    error('wrong number of arguments. Project must be given as argument.')
end

set(handles.settingsfigure, 'units', 'normalized', 'position', [0.05 0.2 0.6 0.8])
set(handles.settingspanel, 'units', 'normalized', 'position', [0.05 0.1 0.8 0.9])
children = handles.settingsfigure.Children;
for child_idx = 1:length(children)
    child = children(child_idx);
    set(child, 'units', 'normalized')
    for grandchild_idx = 1:length(child.Children)
       grandchild = child.Children(grandchild_idx);
       set(grandchild, 'units', 'normalized')
    end
end

CGV = ConstantGlobalValues;
params = varargin{1};
assert(isa(params, 'struct'));
handles.params = params;
handles.CGV = CGV;

assert( isempty(handles.params.pca_params) || ...
    isempty(handles.params.ica_params), ...
    'Either pca or ica, not both together.');

if(~isempty(params.filter_params))
    if(~isempty(params.filter_params.high))
        if( isempty( params.filter_params.high.order) )
            set(handles.highpassorderedit, 'String', CGV.DEFAULT_keyword);
        else
            set(handles.highpassorderedit, 'String', params.filter_params.high.order);
        end
    else
        set(handles.highpassorderedit, 'String', '');
    end
    
    if(~isempty(params.filter_params.low))
        if( isempty( params.filter_params.low.order) )
            set(handles.lowpassorderedit, 'String', CGV.DEFAULT_keyword);
        else
            set(handles.lowpassorderedit, 'String', params.filter_params.low.order);
        end
    else
        set(handles.lowpassorderedit, 'String', '');
    end
else
    set(handles.highpassorderedit, 'String', '');
    set(handles.lowpassorderedit, 'String', '');
end

if ~isempty(params.asr_params)
   if( ~strcmp(params.asr_params.Highpass, 'off'))
        set(handles.asrhighcheckbox, 'Value', 1);
    else
        set(handles.asrhighcheckbox, 'Value', 0);
    end
    set(handles.asrhighedit, 'String', mat2str(params.asr_params.Highpass));
    
    if( ~strcmp(params.asr_params.ChannelCriterion, 'off'))
        set(handles.channelcriterioncheckbox, 'Value', 1);
    else
        set(handles.channelcriterioncheckbox, 'Value', 0);
    end
    set(handles.channelcriterionedit, 'String', params.asr_params.ChannelCriterion);
    
    if( ~strcmp(params.asr_params.LineNoiseCriterion, 'off'))
        set(handles.linenoisecheckbox, 'Value', 1);
    else
        set(handles.linenoisecheckbox, 'Value', 0);
    end
    set(handles.linenoiseedit, 'String', params.asr_params.LineNoiseCriterion);
    
    if( ~strcmp(params.asr_params.BurstCriterion, 'off'))
        set(handles.burstcheckbox, 'Value', 1);
    else
        set(handles.burstcheckbox, 'Value', 0);
    end
    set(handles.burstedit, 'String', params.asr_params.BurstCriterion);
    
    if( ~strcmp(params.asr_params.WindowCriterion, 'off'))
        set(handles.windowcheckbox, 'Value', 1);
    else
        set(handles.windowcheckbox, 'Value', 0);
    end
    set(handles.windowedit, 'String', params.asr_params.WindowCriterion);
end

if( ~isempty(params.prep_params))
    set(handles.rarcheckbox, 'Value', 1);
else
    set(handles.rarcheckbox, 'Value', 0);
end

if( ~isempty(params.pca_params))
    set(handles.pcacheckbox, 'Value', 1);
    if( isempty( params.pca_params.lambda ))
       set(handles.lambdaedit, 'String', CGV.DEFAULT_keyword);
    else
        set(handles.lambdaedit, 'String', params.pca_params.lambda); 
    end
    set(handles.toledit, 'String', params.pca_params.tol);
    set(handles.maxIteredit, 'String', params.pca_params.maxIter);
else
    set(handles.pcacheckbox, 'Value', 0);
    set(handles.lambdaedit, 'String', '');
    set(handles.toledit, 'String', '');
    set(handles.maxIteredit, 'String', '');
end

set(handles.icacheckbox, 'Value', ~isempty(params.ica_params));
if ~isempty(params.ica_params)
    set(handles.largemapcheckbox, 'Value', params.ica_params.large_map)
end

IndexC = strcmp(handles.interpolationpopupmenu.String, params.interpolation_params.method);
Index = find(IndexC == 1);
set(handles.interpolationpopupmenu,...
    'String',handles.interpolationpopupmenu.String,...
    'Value', Index);
        
handles = switch_components(handles);


% Choose default command line output for settings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes settings wait for user response (see UIRESUME)
% uiwait(handles.settingsfigure);

% --- Executes on button press in linenoisecheckbox.
function linenoisecheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to linenoisecheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of linenoisecheckbox


% --- Executes on button press in burstcheckbox.
function burstcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to burstcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = switch_components(handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of burstcheckbox


% --- Executes on button press in channelcriterioncheckbox.
function channelcriterioncheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to channelcriterioncheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

close('settings');

function handles = get_inputs(handles)

h = findobj(allchild(0), 'flat', 'Tag', 'main_gui');
main_gui_handle = guidata(h);
params = handles.params;

ica_params = params.ica_params;
if get(handles.icacheckbox, 'Value')
    ica_params.large_map = get(handles.largemapcheckbox, 'Value');
else
    ica_params = struct([]);
end

high = params.filter_params.high;
if( get(main_gui_handle.highpasscheckbox, 'Value') && ~isempty(high))
    res = str2double(get(handles.highpassorderedit, 'String'));
    if ~isnan(res)
        high.order = res; end
end
clear res;

low = params.filter_params.low;
if( get(main_gui_handle.lowpasscheckbox, 'Value') && ~isempty(low))
    res = str2double(get(handles.lowpassorderedit, 'String'));
    if ~isnan(res)
        low.order = res; end
end
clear res;

asr_params = params.asr_params;
if( get(handles.asrhighcheckbox, 'Value') )
    highpass_val = str2num(get(handles.asrhighedit, 'String'));
    if(length(highpass_val) ~= 2)
        popup_msg('High pass parameter for ASR must be an array of length 2 like [0.25 0.75]', 'Error');
        error('High pass parameter for ASR must be an array of length 2 like [0.25 0.75]');
    end
    if( ~isnan(highpass_val))
        asr_params.Highpass = highpass_val; end
else
    if ~isempty(asr_params)
        asr_params.Highpass = 'off'; end
end

if( get(handles.linenoisecheckbox, 'Value') )
    linenoise_val = str2double(get(handles.linenoiseedit, 'String'));
    if( ~isnan(linenoise_val))
        asr_params.LineNoiseCriterion = linenoise_val; end
else
    if ~isempty(asr_params)
        asr_params.LineNoiseCriterion = 'off'; end
end


if( get(handles.channelcriterioncheckbox, 'Value') )
    ChannelCriterion = str2double(get(handles.channelcriterionedit, 'String'));
    if( ~isnan(ChannelCriterion))
        asr_params.ChannelCriterion = ChannelCriterion; end
else
    if ~isempty(asr_params)
        asr_params.ChannelCriterion = 'off'; end
end



if( get(handles.burstcheckbox, 'Value') )
    BurstCriterion = str2double(get(handles.burstedit, 'String'));
    if ~isnan(BurstCriterion)
        asr_params.BurstCriterion = BurstCriterion; end
else
    if ~isempty(asr_params)
        asr_params.BurstCriterion = 'off'; end
end


if( get(handles.windowcheckbox, 'Value') )
    WindowCriterion = str2double(get(handles.windowedit, 'String'));
    if ~isnan(WindowCriterion)
        asr_params.WindowCriterion = WindowCriterion; end
else
    if ~isempty(asr_params)
        asr_params.WindowCriterion = 'off'; end
end

prep_params = params.prep_params;
rar_check = get(handles.rarcheckbox, 'Value');
if (rar_check && isempty(prep_params))
    prep_params = struct();
elseif ~rar_check
    prep_params = struct([]);
end

pca_params = params.pca_params;
if( get(handles.pcacheckbox, 'Value') )
    lambda = str2double(get(handles.lambdaedit, 'String'));
    tol = str2double(get(handles.toledit, 'String'));
    maxIter = str2double(get(handles.maxIteredit, 'String'));
    
    if ~isnan(lambda) && ~isnan(tol) && ~isnan(maxIter)
        if isempty(pca_params)
            pca_params = struct(); end
        pca_params.lambda = lambda;
        pca_params.tol = tol;
        pca_params.maxIter = maxIter;
    end
else
    pca_params = struct([]);
end

idx = get(handles.interpolationpopupmenu, 'Value');
methods = get(handles.interpolationpopupmenu, 'String');
method = methods{idx};

handles.params.filter_params.high = high;
handles.params.filter_params.low = low;
handles.params.asr_params = asr_params;
handles.params.prep_params = prep_params;
handles.params.pca_params = pca_params;
handles.params.ica_params = ica_params;
handles.params.interpolation_params.method = method;


% --- Executes on button press in defaultpushbutton.
function defaultpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to defaultpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CGV = handles.CGV;
defs = CGV.default_params;
params = handles.params;

if ~isempty(defs.filter_params)
    if ~isempty(defs.filter_params.high) && ~isempty(params.filter_params.high)
        if isempty(defs.filter_params.high.order)
            set(handles.highpassorderedit, 'String', CGV.DEFAULT_keyword);
        else
            set(handles.highpassorderedit, 'String', defs.filter_params.high.order);
        end
    else
        set(handles.highpassorderedit, 'String', '')
    end

    if ~isempty(defs.filter_params.low) && ~isempty(params.filter_params.low)
        if isempty(defs.filter_params.low.order)
            set(handles.lowpassorderedit, 'String', CGV.DEFAULT_keyword);
        else
            set(handles.lowpassorderedit, 'String', defs.filter_params.low.order);
        end
    else
        set(handles.lowpassorderedit, 'String', '')
    end
else
    set(handles.highpassorderedit, 'String', '')
    set(handles.lowpassorderedit, 'String', '')
end

set(handles.icacheckbox, 'Value', ~isempty(defs.ica_params));
if ~isempty(defs.ica_params)
    set(handles.largemapcheckbox, 'Value', defs.ica_params.large_map)
else
    set(handles.largemapcheckbox, 'Value', 0)
end

if ~isempty(defs.asr_params)
    if( ~strcmp(defs.asr_params.Highpass, 'off'))
        set(handles.asrhighcheckbox, 'Value', 1);
    else
        set(handles.asrhighcheckbox, 'Value', 0);
    end
    set(handles.asrhighedit, 'String', ...
            str2mat(defs.asr_params.Highpass));
        
    if( ~strcmp(defs.asr_params.LineNoiseCriterion, 'off'))
        set(handles.linenoisecheckbox, 'Value', 1);
    else
        set(handles.linenoisecheckbox, 'Value', 0);
    end
    set(handles.linenoiseedit, 'String', ...
            defs.asr_params.LineNoiseCriterion);
        
    if( ~strcmp(defs.asr_params.ChannelCriterion, 'off'))
        set(handles.channelcriterioncheckbox, 'Value', 1);
    else
        set(handles.channelcriterioncheckbox, 'Value', 0);
    end
    set(handles.channelcriterionedit, 'String', ...
            CGV.default_params.asr_params.ChannelCriterion);
        
    if( ~strcmp(defs.asr_params.BurstCriterion, 'off'))
        set(handles.burstcheckbox, 'Value', 1);
    else
        set(handles.burstcheckbox, 'Value', 0);
    end
    set(handles.burstedit, 'String', ...
            CGV.default_params.asr_params.BurstCriterion);
        
    if( ~strcmp(defs.asr_params.WindowCriterion, 'off'))
        set(handles.windowcheckbox, 'Value', 1);
    else
        set(handles.windowcheckbox, 'Value', 0);
    end
    set(handles.windowedit, 'String', ...
            CGV.default_params.asr_params.WindowCriterion);
end
set(handles.rarcheckbox, 'Value', ~isempty(defs.prep_params));

if ~isempty(defs.pca_params)
    set(handles.pcacheckbox, 'Value', 1);
    if( isempty(defs.pca_params.lambda))
        set(handles.lambdaedit, 'String', CGV.DEFAULT_keyword);
    else
        set(handles.lambdaedit, 'String', defs.pca_params.lambda);
    end
        set(handles.toledit, 'String', defs.pca_params.tol);
        set(handles.maxIteredit, 'String', defs.pca_params.maxIter);
else
    set(handles.pcacheckbox, 'Value', 0);
    set(handles.lambdaedit, 'String', '');
    set(handles.toledit, 'String', '');
    set(handles.maxIteredit, 'String', '');
end
IndexC = strfind(handles.interpolationpopupmenu.String, ...
    defs.interpolation_params.method);
index = find(not(cellfun('isempty', IndexC)));
set(handles.interpolationpopupmenu, 'Value', index);

handles = switch_components(handles);

% Update handles structure
guidata(hObject, handles);

function handles = switch_components(handles)

h = findobj(allchild(0), 'flat', 'Tag', 'main_gui');
main_gui_handle = guidata(h);

CGV = handles.CGV;
recs = CGV.rec_params;

if( get(main_gui_handle.highpasscheckbox, 'Value') )
    set(handles.highpassorderedit, 'enable', 'on');
    if (~isempty(recs.filter_params.high.order))
        set(handles.highpassorderedit, 'String', recs.filter_params.high.order);
    else
        set(handles.highpassorderedit, 'String', CGV.DEFAULT_keyword)
    end
else
    set(handles.highpassorderedit, 'enable', 'off');
    set(handles.highpassorderedit, 'String', '');
end

if( get(main_gui_handle.lowpasscheckbox, 'Value') )
    set(handles.lowpassorderedit, 'enable', 'on');
    if (~isempty(recs.filter_params.high.order))
        set(handles.lowpassorderedit, 'String', recs.filter_params.low.order);
    else
        set(handles.lowpassorderedit, 'String', CGV.DEFAULT_keyword)
    end
else
    set(handles.lowpassorderedit, 'enable', 'off');
    set(handles.lowpassorderedit, 'String', '');
end

if( get(handles.asrhighcheckbox, 'Value') )
    set(handles.asrhighedit, 'enable', 'on');
    set(handles.asrhighedit, 'String', mat2str(recs.asr_params.Highpass));
else
    set(handles.asrhighedit, 'enable', 'off');
    set(handles.asrhighedit, 'String', '');
end

if( get(handles.linenoisecheckbox, 'Value') )
    set(handles.linenoiseedit, 'enable', 'on');
    set(handles.linenoiseedit, 'String', recs.asr_params.LineNoiseCriterion);
else
    set(handles.linenoiseedit, 'enable', 'off');
    set(handles.linenoiseedit, 'String', '');
end

if( get(handles.channelcriterioncheckbox, 'Value') )
    set(handles.channelcriterionedit, 'enable', 'on');
    set(handles.channelcriterionedit, 'String', recs.asr_params.ChannelCriterion);
else
    set(handles.channelcriterionedit, 'enable', 'off');
    set(handles.channelcriterionedit, 'String', '');
end

if( get(handles.burstcheckbox, 'Value') )
    set(handles.burstedit, 'String', recs.asr_params.BurstCriterion);
    set(handles.burstedit, 'enable', 'on');
else
    set(handles.burstedit, 'enable', 'off');
    set(handles.burstedit, 'String', '');
end

if( get(handles.windowcheckbox, 'Value') )
    set(handles.windowedit, 'String', recs.asr_params.WindowCriterion);
    set(handles.windowedit, 'enable', 'on');
else
    set(handles.windowedit, 'enable', 'off');
    set(handles.windowedit, 'String', '');
end

if( get(handles.icacheckbox, 'Value'))
    set(handles.largemapcheckbox, 'enable', 'on');
else
    set(handles.largemapcheckbox, 'enable', 'off');
end
if( get(handles.pcacheckbox, 'Value') )
    set(handles.lambdaedit, 'enable', 'on');
    set(handles.toledit, 'enable', 'on');
    set(handles.maxIteredit, 'enable', 'on');
    if(~isempty(recs.pca_params.lambda))
        set(handles.lambdaedit, 'String', recs.pca_params.lambda);
    else
        set(handles.lambdaedit, 'String', CGV.DEFAULT_keyword);
    end
    set(handles.toledit, 'String', recs.pca_params.tol);
    set(handles.maxIteredit, 'String', recs.pca_params.maxIter);
else
    set(handles.lambdaedit, 'enable', 'off');
    set(handles.toledit, 'enable', 'off');
    set(handles.maxIteredit, 'enable', 'off');
    set(handles.lambdaedit, 'String', '');
    set(handles.toledit, 'String', '');
    set(handles.maxIteredit, 'String', '');
end

if( get(handles.rarcheckbox, 'Value'))
    set(handles.preppushbutton, 'enable', 'on')
else
    set(handles.preppushbutton, 'enable', 'off')
end

% --- Executes on button press in cancelpushbutton.
function cancelpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close('settings')

% --- Executes when user attempts to close settingsfigure.
function settingsfigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to settingsfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = findobj(allchild(0), 'flat', 'Tag', 'main_gui');
if( isempty(h))
    h = main_gui;
end
handle = guidata(h);
handle.params = handles.params;
guidata(handle.main_gui, handle);

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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Outputs from this function are returned to the command line.
function varargout = settings_OutputFcn(hObject, eventdata, handles) 
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rarcheckbox.
function rarcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to rarcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.params.prep_params = struct();
else
    handles.params.prep_params = struct([]);
end
handles = switch_components(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in windowcheckbox.
function windowcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to windowcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = switch_components(handles);
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
rar_params = handles.params.prep_params;
                                    
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
        (isfield(rar_params, 'detrendChannels') && rar_params.detrendChannels ~= userData.detrend.detrendChannels.value)
    userData.detrend.detrendChannels.value = -1;
end

if ~isfield(rar_params, 'referenceChannels') || ...
        (isfield(rar_params, 'referenceChannels') && rar_params.referenceChannels ~= userData.reference.referenceChannels.value)
    userData.reference.referenceChannels.value = -1;
end

if ~isfield(rar_params, 'evaluationChannels') || ...
        (isfield(rar_params, 'evaluationChannels') && rar_params.evaluationChannels ~= userData.reference.evaluationChannels.value)
    userData.reference.evaluationChannels.value = -1;
end

if ~isfield(rar_params, 'rereferencedChannels') || ...
        (isfield(rar_params, 'rereferencedChannels') && rar_params.rereferencedChannels ~= userData.reference.rereferencedChannels.value)
    userData.reference.rereferencedChannels.value = -1;
end

if ~isfield(rar_params, 'lineNoiseChannels') || ...
        (isfield(rar_params, 'lineNoiseChannels') && rar_params.lineNoiseChannels ~= userData.lineNoise.lineNoiseChannels.value)
    userData.lineNoise.lineNoiseChannels.value = -1;
end

if ~isfield(rar_params, 'detrendCutoff') || ...
        (isfield(rar_params, 'detrendCutoff') && rar_params.detrendCutoff ~= userData.detrend.detrendCutoff.value)
    userData.detrend.detrendCutoff.value = [];
end

if ~isfield(rar_params, 'localCutoff') || ...
        (isfield(rar_params, 'localCutoff') && rar_params.localCutoff ~= userData.globaltrend.localCutoff.value)
    userData.globaltrend.localCutoff.value = [] ;
end

if ~isfield(rar_params, 'globalTrendChannels') || ...
        (isfield(rar_params, 'globalTrendChannels') && rar_params.globalTrendChannels ~= userData.globaltrend.globalTrendChannels.value)
    userData.globaltrend.globalTrendChannels.value = [];
end

if ~isfield(rar_params, 'Fs') || ...
        (isfield(rar_params, 'Fs') && rar_params.Fs ~= userData.lineNoise.Fs.value)
    userData.lineNoise.Fs.value = [];
end

if ~isfield(rar_params, 'lineFrequencies') || ...
        (isfield(rar_params, 'lineFrequencies') && rar_params.lineFrequencies ~= userData.lineNoise.lineFrequencies.value)
    userData.lineNoise.lineFrequencies.value = [];
end

if ~isfield(rar_params, 'fPassBand') || ...
        (isfield(rar_params, 'fPassBand') && rar_params.fPassBand ~= userData.lineNoise.fPassBand.value)
    userData.lineNoise.fPassBand.value = [];
end

if ~isfield(rar_params, 'srate') || ...
        (isfield(rar_params, 'srate') && rar_params.srate ~= userData.reference.srate.value)
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
    if isfield(rar_params, 'detrendChannels') && rar_params.detrendChannels == -1
        rar_params = rmfield(rar_params, 'detrendChannels');
    end
    
    % Lists that are -1 are not set by the gui
    if isfield(rar_params, 'lineNoiseChannels') && rar_params.lineNoiseChannels == -1
        rar_params = rmfield(rar_params, 'lineNoiseChannels');
    end
    
    % Lists that are -1 are not set by the gui
    if isfield(rar_params, 'referenceChannels') && rar_params.referenceChannels == -1
        rar_params = rmfield(rar_params, 'referenceChannels');
    end
    
    % Lists that are -1 are not set by the gui
    if isfield(rar_params, 'evaluationChannels') && rar_params.evaluationChannels == -1
        rar_params = rmfield(rar_params, 'evaluationChannels');
    end
    
    % Lists that are -1 are not set by the gui
    if isfield(rar_params, 'rereferencedChannels') && rar_params.rereferencedChannels == -1
        rar_params = rmfield(rar_params, 'rereferencedChannels');
    end
    
    if isfield(rar_params, 'detrendCutoff') && isempty(rar_params.detrendCutoff)
        rar_params = rmfield(rar_params, 'detrendCutoff');
    end
    
    if isfield(rar_params, 'localCutoff') && isempty(rar_params.localCutoff)
        rar_params = rmfield(rar_params, 'localCutoff');
    end
    
    if isfield(rar_params, 'globalTrendChannels') && isempty(rar_params.globalTrendChannels)
        rar_params = rmfield(rar_params, 'globalTrendChannels');
    end
    
    if isfield(rar_params, 'Fs') && isempty(rar_params.Fs)
        rar_params = rmfield(rar_params, 'Fs');
    end
    
    if isfield(rar_params, 'lineFrequencies') && isempty(rar_params.lineFrequencies)
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

handles.params.prep_params = rar_params;
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
