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