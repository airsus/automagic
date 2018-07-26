% --- Make the plot of the current file
function handles = show_current(reduced, average_reference, handles)
% handles  structure with handles of the gui
% reduced  data file to be plotted
% average_reference bool specifying if average referencing should be
% performed or not

if isfield(reduced, 'data')
    data = reduced.data;
    project = handles.project;
    colorScale = project.colorScale;
    unique_name = project.processed_list{project.current};
else
    data = [];
    unique_name = 'no image';
    colorScale = handles.CGV.default_visualisation_params.COLOR_SCALE;
end


axe = handles.axes;
cla(axe);

% Averange reference data before plotting
if( average_reference && ~isempty(data))
    data_size = size(data);
    data = data - repmat(nanmean(data, 1), data_size(1), 1);
end

im = imagesc(data, 'tag', 'im');
set(im, 'ButtonDownFcn', {@on_selection,handles}, 'AlphaData',~isnan(data))
set(gcf, 'Color', [0.94,0.94,0.94])
colormap jet
caxis([-colorScale colorScale])
set(handles.titletext, 'String', unique_name) 


draw_lines(handles);
mark_interpolated_chans(handles)