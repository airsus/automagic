function popup_msg(msg_str, title)

handle = findobj(allchild(0), 'flat', 'Tag', 'rating_gui');
if(isempty(handle))
    handle = findobj(allchild(0), 'flat', 'Tag', 'main_gui');
end
main_pos = get(handle,'position');
if(strcmp(title, 'Error'))
    msg_handle = msgbox(msg_str, title, 'Error','modal');
else
    msg_handle = msgbox(msg_str, title, 'modal');
end
msg_pos = get(msg_handle,'position');
set(msg_handle, 'position', [main_pos(3)/2 main_pos(4)/2 msg_pos(3) msg_pos(4)]);
waitfor(msg_handle);