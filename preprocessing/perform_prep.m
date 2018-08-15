function EEG_out = perform_prep(EEG_in, prep_params, filter_params, ref_chan)

to_remove = EEG_in.automagic.preprocessing.to_remove;
removed_mask = EEG_in.automagic.preprocessing.removed_mask;

[s, ~] = size(EEG_in.data);
bad_chans_mask = false(1, s); clear s;

EEG_in.automagic.prep.performed = 'no';
EEG_out = EEG_in; % needed so clean_raw_data() runs, when PREP has not run.


if ( ~isempty(prep_params) )
    fprintf(sprintf('Running Prep...\n'));
    
    % Remove the ref_chan containing zeros from prep preprocessing
    rar_chans = setdiff(1:EEG_in.nbchan, ref_chan);
    if isfield(prep_params, 'referenceChannels')
        prep_params.referenceChannels =  ...
            setdiff(prep_params.referenceChannels, ref_chan);
    else
        prep_params.referenceChannels = rar_chans;
    end
    
    if isfield(prep_params, 'evaluationChannels')
        prep_params.evaluationChannels =  ...
            setdiff(prep_params.evaluationChannels, ref_chan);
    else
        prep_params.evaluationChannels = rar_chans;
    end
    
    if isfield(prep_params, 'rereference')
        prep_params.rereference =  ...
            setdiff(prep_params.rereference, ref_chan);
    else
        prep_params.rereference = rar_chans;
    end
    
    if isfield(filter_params, 'notch')
        if isfield(filter_params.notch, 'freq')
            freq = filter_params.notch.freq;
            prep_params.lineFrequencies = freq:freq:((EEG_in.srate/2)-1);
            
        end
    end

    
    
    
    [EEG_out, ~] = prepPipeline(EEG_in, prep_params);
    
    info = EEG_out.etc.noiseDetection;
    % Cancel the interpolation and referecing of prep
    EEG_out.data = bsxfun(@plus, EEG_out.data, info.reference.referenceSignal);

    % Get list of channels to be removed/interpolated later
    bad_chans = union(union(info.stillNoisyChannelNumbers, ...
                              info.interpolatedChannelNumbers), ...
                              info.removedChannelNumbers);
   
    bad_chans_mask(bad_chans) = true;
    new_mask = removed_mask;
    old_mask = removed_mask;
    new_mask(~new_mask) = bad_chans_mask;
    bad_chans = setdiff(find(new_mask), find(old_mask));

    EEG_out.automagic.prep.performed = 'yes';
    EEG_out.automagic.prep.refchan = info.reference.referenceSignal;
    EEG_out.automagic.prep.bad_chans = bad_chans;
    EEG_out.automagic.preprocessing.to_remove = union(bad_chans, to_remove);
end