% --- Get the index of the next available file.
% There are five different lists corresponding to different ratings. The
% first possible block from each list is first chosen, and finally the one
% which precedes all others in the main list is chosen. For more info 
% on why these lists please read Project docs.
function next = get_next_index(handles)
% handles  structure with handles of the gui

project = handles.project;
block = project.get_current_block();
unique_name = block.unique_name;

good_bool = get(handles.goodcheckbox,'Value');
ok_bool = get(handles.okcheckbox,'Value');
bad_bool = get(handles.badcheckbox,'Value');
interpolate_bool = get(handles.interpolatecheckbox,'Value');
notrated_bool = get(handles.notratedcheckbox,'Value');

if( ~ is_filtered(handles, unique_name ))
    next_idx = project.current;
else
    next_idx = -1;
end

next = project.get_next_index(next_idx, good_bool, ok_bool, bad_bool, ...
    interpolate_bool, notrated_bool);

end