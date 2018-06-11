% --- Set the rating of the gui based on the current project
function handles = set_gui_rating(handles)
% handles  structure with handles of the rating_gui

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
       set(handles.rategroup,'selectedobject', handles.goodrate)
    case handles.CGV.ratings.OK
        set(handles.rategroup,'selectedobject', handles.okrate)
    case handles.CGV.ratings.Bad
        set(handles.rategroup,'selectedobject', handles.badrate)
    case handles.CGV.ratings.Interpolate
        set(handles.rategroup,'selectedobject', handles.interpolaterate)
        set(handles.turnonbutton,'Enable', 'on')
        set(handles.turnoffbutton,'Enable', 'on')
    case handles.CGV.ratings.NotRated
        set(handles.rategroup,'selectedobject', handles.notrate)
end