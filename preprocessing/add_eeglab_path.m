function parts = add_eeglab_path()

% System dependence:
if(ispc)
    slash = '\';
else
    slash = '/';
end

matlab_paths = genpath(['..' slash 'matlab_scripts' slash]);
if(ispc)
    parts = strsplit(matlab_paths, ';');
else
    parts = strsplit(matlab_paths, ':');
end

IndexC = strfind(parts, 'compat');
Index = not(cellfun('isempty', IndexC));
parts(Index) = [];
IndexC = strfind(parts, 'neuroscope');
Index = not(cellfun('isempty', IndexC));
parts(Index) = [];
IndexC = strfind(parts, 'dpss');
Index = not(cellfun('isempty', IndexC));
parts(Index) = [];
if(ispc)
    matlab_paths = strjoin(parts, ';');
else
    matlab_paths = strjoin(parts, ':');
end
addpath(matlab_paths);
    
end