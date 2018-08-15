function [EEG_out, EOG_out] = perform_cleanrawdata(EEG_in, EOG_in, params)


to_remove = EEG_in.automagic.preprocessing.to_remove;
removed_mask = EEG_in.automagic.preprocessing.removed_mask;

EEG_out = EEG_in;
EOG_out = EOG_in;
EEG_out.automagic.asr.performed = 'no';
% TODO: take care of empty param and remove these lines
bad_chans = [];
if ( ~isempty(params) )
    fprintf('Detecting bad channels using routines of clean_raw_data()...\n');

    [~, EEG_cleaned] = evalc('clean_artifacts(EEG_in, params)');
    
    % If only channels are removed, remove them from the original EEG so
    % that the effect of high pass filtering is not there anymore
    if(isfield(EEG_cleaned, 'etc'))
        etcfield = EEG_cleaned.etc;
        if(isfield(EEG_cleaned.etc, 'clean_channel_mask'))
            new_mask = removed_mask;
            old_mask = removed_mask;
            new_mask(~new_mask) = ~etcfield.clean_channel_mask;
            bad_chans = setdiff(find(new_mask), find(old_mask));

            new_to_remove = union(to_remove, bad_chans);
        end
        EOG_out.etc = etcfield;
    
        % Remove the same time-windows from the EOG channels
       if(isfield(EEG_cleaned.etc, 'clean_sample_mask'))
           EEG_out = EEG_cleaned;
           
           if(isfield(EEG_cleaned.etc, 'clean_channel_mask'))
                removed_mask = new_mask;
                new_to_remove = to_remove;
            end
           
           removed = EEG_cleaned.etc.clean_sample_mask;
           firsts = find(diff(removed) == -1) + 1;
           seconds = find(diff(removed) == 1);
           if(removed(1) == 0)
               firsts = [1, firsts];
           end
           if(removed(end) == 0)
               seconds = [seconds, length(removed)];
           end
           remove_range = [firsts; seconds]'; %#ok<NASGU>
           [~, EOG_out] = evalc('pop_select(EOG_in, ''nopoint'', remove_range)');
       end
    end

    EEG_out.automagic.asr.performed = 'yes';
    EEG_out.automagic.asr.bad_chans = bad_chans;
    EEG_out.automagic.preprocessing.to_remove = new_to_remove;
    EEG_out.automagic.preprocessing.removed_mask = removed_mask;
end