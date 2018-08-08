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

Index = not(~contains(parts, 'compat'));
parts(Index) = [];
Index = not(~contains(parts, 'neuroscope'));
parts(Index) = [];
Index = not(~contains(parts, 'dpss'));
parts(Index) = [];
if(ispc)
    matlab_paths = strjoin(parts, ';');
else
    matlab_paths = strjoin(parts, ':');
end
addpath(matlab_paths);
    
end