function varargout = qualityrating_gui(varargin)
% QUALITYRATING_GUI MATLAB code for qualityrating_gui.fig
%      QUALITYRATING_GUI, by itself, creates a new QUALITYRATING_GUI or raises the existing
%      singleton*.
%
%      H = QUALITYRATING_GUI returns the handle to a new QUALITYRATING_GUI or the handle to
%      the existing singleton*.
%
%      QUALITYRATING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUALITYRATING_GUI.M with the given input arguments.
%
%      QUALITYRATING_GUI('Property','Value',...) creates a new QUALITYRATING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before qualityrating_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to qualityrating_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help qualityrating_gui

% Last Modified by GUIDE v2.5 08-Jun-2018 14:15:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @qualityrating_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @qualityrating_gui_OutputFcn, ...
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


% --- Executes just before qualityrating_gui is made visible.
function qualityrating_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to qualityrating_gui (see VARARGIN)

if( nargin - 3 ~= 1 )
    error('wrong number of arguments. Project must be given as argument.')
end

project = varargin{1};
assert(isa(project, 'Project'));
handles.project = project;
handles.CGV = ConstantGlobalValues;
% Set the title to the current version
handles.title_name = ['Automagic v.', handles.CGV.version, ' Quality Rating'];
set(handles.qualityrating, 'Name', handles.title_name);

cutoffs = handles.project.qualityCutoffs;
render_project(handles, cutoffs);
% Choose default command line output for qualityrating_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes qualityrating_gui wait for user response (see UIRESUME)
% uiwait(handles.qualityrating);


% --- Outputs from this function are returned to the command line.
function varargout = qualityrating_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles = render_project(handles, cutoffs)

if any(strfind(cutoffs.Qmeasure,'OHA'))
    set(handles.oharadio, 'Value', 1);
    set(handles.ohaslider1, 'Value', cutoffs.overallGoodCutoff);
    set(handles.ohaslider2, 'Value', cutoffs.overallBadCutoff);
else
    set(handles.oharadio, 'Value', 0);
    set(handles.ohaslider1, 'Value', 0);
    set(handles.ohaslider2, 'Value', 0);
end
set(handles.ohaslider1text, 'String', get(handles.ohaslider1, 'Value'));
set(handles.ohaslider2text, 'String', get(handles.ohaslider2, 'Value'));

if any(strfind(cutoffs.Qmeasure,'THV'))
    set(handles.thvradio, 'Value', 1);
    set(handles.thvslider1, 'Value', cutoffs.timeGoodCutoff);
    set(handles.thvslider2, 'Value', cutoffs.timeBadCutoff);
else
    set(handles.thvradio, 'Value', 0);
    set(handles.thvslider1, 'Value', 0);
    set(handles.thvslider2, 'Value', 0);
end
set(handles.thvslider1text, 'String', get(handles.thvslider1, 'Value'));
set(handles.thvslider2text, 'String', get(handles.thvslider2, 'Value'));

if any(strfind(cutoffs.Qmeasure,'CHV'))
    set(handles.chvradio, 'Value', 1);
    set(handles.chvslider1, 'Value', cutoffs.channelGoodCutoff);
    set(handles.chvslider2, 'Value', cutoffs.channelBadCutoff);
else
    set(handles.chvradio, 'Value', 0);
    set(handles.chvslider1, 'Value', 0);
    set(handles.chvslider2, 'Value', 0);
end
set(handles.chvslider1text, 'String', get(handles.chvslider1, 'Value'));
set(handles.chvslider2text, 'String', get(handles.chvslider2, 'Value'));

if any(strfind(cutoffs.Qmeasure,'RBC'))
    set(handles.rbcradio, 'Value', 1);
    set(handles.rbcslider1, 'Value', cutoffs.BadChannelGoodCutoff);
    set(handles.rbcslider2, 'Value', cutoffs.BadChannelBadCutoff);
else
    set(handles.rbcradio, 'Value', 0);
    set(handles.rbcslider1, 'Value', 0);
    set(handles.rbcslider2, 'Value', 0);
end
set(handles.rbcslider1text, 'String', get(handles.rbcslider1, 'Value'));
set(handles.rbcslider2text, 'String', get(handles.rbcslider2, 'Value'));
renderAxes(handles, cutoffs);

function cutoffs = get_gui_values(handles)

cutoffs = struct('Qmeasure', '');                                
if get(handles.oharadio, 'Value')
    cutoffs.Qmeasure = [cutoffs.Qmeasure 'OHA'];
    cutoffs.overallGoodCutoff = get(handles.ohaslider1, 'Value');
    cutoffs.overallBadCutoff = get(handles.ohaslider2, 'Value');
end

if get(handles.thvradio, 'Value')
    cutoffs.Qmeasure = [cutoffs.Qmeasure 'THV'];
    cutoffs.timeGoodCutoff = get(handles.thvslider1, 'Value');
    cutoffs.timeBadCutoff = get(handles.thvslider2, 'Value');
end

if get(handles.chvradio, 'Value')
    cutoffs.Qmeasure = [cutoffs.Qmeasure 'CHV'];
    cutoffs.channelGoodCutoff = get(handles.chvslider1, 'Value');
    cutoffs.channelBadCutoff = get(handles.chvslider2, 'Value');
end

if get(handles.rbcradio, 'Value')
    cutoffs.Qmeasure = [cutoffs.Qmeasure 'RBC'];
    cutoffs.BadChannelGoodCutoff = get(handles.rbcslider1, 'Value');
    cutoffs.BadChannelBadCutoff = get(handles.rbcslider2, 'Value');
end


function renderAxes(handles, cutoffs)
blocks = handles.project.block_map.values;
res = cellfun( @(block) rateQuality(block.qualityScore, cutoffs), blocks, 'uniform', 0);
cutoffAxes = handles.cutoffaxes;
rateingHist = histogram(categorical(res, {'Good' 'OK' 'Bad' 'Interpolate'},'Ordinal',true), 'Parent', cutoffAxes);
set(cutoffAxes, 'YTick', 0:max(rateingHist.Values))
title('Overview of dataset rating based on selected cutoffshow')

function handles = apply_to_all(handles, cutoffs)
% Change the cutoff the project
% Change rating of everyfile
project = handles.project;
blocks = project.block_map.values;

set(handles.qualityrating, 'pointer', 'watch')
drawnow;
for i = 1:length(blocks)
    block = blocks{i};
    new_rate = rateQuality(block.qualityScore, cutoffs);
    if ~strcmp(new_rate, handles.CGV.ratings.Interpolate) 
        block.setRatingInfoAndUpdate(new_rate, [], block.final_badchans, ...
            block.is_interpolated);
        block.saveRatingsToFile();
        project.update_rating_lists(block);
    end
end
handles.project.qualityCutoffs = cutoffs;
set(handles.qualityrating, 'pointer', 'arrow')

% --- Executes on button press in commitbutton.
function commitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to commitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cutoffs = get_gui_values(handles);
apply_to_all(handles, cutoffs);
close(handles.title_name);

% --- Executes on button press in resetbutton.
function resetbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cutoffs = handles.CGV.rateQuality_params;
handles = render_project(handles, cutoffs);
renderAxes(handles, cutoffs);

% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.title_name);

% --- Executes on slider movement.
function ohaslider1_Callback(hObject, eventdata, handles)
% hObject    handle to ohaslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodValue = get(hObject,'Value');
badValue = get(handles.ohaslider2, 'Value');
if (goodValue > badValue)
    set(handles.ohaslider2, 'Value', goodValue)
end
set(handles.ohaslider1text, 'String', goodValue);
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function ohaslider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ohaslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in chvradio.
function chvradio_Callback(hObject, eventdata, handles)
% hObject    handle to chvradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.chvslider1, 'enable', 'on')
    set(handles.chvslider2, 'enable', 'on')
else
    set(handles.chvslider1, 'enable', 'off')
    set(handles.chvslider2, 'enable', 'off')
end
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hint: get(hObject,'Value') returns toggle state of chvradio


% --- Executes on button press in thvradio.
function thvradio_Callback(hObject, eventdata, handles)
% hObject    handle to thvradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.thvslider1, 'enable', 'on')
    set(handles.thvslider2, 'enable', 'on')
else
    set(handles.thvslider1, 'enable', 'off')
     set(handles.thvslider2, 'enable', 'off')
end
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hint: get(hObject,'Value') returns toggle state of thvradio


% --- Executes on button press in oharadio.
function oharadio_Callback(hObject, eventdata, handles)
% hObject    handle to oharadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.ohaslider1, 'enable', 'on')
    set(handles.ohaslider2, 'enable', 'on')
else
    set(handles.ohaslider1, 'enable', 'off')
    set(handles.ohaslider2, 'enable', 'off')
end
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hint: get(hObject,'Value') returns toggle state of oharadio


% --- Executes on button press in rbcradio.
function rbcradio_Callback(hObject, eventdata, handles)
% hObject    handle to rbcradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.rbcslider1, 'enable', 'on')
    set(handles.rbcslider2, 'enable', 'on')
else
    set(handles.rbcslider1, 'enable', 'off')
    set(handles.rbcslider2, 'enable', 'off')
end
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hint: get(hObject,'Value') returns toggle state of rbcradio


% --- Executes on slider movement.
function rbcslider1_Callback(hObject, eventdata, handles)
% hObject    handle to rbcslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodValue = get(hObject,'Value');
badValue = get(handles.rbcslider2, 'Value');
if (goodValue > badValue)
    set(handles.rbcslider2, 'Value', goodValue)
end
set(handles.rbcslider1text, 'String', goodValue);
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function rbcslider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function rbcslider2_Callback(hObject, eventdata, handles)
% hObject    handle to rbcslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
badValue = get(hObject,'Value');
goodValue = get(handles.rbcslider1, 'Value');
if (goodValue > badValue)
    set(handles.rbcslider1, 'Value', badValue)
end
set(handles.rbcslider2text, 'String', badValue);
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function rbcslider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function chvslider1_Callback(hObject, eventdata, handles)
% hObject    handle to chvslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodValue = get(hObject,'Value');
badValue = get(handles.chvslider2, 'Value');
if (goodValue > badValue)
    set(handles.chvslider2, 'Value', goodValue)
end
set(handles.chvslider1text, 'String', goodValue);
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function chvslider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chvslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function chvslider2_Callback(hObject, eventdata, handles)
% hObject    handle to chvslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
badValue = get(hObject,'Value');
goodValue = get(handles.chvslider1, 'Value');
if (goodValue > badValue)
    set(handles.chvslider1, 'Value', badValue)
end
set(handles.chvslider2text, 'String', badValue);
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function chvslider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chvslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function thvslider1_Callback(hObject, eventdata, handles)
% hObject    handle to thvslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodValue = get(hObject,'Value');
badValue = get(handles.thvslider2, 'Value');
if (goodValue > badValue)
    set(handles.thvslider2, 'Value', goodValue)
end
set(handles.thvslider1text, 'String', goodValue);
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function thvslider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thvslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function thvslider2_Callback(hObject, eventdata, handles)
% hObject    handle to thvslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
badValue = get(hObject,'Value');
goodValue = get(handles.thvslider1, 'Value');
if (goodValue > badValue)
    set(handles.thvslider1, 'Value', badValue)
end
set(handles.thvslider2text, 'String', badValue);
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function thvslider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thvslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function ohaslider2_Callback(hObject, eventdata, handles)
% hObject    handle to ohaslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
badValue = get(hObject,'Value');
goodValue = get(handles.ohaslider1, 'Value');
if (goodValue > badValue)
    set(handles.ohaslider1, 'Value', badValue)
end
set(handles.ohaslider2text, 'String', badValue);
cutoffs = get_gui_values(handles);
renderAxes(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function ohaslider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ohaslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when user attempts to close qualityrating.
function qualityrating_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to qualityrating (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
