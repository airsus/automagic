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