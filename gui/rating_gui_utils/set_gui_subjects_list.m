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