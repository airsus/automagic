% --- Delete the line selected by y and remove it from the interpolation
% list 
function delete_interpolate_line(source, event, p, y, handles)
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
block.setRatingInfoAndUpdate(handles.CGV.ratings.Interpolate, list, block.final_badchans, block.is_interpolated, true);
set(handles.channellistbox,'String',list)