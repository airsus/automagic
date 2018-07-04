% --- Check whether this file is filtered by the user
function bool = is_filtered(handles, file)
% handles  structure with handles of the gui
% subj     could be a double indicating the index of the file or a char
%          indicating the name of it
project = handles.project;
if( project.current == -1)
    bool = true;
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