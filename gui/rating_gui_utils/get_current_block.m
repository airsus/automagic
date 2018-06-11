% Returns the block pointed by the current index. If current = -1, a mock
% block is returned.
function block = get_current_block(handles)
project = handles.project;

if( project.current == -1)
    subject = Subject('','');
    block = Block(project, subject, '', '', 0, []);
    block.index = -1;
    return;
end
unique_name = project.processed_list{project.current};
block = project.block_map(unique_name);