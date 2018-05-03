function varargout = rating_gui(varargin)
% RATING_GUI MATLAB code for rating_gui.fig
%      RATING_GUI is called by the main_gui. A user must not call this gui 
%      directly. Howerver, for test reasons, one can call RATING_GUI if an 
%      instance of the class Project is given as argument.
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

% Last Modified by GUIDE v2.5 03-May-2018 16:16:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rating_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rating_gui_OutputFcn, ...
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


% --- Executes just before rating_gui is made visible.
function rating_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rating_gui (see VARARGIN)

% Change the cursor to a watch while updating...
set(handles.rating_gui, 'pointer', 'watch')
drawnow;

if( nargin - 3 ~= 1 )
    error('wrong number of arguments. Project must be given as argument.')
end

project = varargin{1};
assert(isa(project, 'Project') || isa(project, 'EEGLabProject'));
handles.project = project;
handles.CGV = ConstantGlobalValues;

set(handles.rating_gui, 'units', 'normalized', 'position', [0.05 0.3 0.8 0.8])

% Set the title to the current version
set(handles.rating_gui, 'Name', ['Automagic v.', handles.CGV.version, ...
                                 ' Manual Rating']);

% set checkboxes to be all selected on startup
set(handles.interpolatecheckbox,'Value', 1)
set(handles.badcheckbox,'Value', 1)
set(handles.okcheckbox,'Value', 1)
set(handles.goodcheckbox,'Value', 1)
set(handles.notratedcheckbox,'Value', 1)

% Allows to select channels for interpolation if it's set to true.
handles.selection_mode = false;

handles = load_project(handles);

% Set keyboard shortcuts for rating
handles = set_shortcuts(handles);

% Choose default command line output for rating_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Change back the cursor to an arrow
set(handles.rating_gui, 'pointer', 'arrow')
% UIWAIT makes rating_gui wait for user response (see UIRESUME)
% uiwait(handles.rating_gui);


% --- Outputs from this function are returned to the command line.
function varargout = rating_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Set the gui components according to this project's properties
function handles = load_project(handles)
% handles       structure with handles of the gui

set_color_scale(handles);
handles = set_gui_subjects_list(handles);
set_gui_rating(handles);
handles = update_next_and_previous_button(handles);

% Load and show the first image
[handles, data] = load_current(handles, true);
handles = show_current(data, false, handles);

clear data;

% --- Set components related to color scale
function set_color_scale(handles)
% handles       structure with handles of the gui

scale = handles.project.colorScale;
set(handles.scaletext, 'String', ...
    ['[ -', num2str(scale), ' ' , num2str(scale),']']);
set(handles.colorscale, 'Value', scale);

% --- Set the gui menu to show all avaiable files that are not filtered by 
% the gui
function handles = set_gui_subjects_list(handles)
% handles  structure with handles of the gui

project = handles.project;
processed_list = project.processed_list;
list = {};
for i = 1:length(processed_list)
    unique_name = processed_list{i};
    if( ~ is_filtered(handles, unique_name) )
        list{end + 1} = unique_name;
    end
end

if( isempty(list))
    list{end + 1} = '';
end

set(handles.subjectsmenu,'String',list);
handles = update_gui_selected_subject(handles);

% --- Set the rating of the gui based on the current project
function handles = set_gui_rating(handles)
% handles  structure with handles of the gui

project = handles.project;
if( project.current == - 1 || is_filtered(handles, project.current))
    set(handles.rategroup,'selectedobject',[]);
    return
end
block = get_current_block(handles);

set(handles.turnonbutton,'Enable', 'off')
set(handles.turnoffbutton,'Enable', 'off')
switch block.rate
    case handles.CGV.ratings.Good
       set(handles.rategroup,'selectedobject',handles.goodrate)
    case handles.CGV.ratings.OK
        set(handles.rategroup,'selectedobject',handles.okrate)
    case handles.CGV.ratings.Bad
        set(handles.rategroup,'selectedobject',handles.badrate)
    case handles.CGV.ratings.Interpolate
        set(handles.rategroup,'selectedobject',handles.interpolaterate)
        set(handles.turnonbutton,'Enable', 'on')
        set(handles.turnoffbutton,'Enable', 'on')
    case handles.CGV.ratings.NotRated
        set(handles.rategroup,'selectedobject',handles.notrate)
end


% --- Load the current "reduced" file to the work space (The file is 
% downsampled to speed up the loading)
function [handles, data] = load_current(handles, get_reduced) %#ok<STOUT>
% handles   structure with handles of the gui

project = handles.project;
if ( project.current == - 1 || is_filtered(handles, project.current))
    data = [];
else
    block = get_current_block(handles);
    if(isa(block, 'Block'))
        block.update_addresses(project.data_folder, project.result_folder);
        if(get_reduced)
            load(block.reduced_address);
            data = reduced;
        else
            load(block.result_address);
            data.data = EEG.data;
            data.srate = EEG.srate;
            data.chanlocs = EEG.chanlocs;
            data.event = EEG.event;
        end
    elseif(isa(block, 'EEGLabBlock'))
        data = block.get_reduced();
    end
    handles.project.maxX = max(project.maxX, size(data.data, 2));% for the plot
end

% --- Make the plot of the current file
function handles = show_current(reduced, average_reference, handles)
% handles  structure with handles of the gui
% reduced  data file to be plotted
% average_reference bool specifying if average referencing should be
% performed or not

if isfield(reduced, 'data')
    data = reduced.data;
    project = handles.project;
    colorScale = project.colorScale;
    unique_name = project.processed_list{project.current};
else
    data = [];
    unique_name = 'no image';
    colorScale = handles.CGV.COLOR_SCALE;
end


axe = handles.axes;
cla(axe);

% Averange reference data before plotting
if( average_reference && ~isempty(data))
    data_size = size(data);
    data = data - repmat(nanmean(data, 1), data_size(1), 1);
end

im = imagesc(data, 'tag', 'im');
set(im, 'ButtonDownFcn', {@on_selection,handles}, 'AlphaData',~isnan(data))
set(gcf, 'Color', [1,1,1])
colormap jet
caxis([-colorScale colorScale])
title(unique_name, 'Interpreter','none')

draw_lines(handles);
mark_interpolated_chans(handles)

% --- Show the current ptoject as the selected one in the menu
function handles = update_gui_selected_subject(handles)
% handles  structure with handles of the gui

project = handles.project;
if( project.current == -1)
    return;
end
unique_name = project.processed_list{project.current};
IndexC = strfind(handles.subjectsmenu.String, unique_name);
Index = find(not(cellfun('isempty', IndexC)));
if(isempty(Index))
    Index = 1;
end
set(handles.subjectsmenu,'Value',Index);

% Returns the block pointed by the current index. If current = -1, a mock
% block is returned.
function block = get_current_block(handles)
project = handles.project;

if( project.current == -1)
    subject = Subject('','');
    block = Block(subject, '', '', 0, []);
    block.index = -1;
    return;
end
unique_name = project.processed_list{project.current};
block = project.block_map(unique_name);



% --- Get the index of the next available file.
% There are five different lists corresponding to different ratings. The
% first possible block from each list is first chosen, and finally the one
% which precedes all others in the main list is chosen. For more info 
% on why these lists please read Project docs.
function next = get_next_index(handles)
% handles  structure with handles of the gui

block = get_current_block(handles);
unique_name = block.unique_name;
current_index = block.index;
project = handles.project;

good_bool = get(handles.goodcheckbox,'Value');
ok_bool = get(handles.okcheckbox,'Value');
bad_bool = get(handles.badcheckbox,'Value');
interpolate_bool = get(handles.interpolatecheckbox,'Value');
notrated_bool = get(handles.notratedcheckbox,'Value');

% If no rating is filtered, simply return the next one in the list.
if( good_bool && ok_bool && bad_bool && interpolate_bool && notrated_bool)
    next = min(project.current + 1, length(project.processed_list));
    if( next == 0)
        next = next + 1;
    end
else
    next_good = [];
    next_ok = [];
    next_bad = [];
    next_interpolate = [];
    next_notrated = [];
    if(good_bool)
        possible_goods = find(project.good_list > current_index, 1);
        if( ~ isempty(possible_goods))
            next_good = project.good_list(possible_goods(1));
        end
    end
    if(ok_bool)
       possible_oks = find(project.ok_list > current_index, 1);
        if( ~ isempty(possible_oks))
            next_ok = project.ok_list(possible_oks(1));
        end
    end
    if(bad_bool)
       possible_bads = find(project.bad_list > current_index, 1);
        if( ~ isempty(possible_bads))
            next_bad = project.bad_list(possible_bads(1));
        end
    end
    if(interpolate_bool)
       possible_interpolates = find(project.interpolate_list > current_index, 1);
        if( ~ isempty(possible_interpolates))
            next_interpolate = project.interpolate_list(possible_interpolates(1));
        end
    end
    if(notrated_bool)
       possible_notrateds = find(project.not_rated_list > current_index, 1);
        if( ~ isempty(possible_notrateds))
            next_notrated = project.not_rated_list(possible_notrateds(1));
        end
    end
    next = min([next_good next_ok next_bad next_interpolate next_notrated]);
    if( isempty(next))
        if( ~ is_filtered(handles, unique_name ))
            next = project.current;
        else
            next = -1;
        end
    end
end

% --- Get the index of the previous file if any.
% There are five different lists corresponding to different ratings. The
% first possible block from each list is first chosen, and finally the one
% which follows all others in the main list is chosen. For more info 
% please read the docs.
function previous = get_previous_index(handles)
% handles  structure with handles of the gui

% Get the current project and file
block = get_current_block(handles);
unique_name = block.unique_name;
current_index = block.index;
project = handles.project;

% Check which ratings are filtered and which are not
good_bool = get(handles.goodcheckbox,'Value');
ok_bool = get(handles.okcheckbox,'Value');
bad_bool = get(handles.badcheckbox,'Value');
interpolate_bool = get(handles.interpolatecheckbox,'Value');
notrated_bool = get(handles.notratedcheckbox,'Value');

% If nothing is filtered the previous one is simply the one before the
% current one in the list
if( good_bool && ok_bool && bad_bool && interpolate_bool && notrated_bool)
    previous = max(project.current - 1, 1);
    return;
end

% Now for each rating, find the possible choices, and then choose the
% closest one
previous_good = [];
previous_ok = [];
previous_bad = [];
previous_interpolate = [];
previous_notrated = [];
if(good_bool)
    possible_goods = find(project.good_list < current_index, 1, 'last');
    if( ~ isempty(possible_goods))
        previous_good = project.good_list(possible_goods(end));
    end
end
if(ok_bool)
   possible_oks = find(project.ok_list < current_index, 1, 'last');
    if( ~ isempty(possible_oks))
        previous_ok = project.ok_list(possible_oks(end));
    end
end
if(bad_bool)
   possible_bads = find(project.bad_list < current_index, 1, 'last');
    if( ~ isempty(possible_bads))
        previous_bad = project.bad_list(possible_bads(end));
    end
end
if(interpolate_bool)
   possible_interpolates = find(project.interpolate_list < current_index, 1, 'last');
    if( ~ isempty(possible_interpolates))
        previous_interpolate = project.interpolate_list(possible_interpolates(end));
    end
end
if(notrated_bool)
   possible_notrateds = find(project.not_rated_list < current_index, 1, 'last');
    if( ~ isempty(possible_notrateds))
        previous_notrated = project.not_rated_list(possible_notrateds(end));
    end
end
previous = max([previous_good previous_ok previous_bad previous_interpolate previous_notrated]);
if( isempty(previous))
    if( ~ is_filtered(handles, unique_name ))
        previous = project.current;
    else
        previous = -1;
    end
end

% --- Check whether this file is filtered by the user
function bool = is_filtered(handles, file)
% handles  structure with handles of the gui
% subj     could be a double indicating the index of the file or a char
%          indicating the name of it
project = handles.project;
if( project.current == -1)
    bool = false;
    return;
end

project = handles.project;
switch class(file)
    case 'double'
        unique_name = project.processed_list{file};
    case 'char'
        unique_name = file;
end

block = project.block_map(unique_name);
rate = block.rate;
switch rate
    case handles.CGV.ratings.Good
        bool = ~ get(handles.goodcheckbox,'Value');
    case handles.CGV.ratings.OK
        bool = ~ get(handles.okcheckbox,'Value');
    case handles.CGV.ratings.Bad
        bool = ~ get(handles.badcheckbox,'Value');
    case handles.CGV.ratings.Interpolate
        bool = ~ get(handles.interpolatecheckbox,'Value');
    case handles.CGV.ratings.NotRated
        bool = ~ get(handles.notratedcheckbox,'Value');
    otherwise
        bool = false;
end

% --- Switch the gui to enable or disable
function switch_gui(mode, handles)
% handles  structure with handles of the gui
% mode     string that can be 'off' or 'on'

set(handles.nextbutton,'Enable', mode)
set(handles.previousbutton,'Enable', mode)
set(handles.interpolaterate,'Enable', mode)
set(handles.okrate,'Enable', mode)
set(handles.badrate,'Enable', mode)
set(handles.goodrate,'Enable', mode)
set(handles.notrate,'Enable', mode)
set(handles.goodcheckbox,'Enable', mode)
set(handles.okcheckbox,'Enable', mode)
set(handles.badcheckbox,'Enable', mode)
set(handles.interpolatecheckbox,'Enable', mode)
set(handles.notratedcheckbox,'Enable', mode)

% --- If there is no previous, desactivate the previous button, if there 
% is no next, desactivate the next button. And vice versa in order to 
% reset the action.
function handles = update_next_and_previous_button(handles)
% handles  structure with handles of the gui

if( handles.project.current == -1)
    set(handles.nextbutton,'Enable', 'off');
    set(handles.previousbutton,'Enable', 'off');
    return;
end
project = handles.project;
if( project.current == get_next_index(handles))
    set(handles.nextbutton,'Enable', 'off');
end

if( project.current ~= get_previous_index(handles))
    set(handles.previousbutton,'Enable', 'on');
end

if( project.current == get_previous_index(handles))
    set(handles.previousbutton,'Enable', 'off');
end

if( project.current ~= get_next_index(handles))
    set(handles.nextbutton,'Enable', 'on');
end

% --- Executes on button press in turnonbutton. Turn on the selection_mode
function turnonbutton_Callback(hObject, eventdata, handles)
% hObject    handle to turnonbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
project = handles.project;
if( project.current == -1)
    return;
end

block = get_current_block(handles);
assert(block.is_interpolate())
handles = turn_on_selection(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in turnoffbutton. Turn off the
% selection_mode
function turnoffbutton_Callback(hObject, eventdata, handles)
% hObject    handle to turnoffbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
project = handles.project;
if( project.current == -1)
    return;
end

block = get_current_block(handles);
assert(block.is_interpolate())
handles = turn_off_selection(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in goodcheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function goodcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to goodcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = save_state(handles);
project = handles.project;

next_idx = handles.project.current;
val = get(handles.goodcheckbox, 'Value');
block = get_current_block(handles);

% If it's to be filtered and current must be changed
if( ~ val && block.is_good() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown and filter is off
if((val && is_filtered(handles, project.current)) || ...
        (val && block.is_good() ))
    if(block.is_good()  && ...
            ~ is_filtered(handles, project.current))
        next_idx = handles.project.current;
    else
        next_idx = get_next_index(handles);
        if(next_idx == -1)
            next_idx = get_previous_index(handles);
        end
    end
end

handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in okcheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function okcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to okcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = save_state(handles);
project = handles.project;
next_idx = handles.project.current;
val = get(handles.okcheckbox, 'Value');
block = get_current_block(handles);
if( ~ val && block.is_ok() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown
if((val && is_filtered(handles, project.current)) || ...
        (val && block.is_ok() ))
    if(block.is_ok()  && ...
            ~ is_filtered(handles, project.current))
        next_idx = handles.project.current;
    else
        next_idx = get_next_index(handles);
        if(next_idx == -1)
            next_idx = get_previous_index(handles);
        end
    end
end
handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in badcheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function badcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to badcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = save_state(handles);
project = handles.project;
next_idx = handles.project.current;
val = get(handles.badcheckbox, 'Value');
block = get_current_block(handles);
if( ~ val && block.is_bad() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown
if((val && is_filtered(handles, project.current)) || ...
        (val && block.is_bad() ))
    if(block.is_bad()  && ...
            ~ is_filtered(handles, project.current))
        next_idx = handles.project.current;
    else
        next_idx = get_next_index(handles);
        if(next_idx == -1)
            next_idx = get_previous_index(handles);
        end
    end
end
handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in interpolatecheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function interpolatecheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to interpolatecheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = save_state(handles);
project = handles.project;
next_idx = handles.project.current;
val = get(handles.interpolatecheckbox, 'Value');
block = get_current_block(handles);
if( ~ val && block.is_interpolate() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown
if((val && is_filtered(handles, project.current)) || ...
        (val && block.is_interpolate() ))
    if(block.is_interpolate()  && ...
            ~ is_filtered(handles, project.current))
        next_idx = handles.project.current;
    else
        next_idx = get_next_index(handles);
        if(next_idx == -1)
            next_idx = get_previous_index(handles);
        end
    end
end
handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in notratedcheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function notratedcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to notratedcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = save_state(handles);
project = handles.project;
next_idx = handles.project.current;
val = get(handles.notratedcheckbox, 'Value');
block = get_current_block(handles);
if( ~ val && block.is_not_rated() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown
if((val && is_filtered(handles, project.current)) || ...
        (val && block.is_not_rated() ))
    if(block.is_not_rated()  && ...
            ~ is_filtered(handles, project.current))
        next_idx = handles.project.current;
    else
        next_idx = get_next_index(handles);
        if(next_idx == -1)
            next_idx = get_previous_index(handles);
        end
    end
end
handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in previousbutton.
function previousbutton_Callback(hObject, eventdata, handles)
% hObject    handle to previousbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Change the cursor to a watch while updating...
set(handles.rating_gui, 'pointer', 'watch')
drawnow;

handles = previous(handles);

% Update handles structure
guidata(hObject, handles);

% Change back the cursor to an arrow
set(handles.rating_gui, 'pointer', 'arrow')

% --- Executes on button press in nextbutton.
function nextbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Change the cursor to a watch while updating...
set(handles.rating_gui, 'pointer', 'watch')
drawnow;

handles = next(handles);

% Update handles structure
guidata(hObject, handles);

% Change back the cursor to an arrow
set(handles.rating_gui, 'pointer', 'arrow')

% --- Executes when selected object is changed in rategroup.
function rategroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in rategroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = change_rating(handles);

% Update handles structure
guidata(hObject, handles);

% --- updates the rating based on gui input
function handles = change_rating(handles)
% handles  structure with handles of the gui

project = handles.project;
if(project.current == -1)
    return;
end
handles = get_rating_from_gui(handles);
block = get_current_block(handles);
update_lines(handles)
if( block.is_interpolate() )
   handles = turn_on_selection(handles);
end

% --- Executes on selection change in channellistbox. If a channel from the
% channel list is chosen, it will be drawn with 'red' color. Just a visual
% effect.
function channellistbox_Callback(hObject, eventdata, handles)
% hObject    handle to channellistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if( handles.project.current == -1)
    return;
end
project = handles.project;
index_selected = get(handles.channellistbox,'Value');

if( isempty(index_selected))
    return;
end

channels = cellstr(get(handles.channellistbox,'String'));
channel = channels{index_selected};
channel = str2num(channel);

update_lines(handles);
lines = findall(gcf,'Type','Line');
for i = 1:length(lines)
   if (lines(i).YData(1) == channel)
       break;
   end
end
delete(lines(i));
draw_line(channel, project.maxX, handles, 'r')


% --- Executes on selection change in subjectsmenu. It selects the block
% chosen by the user in the subjects menu list
function subjectsmenu_Callback(hObject, eventdata, handles)
% hObject    handle to subjectsmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Determine the selected data set.

% Change the cursor to a watch while updating...
set(handles.rating_gui, 'pointer', 'watch')
drawnow;

handles = save_state(handles);

project = handles.project;
list = get(hObject, 'String');
idx = get(hObject,'Value');
unique_name = list{idx};
IndexC = strfind(project.processed_list, unique_name);
Index = find(not(cellfun('isempty', IndexC)));
if( isempty(Index) )
    Index = -1;
end
project.current = Index;
handles.project = project;
handles = load_project(handles);

% Update handles structure
guidata(hObject, handles);

% Change back the cursor to an arrow
set(handles.rating_gui, 'pointer', 'arrow')

% --- Show the next file in the list
function handles = next(handles)
% handles  structure with handles of the gui

handles = save_state(handles);
handles.project.current = get_next_index(handles);
handles = load_project(handles);

% --- Show the previous file in the list
function handles = previous(handles)
% handles  structure with handles of the gui

handles = save_state(handles);
handles.project.current = get_previous_index(handles);
handles = load_project(handles);


% --- Get the selected rating from the gui for this current file. It does
% not save the result in the corresponsing file yet, but it does rename the
% result file immediately.
function handles = get_rating_from_gui(handles)
% handles  structure with handles of the gui

project = handles.project;
if ( ~ isa(handles,'struct') || project.current == -1)
    return
end

if( isempty(handles.rategroup.SelectedObject))
    return;
else
    block = get_current_block(handles);
    new_rate = handles.rategroup.SelectedObject.String;
    switch new_rate
        case {handles.CGV.ratings.Good, handles.CGV.ratings.OK, ...
                handles.CGV.ratings.Bad, handles.CGV.ratings.NotRated}
            block.setRatingInfoAndUpdate(new_rate, ...
                                        [], ...
                                        block.final_badchans, ...
                                        block.is_interpolated);
        case handles.CGV.ratings.Interpolate
                % The interpolate_list is untouched at this step. There maybe even
                % conflicts in it which are not checked.
                block.setRatingInfoAndUpdate(new_rate, ...
                block.tobe_interpolated, ...
                block.final_badchans, ...
                block.is_interpolated);
    end
end

% --- Draw all the channels that has been previously selected to be
% interpolated
function draw_lines(handles)
% handles  structure with handles of the gui

project = handles.project;
if(project.current == -1)
    return;
end
block = get_current_block(handles);
list = block.tobe_interpolated;
for chan = 1:length(list)
    draw_line(list(chan), project.maxX, handles, 'b');
end
set(handles.channellistbox,'String',list)

% --- Draw a horizontal line on the channel selected by y to mark it on the
% plot
function handles = draw_line(y, maxX, handles, color)
% handles  structure with handles of the gui
% y        the y-coordinate of the selected point to be drawn
% maxX     the maximum x-coordinate until which the line must be drawn in
%          the x-axis
% color    color of the line

axe = handles.axes;
axes(axe);
hold on;
p1 = [0, maxX];
p2 = [y, y];
p = plot(axe, p1, p2, color ,'LineWidth', 3);
set(p, 'ButtonDownFcn', {@delete_line, p, y, handles})
hold off;

% --- Draw a star * on the plot to show the channels that have been
% selected as bad channels during the preprocessing step. Note that they
% are not necessary interpolated.
function mark_interpolated_chans(handles)
% handles  structure with handles of the gui

project = handles.project;
if(project.current == -1)
    return;
end
block = get_current_block(handles);
badchans = block.auto_badchans;
axe = handles.axes;
axes(axe);
hold on;
for i = 1:length(badchans)
    plot(0 , badchans(i),'r*')
end
hold off;

% --- Turn on the selection mode to choose channels that should be
% interpolated
function handles = turn_on_selection(handles)
% handles  structure with handles of the gui
set(handles.turnoffbutton,'Enable', 'on')
set(handles.turnonbutton,'Enable', 'off')
handles.selection_mode = true;

% To update both oncall functions with new handles where the selection is
% changed
im = findobj(allchild(0), 'Tag', 'im');
set(im, 'ButtonDownFcn', {@on_selection,handles})
update_lines(handles)

set(gcf,'Pointer','crosshair');
switch_gui('off', handles);

% --- Turn of the slesction mode of channels
function handles = turn_off_selection(handles)
% handles  structure with handles of the gui
set(handles.turnoffbutton,'Enable', 'off')
set(handles.turnonbutton,'Enable', 'on')
handles.selection_mode = false;

% To update both oncall functions with new handles where the selection is
% changed
im = findobj(allchild(0), 'Tag', 'im');
set(im, 'ButtonDownFcn', {@on_selection,handles})
update_lines(handles)

set(gcf,'Pointer','arrow');
switch_gui('on', handles);

% --- Event handler for the selection
function on_selection(source, event, handles)
% handles  structure with handles of the gui
% event    the event object

if( handles.selection_mode )
    y = event.IntersectionPoint(2);
    process_input(y, handles);
end

% --- Save the selected channel to the interpolation list and draw a line
% to mark it on the plot
function process_input(y, handles)
% handles  structure with handles of the gui
% y        the y coordinate of the selected point
block = get_current_block(handles);
list = block.tobe_interpolated;
y = int64(y);
if( ismember(y, list ) )
    error('No way the callback function is called here !')
else
    list = [list y];
    draw_line(y, handles.project.maxX, handles, 'b');
end
block.setRatingInfoAndUpdate(handles.CGV.ratings.Interpolate, list, block.final_badchans, block.is_interpolated);
set(handles.channellistbox,'String',list)

% --- Redraw all lines
function update_lines(handles)
% handles  structure with handles of the gui

lines = findall(gcf,'Type','Line');
for i = 1:length(lines)
   delete(lines(i)); 
end
draw_lines(handles);
mark_interpolated_chans(handles);

% --- Delete the line selected by y and remove it from the interpolation
% list 
function delete_line(source, event, p, y, handles)
% handles  structure with handles of the gui
% y        the y-coordinate of the line to be deleted (number of the channel)
% p        the plot handler of the line (this is the plot seperated from the main plot)
% event    the event object

if( ~ handles.selection_mode )
    return;
end
axes(handles.axes);
delete(p);
block = get_current_block(handles);
list = block.tobe_interpolated;
list = list(list ~= y);
block.setRatingInfoAndUpdate(handles.CGV.ratings.Interpolate, list, block.final_badchans, block.is_interpolated);
set(handles.channellistbox,'String',list)

% --- Save the state of the project
function handles = save_state(handles)
% handles  structure with handles of the gui

if ( ~ isa(handles,'struct') || handles.project.current == -1)
    return

end

% Save the rating data into the preprocessing file
block = get_current_block(handles);
block.saveRatingsToFile();
% Now we should update five lists of ratings which are used to speed up the
% filtering pocess.
switch block.rate
    case handles.CGV.ratings.Good
        if( ~ ismember(block.index, handles.project.good_list ) )
            handles.project.good_list = ...
                [handles.project.good_list block.index];
            handles.project.not_rated_list(handles.project.not_rated_list == block.index) = [];
            handles.project.ok_list(handles.project.ok_list == block.index) = [];
            handles.project.bad_list(handles.project.bad_list == block.index) = [];
            handles.project.interpolate_list(handles.project.interpolate_list == block.index) = [];
            handles.project.good_list = sort(handles.project.good_list);

        end
    case handles.CGV.ratings.OK
        if( ~ ismember(block.index, handles.project.ok_list ) )
            handles.project.ok_list = ...
                [handles.project.ok_list block.index];
            handles.project.not_rated_list(handles.project.not_rated_list == block.index) = [];
            handles.project.good_list(handles.project.good_list == block.index) = [];
            handles.project.bad_list(handles.project.bad_list == block.index) = [];
            handles.project.interpolate_list(handles.project.interpolate_list == block.index) = [];
            handles.project.ok_list = sort(handles.project.ok_list);
        end
    case handles.CGV.ratings.Bad
        if( ~ ismember(block.index, handles.project.bad_list ) )
            handles.project.bad_list = ...
                [handles.project.bad_list block.index];
            handles.project.not_rated_list(handles.project.not_rated_list == block.index) = [];
            handles.project.ok_list(handles.project.ok_list == block.index) = [];
            handles.project.good_list(handles.project.good_list == block.index) = [];
            handles.project.interpolate_list(handles.project.interpolate_list == block.index) = [];
            handles.project.bad_list = sort(handles.project.bad_list);
        end
    case handles.CGV.ratings.Interpolate
        if( ~ ismember(block.index, handles.project.interpolate_list ) )
            handles.project.interpolate_list = ...
                [handles.project.interpolate_list block.index];
            handles.project.not_rated_list(handles.project.not_rated_list == block.index) = [];
            handles.project.ok_list(handles.project.ok_list == block.index) = [];
            handles.project.bad_list(handles.project.bad_list == block.index) = [];
            handles.project.good_list(handles.project.good_list == block.index) = [];
            handles.project.interpolate_list = sort(handles.project.interpolate_list);
        end
    case handles.CGV.ratings.NotRated
        if( ~ ismember(block.index, handles.project.not_rated_list ) )
            handles.project.not_rated_list = ...
                [handles.project.not_rated_list block.index];
            handles.project.good_list(handles.project.good_list == block.index) = [];
            handles.project.ok_list(handles.project.ok_list == block.index) = [];
            handles.project.bad_list(handles.project.bad_list == block.index) = [];
            handles.project.interpolate_list(handles.project.interpolate_list == block.index) = [];
            handles.project.not_rated_list = sort(handles.project.not_rated_list);
        end
end
        
% Save the stateS
if(isa(handles.project, 'Project'))
    handles.project.save_project();
end

% --- Executes when user attempts to close rating_gui.
function rating_gui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to rating_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Change the cursor to a watch while updating...
set(handles.rating_gui, 'pointer', 'watch')
drawnow;

save_state(handles);

if(isa(handles.project, 'EEGLabProject'))
    delete(hObject);
    return;
end

% Update the main gui's data after rating processing
h = findobj(allchild(0), 'flat', 'Tag', 'main_gui');
if( isempty(h))
    h = main_gui;
end
handle = guidata(h);
handle.project_list(handles.project.name) = handles.project;
guidata(handle.main_gui, handle);
main_gui();

% Change back the cursor to an arrow
set(handles.rating_gui, 'pointer', 'arrow')

% Hint: delete(hObject) closes the figure
delete(hObject);

function handles = set_shortcuts(handles)
h = findobj(allchild(0), 'flat', 'Tag', 'rating_gui');
set(h, 'KeyPressFcn', {@keyPress,handles})

function handles = keyPress(src, e, handles)
set(handles.turnonbutton,'Enable', 'off')
set(handles.turnoffbutton,'Enable', 'off')
shortcuts = handles.CGV.KEYBOARD_SHORTCUTS;

    switch e.Key
        case {shortcuts.GOOD}
            set(handles.rategroup,'selectedobject',handles.goodrate)
            handles = change_rating(handles);
        case {shortcuts.OK}
            set(handles.rategroup,'selectedobject',handles.okrate)
            handles = change_rating(handles);
        case {shortcuts.BAD}
            set(handles.rategroup,'selectedobject',handles.badrate)
            handles = change_rating(handles);
        case {shortcuts.INTERPOLATE}
            set(handles.rategroup,'selectedobject',handles.interpolaterate)
            set(handles.turnonbutton,'Enable', 'on')
            set(handles.turnoffbutton,'Enable', 'on')
            handles = change_rating(handles);
        case {shortcuts.NOTRATED}
            set(handles.rategroup,'selectedobject',handles.notrate)
            handles = change_rating(handles);
        case {shortcuts.NEXT}
            handles = next(handles);
        case {shortcuts.PREVIOUS}
            handles = previous(handles);
    end

% --- Executes during object creation, after setting all properties.
function subjectsmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectsmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function channellistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channellistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function colorscale_Callback(hObject, eventdata, handles)
% hObject    handle to colorscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_value = int16(get(hObject,'Value'));
set(handles.scaletext, 'String', ['[ -',num2str(new_value), ' ' ,num2str(new_value),']']);
handles.project.colorScale = new_value;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function colorscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on key press with focus on goodcheckbox and none of its controls.
function goodcheckbox_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to goodcheckbox (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in eegplotpush.
function eegplotpush_Callback(hObject, eventdata, handles)
% hObject    handle to eegplotpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(ispc)
    slash = '\';
else
    slash = '/';
end

% First add eeglab in path if not added yet
if(~exist('pop_fileio', 'file'))
    matlab_paths = genpath(['..' slash 'matlab_scripts' slash]);
    if(ispc)
        parts = strsplit(matlab_paths, ';');
    else
        parts = strsplit(matlab_paths, ':');
    end
    IndexC = strfind(parts, 'compat');
    Index = not(cellfun('isempty', IndexC));
    parts(Index) = [];
    IndexC = strfind(parts, 'neuroscope');
    Index = not(cellfun('isempty', IndexC));
    parts(Index) = [];
    if(ispc)
        matlab_paths = strjoin(parts, ';');
    else
        matlab_paths = strjoin(parts, ':');
    end
    addpath(matlab_paths);
    
    % Add path for 10_20 system
    IndexC = strfind(parts, 'BESA');
    Index = not(cellfun('isempty', IndexC));
end


% Plot
[~, data] = load_current(handles, false);
if(~ isempty(data))
    eegplot(data.data, 'srate', data.srate, 'eloc_file', data.chanlocs,...
        'dispchans', 55,'spacing', 50,'events', data.event,'winlength', 20);
end

% --- Executes on button press in averagereftoggle.
function averagereftoggle_Callback(hObject, eventdata, handles)
% hObject    handle to averagereftoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(get(hObject,'Value'))
    [~, data] = load_current(handles, true);
    show_current(data, true, handles);
    set(hObject, 'String', sprintf('Average Referencing: On'))
else
    [~, data] = load_current(handles, true);
    show_current(data, false, handles);
    set(hObject, 'String', sprintf('Average Referencing: Off'))
end
clear data;


% --- Executes on button press in detectedpushbutton.
function detectedpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to detectedpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

block = get_current_block(handles);
interpolated = block.final_badchans;
tobe_interpolated = block.tobe_interpolated;
autos = block.auto_badchans;
autos = setdiff(autos, interpolated);
tobe_interpolated = union(tobe_interpolated, autos);
if(~isempty(tobe_interpolated))
    rate = handles.CGV.ratings.Interpolate;
else
    rate = block.rate;
end
block.setRatingInfoAndUpdate(rate, tobe_interpolated', block.final_badchans, block.is_interpolated);

% Update handles structure
guidata(hObject, handles);

draw_lines(handles)
set_gui_rating(handles);