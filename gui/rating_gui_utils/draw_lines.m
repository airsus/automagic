% --- Draw all the channels that has been previously selected to be
% interpolated
function draw_lines(handles)
% handles  structure with handles of the gui
project = handles.project;
if(project.current == -1)
    return;
end
block = get_current_block(handles);
if strcmp(block.rate, handles.CGV.ratings.Interpolate)
    list = block.tobe_interpolated;
else
    list = [];
end

axe = handles.axes;
axes(axe);
for chan = 1:length(list)
    draw_line(list(chan), project.maxX, handles, 'b', axe);
end
set(handles.channellistbox,'String',list)