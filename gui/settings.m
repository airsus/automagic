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

% Last Modified by GUIDE v2.5 25-Jan-2018 10:52:52

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
assert(isa(CGV, 'ConstantGlobalValues'));
handles.params = params;
handles.CGV = CGV;

% Either pca or ica, not both together.
assert( ( ~ isempty(handles.params.pca_params.lambda) && ...
    handles.params.pca_params.lambda == -1) || handles.params.ica_params.bool == 0);

if( isempty( params.filter_params.high_order) )
    set(handles.highpassorderedit, 'String', CGV.DEFAULT_keyword);
else
    set(handles.highpassorderedit, 'String', params.filter_params.high_order);
end

if( isempty( params.filter_params.low_order) )
    set(handles.lowpassorderedit, 'String', CGV.DEFAULT_keyword);
else
    set(handles.lowpassorderedit, 'String', params.filter_params.low_order);
end

if( ~ strcmp(params.channel_rejection_params.channel_criterion, 'off'))
    set(handles.channelcriterioncheckbox, 'Value', 1);
    set(handles.channelcriterionedit, 'String', params.channel_rejection_params.channel_criterion);
else
    set(handles.channelcriterioncheckbox, 'Value', 0);
    set(handles.channelcriterionedit, 'String', CGV.default_params.channel_rejection_params.channel_criterion);
end

if( ~ strcmp(params.channel_rejection_params.line_noise_criterion, 'off'))
    set(handles.linenoisecheckbox, 'Value', 1);
    set(handles.linenoiseedit, 'String', params.channel_rejection_params.line_noise_criterion);
else
    set(handles.linenoisecheckbox, 'Value', 0);
    set(handles.linenoiseedit, 'String', CGV.default_params.channel_rejection_params.line_noise_criterion);
end

if( ~ strcmp(params.channel_rejection_params.burst_criterion, 'off'))
    set(handles.burstcheckbox, 'Value', 1);
    set(handles.burstedit, 'String', params.channel_rejection_params.burst_criterion);
else
    set(handles.burstcheckbox, 'Value', 0);
    set(handles.burstedit, 'String', CGV.default_params.channel_rejection_params.burst_criterion);
end

if( ~ strcmp(params.channel_rejection_params.window_criterion, 'off'))
    set(handles.windowcheckbox, 'Value', 1);
    set(handles.windowedit, 'String', params.channel_rejection_params.window_criterion);
else
    set(handles.windowcheckbox, 'Value', 0);
    set(handles.windowedit, 'String', CGV.default_params.channel_rejection_params.window_criterion);
end

if( params.channel_rejection_params.rar)
    set(handles.rarcheckbox, 'Value', 1);
else
    set(handles.rarcheckbox, 'Value', 0);
end

if( isempty(params.pca_params.lambda) || params.pca_params.lambda ~= -1)
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
    set(handles.lambdaedit, 'String', CGV.DEFAULT_keyword);
    set(handles.toledit, 'String', CGV.default_params.pca_params.tol);
    set(handles.maxIteredit, 'String', CGV.default_params.pca_params.maxIter);
end

set(handles.icacheckbox, 'Value', params.ica_params.bool);


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

% --- Executes on button press in okpushbutton.
function okpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = get_inputs(handles);
% Update handles structure
guidata(hObject, handles);

close('settings');

function handles = get_inputs(handles)

h = findobj(allchild(0), 'flat', 'Tag', 'main_gui');
main_gui_handle = guidata(h);
CGV = handles.CGV;

ica_bool = get(handles.icacheckbox, 'Value');

high_order = [];
if( get(main_gui_handle.highpasscheckbox, 'Value') )
    high_order = str2double(get(handles.highpassorderedit, 'String'));
end
if(isnan(high_order) )
    high_order = CGV.default_params.filter_params.high_order;
end


low_order = [];
if( get(main_gui_handle.lowpasscheckbox, 'Value') )
    low_order = str2double(get(handles.lowpassorderedit, 'String'));
end
if(isnan(low_order))
    low_order = CGV.default_params.filter_params.high_order;
end

if( get(handles.linenoisecheckbox, 'Value') )
    linenoise_val = str2double(get(handles.linenoiseedit, 'String'));
    if( isempty(linenoise_val) || isnan(linenoise_val))
        linenoise_val = CGV.default_params.channel_rejection_params.line_noise_criterion; 
    end
else
    linenoise_val = 'off';
end


if( get(handles.channelcriterioncheckbox, 'Value') )
    channel_criterion_val = str2double(get(handles.channelcriterionedit, 'String'));
    if( isempty(channel_criterion_val) || isnan(channel_criterion_val))
        channel_criterion_val = CGV.default_params.channel_rejection_params.channel_criterion; 
    end
else
    channel_criterion_val = 'off';
end



if( get(handles.burstcheckbox, 'Value') )
    burst_val = str2double(get(handles.burstedit, 'String'));
    if( isempty(burst_val) || isnan(burst_val))
        burst_val = CGV.default_params.channel_rejection_params.burst_criterion; 
    end
else
    burst_val = 'off';
end


if( get(handles.windowcheckbox, 'Value') )
    window_val = str2double(get(handles.windowedit, 'String'));
    if( isempty(window_val) || isnan(window_val))
        window_val = CGV.default_params.channel_rejection_params.window_criterion; 
    end
else
    window_val = 'off';
end


rar_check = get(handles.rarcheckbox, 'Value');

if( get(handles.pcacheckbox, 'Value') )
    lambda = str2double(get(handles.lambdaedit, 'String'));
    tol = str2double(get(handles.toledit, 'String'));
    maxIter = str2double(get(handles.maxIteredit, 'String'));
    if(isnan(lambda) )
        lambda = CGV.default_params.pca_params.lambda;
    end
else
    lambda = -1;
    tol = -1;
    maxIter = -1;
end

if(isempty(tol) || isnan(tol))
    tol = CGV.default_params.pca_params.tol;
end

if( isempty(maxIter) || isnan(maxIter)) 
    maxIter = CGV.default_params.pca_params.maxIter;
end


idx = get(handles.interpolationpopupmenu, 'Value');
methods = get(handles.interpolationpopupmenu, 'String');
method = methods{idx};

handles.params.filter_params.high_order = high_order;
handles.params.filter_params.low_order = low_order;
handles.params.channel_rejection_params.line_noise_criterion = linenoise_val;
handles.params.channel_rejection_params.channel_criterion = channel_criterion_val;
handles.params.channel_rejection_params.burst_criterion = burst_val;
handles.params.channel_rejection_params.window_criterion = window_val;
handles.params.channel_rejection_params.highpass = CGV.default_params.channel_rejection_params.highpass;
handles.params.channel_rejection_params.rar = rar_check;
handles.params.pca_params.lambda = lambda;
handles.params.pca_params.tol = tol;
handles.params.pca_params.maxIter = maxIter;
handles.params.ica_params.bool = ica_bool;
handles.params.interpolation_params.method = method;

% --- Executes on button press in defaultpushbutton.
function defaultpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to defaultpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CGV = handles.CGV;
params = handles.params;

set(handles.highpassorderedit, 'String', ...
    CGV.DEFAULT_keyword);
set(handles.lowpassorderedit, 'String', ...
    CGV.default_params.filter_params.low_order);

set(handles.icacheckbox, 'Value', CGV.default_params.ica_params.bool);

if( ~strcmp(CGV.default_params.channel_rejection_params.line_noise_criterion, 'off'))
    set(handles.linenoisecheckbox, 'Value', 1);
    set(handles.linenoiseedit, 'String', ...
        CGV.default_params.channel_rejection_params.line_noise_criterion);
else
    set(handles.linenoisecheckbox, 'Value', 0);
    set(handles.linenoiseedit, 'String', '');
end

if( ~strcmp(CGV.default_params.channel_rejection_params.channel_criterion, 'off'))
    set(handles.channelcriterioncheckbox, 'Value', 1);
    set(handles.channelcriterionedit, 'String', ...
        CGV.default_params.channel_rejection_params.channel_criterion);
else
    set(handles.channelcriterioncheckbox, 'Value', 0);
    set(handles.channelcriterionedit, 'String', '');
end
if( ~strcmp(CGV.default_params.channel_rejection_params.burst_criterion, 'off'))
    set(handles.burstcheckbox, 'Value', 1);
    set(handles.burstedit, 'String', ...
        CGV.default_params.channel_rejection_params.burst_criterion);
else
    set(handles.burstcheckbox, 'Value', 0);
    set(handles.burstedit, 'String', '');
end
if( ~strcmp(CGV.default_params.channel_rejection_params.window_criterion, 'off'))
    set(handles.windowcheckbox, 'Value', 1);
    set(handles.windowedit, 'String', ...
        CGV.default_params.channel_rejection_params.window_criterion);
else
    set(handles.windowcheckbox, 'Value', 0);
    set(handles.windowedit, 'String', '');
end

set(handles.rarcheckbox, 'Value',CGV.default_params.channel_rejection_params.rar);

if( isempty(CGV.default_params.pca_params.lambda) || CGV.default_params.pca_params.lambda ~= -1)
    set(handles.pcacheckbox, 'Value', 1);
    set(handles.lambdaedit, 'String', ...
        CGV.DEFAULT_keyword);
    set(handles.toledit, 'String', ...
        CGV.default_params.pca_params.tol);
    set(handles.maxIteredit, 'String', ...
        CGV.default_params.pca_params.maxIter);
else
    set(handles.pcacheckbox, 'Value', 0);
    set(handles.lambdaedit, 'String', '');
    set(handles.toledit, 'String', '');
    set(handles.maxIteredit, 'String', '');
end

IndexC = strfind(handles.interpolationpopupmenu.String, ...
    CGV.default_params.interpolation_params.method);
index = find(not(cellfun('isempty', IndexC)));
set(handles.interpolationpopupmenu, 'Value', index);

handles = switch_components(handles);

% Update handles structure
guidata(hObject, handles);

function handles = switch_components(handles)

h = findobj(allchild(0), 'flat', 'Tag', 'main_gui');
main_gui_handle = guidata(h);
CGV = handles.CGV;

if( get(main_gui_handle.highpasscheckbox, 'Value') )
    set(handles.highpassorderedit, 'enable', 'on');
else
    set(handles.highpassorderedit, 'enable', 'off');
    set(handles.highpassorderedit, 'String', ...
        CGV.default_params.filter_params.high_order);
end

if( get(main_gui_handle.lowpasscheckbox, 'Value') )
    set(handles.lowpassorderedit, 'enable', 'on');
else
    set(handles.lowpassorderedit, 'enable', 'off');
    set(handles.lowpassorderedit, 'String', ...
        CGV.default_params.filter_params.low_order);
end

if( get(handles.linenoisecheckbox, 'Value') )
    set(handles.linenoiseedit, 'enable', 'on');
else
    set(handles.linenoiseedit, 'enable', 'off');
    set(handles.linenoiseedit, 'String', ...
        num2str(CGV.default_params.channel_rejection_params.line_noise_criterion));
end

if( get(handles.channelcriterioncheckbox, 'Value') )
    set(handles.channelcriterionedit, 'enable', 'on');
else
    set(handles.channelcriterionedit, 'enable', 'off');
    set(handles.channelcriterionedit, 'String', ...
        num2str(CGV.default_params.channel_rejection_params.channel_criterion));
end

if( get(handles.burstcheckbox, 'Value') )
    set(handles.burstedit, 'enable', 'on');
else
    set(handles.burstedit, 'enable', 'off');
    set(handles.burstedit, 'String', ...
        num2str(CGV.default_params.channel_rejection_params.burst_criterion));
end

if( get(handles.windowcheckbox, 'Value') )
    set(handles.windowedit, 'enable', 'on');
else
    set(handles.windowedit, 'enable', 'off');
    set(handles.windowedit, 'String', ...
        num2str(CGV.default_params.channel_rejection_params.window_criterion));
end

if( get(handles.pcacheckbox, 'Value') )
    set(handles.lambdaedit, 'enable', 'on');
    set(handles.toledit, 'enable', 'on');
    set(handles.maxIteredit, 'enable', 'on');
else
    set(handles.lambdaedit, 'enable', 'off');
    set(handles.toledit, 'enable', 'off');
    set(handles.maxIteredit, 'enable', 'off');
    set(handles.lambdaedit, 'String', ...
        num2str(CGV.DEFAULT_keyword));
    set(handles.toledit, 'String', ...
        num2str(CGV.default_params.pca_params.tol));
    set(handles.maxIteredit, 'String', ...
        num2str(CGV.default_params.pca_params.maxIter));
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

% Hint: get(hObject,'Value') returns toggle state of rarcheckbox


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
