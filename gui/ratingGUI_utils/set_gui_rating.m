function handles = set_gui_rating(handles, cutoffs)
%set_gui_rating Set the rating of the gui based on the current project
% handles  structure with handles of the rating_gui

project = handles.project;
if( project.current == - 1 || is_filtered(handles, project.current))
    set(handles.rategroup,'selectedobject',[]);
    return
end
block = project.getCurrentBlock();

set(handles.turnonbutton,'Enable', 'off')
set(handles.turnoffbutton,'Enable', 'off')
switch block.rate
    case handles.CGV.RATINGS.Good
       set(handles.rategroup,'selectedobject', handles.goodrate)
    case handles.CGV.RATINGS.OK
        set(handles.rategroup,'selectedobject', handles.okrate)
    case handles.CGV.RATINGS.Bad
        set(handles.rategroup,'selectedobject', handles.badrate)
    case handles.CGV.RATINGS.Interpolate
        set(handles.rategroup,'selectedobject', handles.interpolaterate)
        set(handles.turnonbutton,'Enable', 'on')
        set(handles.turnoffbutton,'Enable', 'on')
    case handles.CGV.RATINGS.NotRated
        set(handles.rategroup,'selectedobject', handles.notrate)
end

res = rateQuality(block.getCurrentQualityScore(), cutoffs);
set(handles.qualityscoretext, 'FontSize', 6)
set(handles.qualityscoretext, 'String', evalc('disp(block.qualityScore)'))
switch res
    case handles.CGV.RATINGS.Good
       set(handles.goodrate,'ForegroundColor','red')
       set(handles.okrate,'ForegroundColor','black')
       set(handles.badrate,'ForegroundColor','black')
       set(handles.interpolaterate,'ForegroundColor','black')
    case handles.CGV.RATINGS.OK
       set(handles.goodrate,'ForegroundColor','black')
       set(handles.okrate,'ForegroundColor','red')
       set(handles.badrate,'ForegroundColor','black')
       set(handles.interpolaterate,'ForegroundColor','black')
    case handles.CGV.RATINGS.Bad
       set(handles.goodrate,'ForegroundColor','black')
       set(handles.okrate,'ForegroundColor','black')
       set(handles.badrate,'ForegroundColor','red')
       set(handles.interpolaterate,'ForegroundColor','black')
    case handles.CGV.RATINGS.Interpolate
       set(handles.goodrate,'ForegroundColor','black')
       set(handles.okrate,'ForegroundColor','black')
       set(handles.badrate,'ForegroundColor','black')
       set(handles.interpolaterate,'ForegroundColor','red')
end