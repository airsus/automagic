% --- Load the current "reduced" file to the work space (The file is 
% downsampled to speed up the loading)
function [handles, data] = load_current(handles, get_reduced) %#ok<STOUT>
% handles   structure with handles of the gui

project = handles.project;
if ( project.current == - 1 || is_filtered(handles, project.current))
    data = [];
else
    block = get_current_block(handles);
    if(isa(block, 'Block'))
%         block.update_addresses(project.data_folder, project.result_folder);
        if(get_reduced)
            load(block.reduced_address);
            data = reduced;
        else
            load(block.result_address);
            data.data = EEG.data;
            data.srate = EEG.srate;
            data.chanlocs = EEG.chanlocs;
            data.event = EEG.event;
        end
    elseif(isa(block, 'EEGLabBlock'))
        data = block.get_reduced();
    end
    handles.project.maxX = max(project.maxX, size(data.data, 2));% for the plot
end