function data = perform_ica(data, varargin)
% perform_ica
% The argument must be a map which maps all "possible" current channel
% labels to the standard channel labels given by FPz, F3, Fz, F4, Cz,
% Oz, ...

p = inputParser;
addParameter(p,'chanloc_map', containers.Map, @(x) isa(x, 'containers.Map'));
addParameter(p,'bool', 0, @isnumeric);
parse(p, varargin{:});

chanloc_map = p.Results.chanloc_map;
bool = p.Results.bool;

if (~bool)
    return;
end

if( ~ isempty(chanloc_map))
    inverse_chanloc_map = containers.Map(chanloc_map.values, chanloc_map.keys);
    idx = find(ismember({data.chanlocs.labels}, chanloc_map.keys));
    for i = idx
       data.chanlocs(1,i).labels = chanloc_map(data.chanlocs(1,i).labels);
    end
end

display('Performing ICA  (this may take a while...)');
options = [0 1 0 0 1];
[~, ~, EEG_Mara, ~] = evalc('processMARA_with_no_popup(data, data, 1, options)');
    
data = EEG_Mara;

if( ~ isempty(chanloc_map))
    for i = idx
       data.chanlocs(1,i).labels = inverse_chanloc_map(data.chanlocs(1,i).labels);
    end
end

end

function [ALLEEG,EEG,CURRENTSET] = processMARA_with_no_popup(ALLEEG,EEG,CURRENTSET,varargin)

    addpath('../matlab_scripts');
    if isempty(EEG.chanlocs)
        try
            error('No channel locations. Aborting MARA.')
        catch
           eeglab_error; 
           return; 
        end
    end
    
    if not(isempty(varargin))
        options = varargin{1}; 
    else
        options = [0 0 0 0 0]; 
    end
    

    %% filter the data
    if options(1) == 1
        disp('Filtering data');
        [EEG, LASTCOM] = pop_eegfilt(EEG);
        eegh(LASTCOM);
        [ALLEEG EEG CURRENTSET, LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET);
        eegh(LASTCOM);
    end

    %% run ica
    if options(2) == 1
        disp('Run ICA');
        
        [EEG, LASTCOM] = pop_runica(EEG, 'icatype','runica');
        g.gui = 'off';
        [ALLEEG EEG CURRENTSET, LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, g);
        eegh(LASTCOM);
    end

    %% check if ica components are present
    [EEG LASTCOM] = eeg_checkset(EEG, 'ica'); 
    if LASTCOM < 0
        disp('There are no ICA components present. Aborting classification.');
        return 
    else
        eegh(LASTCOM);
    end

    %% classify artifactual components with MARA
    [artcomps, MARAinfo] = MARA(EEG);
    EEG.reject.MARAinfo = MARAinfo; 
    disp('MARA marked the following components for rejection: ')
    if isempty(artcomps)
        disp('None')
    else
        disp(artcomps)    
        disp(' ')
    end
   
    
    if isempty(EEG.reject.gcompreject) 
        EEG.reject.gcompreject = zeros(1,size(EEG.icawinv,2)); 
        gcompreject_old = EEG.reject.gcompreject;
    else % if gcompreject present check whether labels differ from MARA
        if and(length(EEG.reject.gcompreject) == size(EEG.icawinv,2), ...
            not(isempty(find(EEG.reject.gcompreject))))
            
            tmp = zeros(1,size(EEG.icawinv,2));
            tmp(artcomps) = 1; 
            if not(isequal(tmp, EEG.reject.gcompreject)) 
       
                answer = questdlg(... 
                    'Some components are already labeled for rejection. What do you want to do?',...
                    'Labels already present','Merge artifactual labels','Overwrite old labels', 'Cancel','Cancel'); 
            
                switch answer,
                    case 'Overwrite old labels',
                        gcompreject_old = EEG.reject.gcompreject;
                        EEG.reject.gcompreject = zeros(1,size(EEG.icawinv,2));
                        disp('Overwrites old labels')
                    case 'Merge artifactual labels'
                        disp('Merges MARA''s and old labels')
                        gcompreject_old = EEG.reject.gcompreject;
                    case 'Cancel',
                        return; 
                end 
            else
                gcompreject_old = EEG.reject.gcompreject;
            end
        else
            EEG.reject.gcompreject = zeros(1,size(EEG.icawinv,2));
            gcompreject_old = EEG.reject.gcompreject;
        end
    end
    EEG.reject.gcompreject(artcomps) = 1;     
    
    try 
        EEGLABfig = findall(0, 'tag', 'EEGLAB');
        MARAvizmenu = findobj(EEGLABfig, 'tag', 'MARAviz'); 
        set(MARAvizmenu, 'Enable', 'on');
    catch
        keyboard
    end

    
    %% display components with checkbox to label them for artifact rejection  
    if options(3) == 1
        if isempty(artcomps)
            answer = questdlg2(... 
                'MARA identied no artifacts. Do you still want to visualize components?',...
                'No artifacts identified','Yes', 'No', 'No'); 
            if strcmp(answer,'No')
                return; 
            end
        end
        [EEG, LASTCOM] = pop_selectcomps_MARA(EEG, gcompreject_old); 
        eegh(LASTCOM);  
        if options(4) == 1
            pop_visualizeMARAfeatures(EEG.reject.gcompreject, EEG.reject.MARAinfo); 
        end
    end

    %% automatically remove artifacts
    if and(and(options(5) == 1, not(options(3) == 1)), not(isempty(artcomps)))
        try
            [EEG LASTCOM] = pop_subcomp(EEG, []);
            eegh(LASTCOM);
        catch
            eeglab_error
        end
        g.gui = 'off';
        [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, g); 
        eegh(LASTCOM);
        disp('Artifact rejection done.');
    end
end