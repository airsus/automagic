% --- Save the selected channel to the interpolation list and draw a line
% to mark it on the plot
function process_input(y, handles)
% handles  structure with handles of the gui
% y        the y coordinate of the selected point
block = handles.project.get_current_block();
list = block.tobe_interpolated;
y = int64(y);
if( ismember(y, list ) )
    error('No way the callback function is called here !')
else
    list = [list y];
    axe = handles.axes;
    axes(axe);
    draw_line(y, handles.project.maxX, handles, 'b', axe);
end
block.setRatingInfoAndUpdate(struct('tobe_interpolated', list));
set(handles.channellistbox,'String',list)