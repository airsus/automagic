function [EEG_out, EOG_out] = perform_prep(EEG_in, EOG_in, prep_params, ref_chan)

EEG_out = EEG_in;
EOG_out = EOG_in;
EEG_out.automagic.prep.performed = 'no';
if isempty(prep_params)
    return; end

to_remove = EEG_in.automagic.preprocessing.to_remove;
removed_mask = EEG_in.automagic.preprocessing.removed_mask;

[s, ~] = size(EEG_in.data);
bad_chans_mask = false(1, s); clear s;


fprintf(sprintf('Running Prep...\n'));

% Remove the ref_chan containing zeros from prep preprocessing
eeg_chans = setdiff(1:EEG_in.nbchan, ref_chan);
eog_chans = setdiff(1: EEG_in.nbchan + EOG_in.nbchan, eeg_chans);
if isfield(prep_params, 'referenceChannels')
    prep_params.referenceChannels =  ...
        setdiff(prep_params.referenceChannels, ref_chan);
else
    prep_params.referenceChannels = eeg_chans;
end

if isfield(prep_params, 'evaluationChannels')
    prep_params.evaluationChannels =  ...
        setdiff(prep_params.evaluationChannels, ref_chan);
else
    prep_params.evaluationChannels = eeg_chans;
end

if isfield(prep_params, 'rereference')
    prep_params.rereference =  ...
        setdiff(prep_params.rereference, ref_chan);
else
    prep_params.rereference = [eeg_chans, eog_chans];
end

if isfield(prep_params, 'lineFrequencies')
    if length(prep_params.lineFrequencies) == 1
        freq = prep_params.lineFrequencies(1);
        prep_params.lineFrequencies = freq:freq:((EEG_in.srate/2)-1);
    end
end

% Combine both EEG and EOG for the analysis
new_EEG = EEG_in;
new_EEG.data = cat(1, EEG_in.data, EOG_in.data);
new_EEG.chanlocs = [EEG_in.chanlocs, EOG_in.chanlocs];
new_EEG.nbchan = EEG_in.nbchan + EOG_in.nbchan;

[~, new_EEG, ~] = evalc('prepPipeline(new_EEG, prep_params)');

% Separate EEG from EOG
[~, EEG_out] = evalc('pop_select( new_EEG , ''channel'', eeg_chans)');
[~, EOG_out] = evalc('pop_select( new_EEG , ''channel'', eog_chans)');

info = new_EEG.etc.noiseDetection;
% Cancel the interpolation and referecing of prep
EEG_out.data = bsxfun(@plus, EEG_out.data, info.reference.referenceSignal);
EOG_out.data = bsxfun(@plus, EOG_out.data, info.reference.referenceSignal);

% Get list of channels to be removed/interpolated later
bad_chans = union(union(info.stillNoisyChannelNumbers, ...
                          info.interpolatedChannelNumbers), ...
                          info.removedChannelNumbers);

bad_chans = bad_chans(bad_chans <= EEG_in.nbchan); % TODO: This looks like a hack.
                                                  % Why should prep give EOG channels as bad channels?
bad_chans_mask(bad_chans) = true;
new_mask = removed_mask;
old_mask = removed_mask;
new_mask(~new_mask) = bad_chans_mask;
bad_chans = setdiff(find(new_mask), find(old_mask));

EEG_out.automagic.prep.performed = 'yes';
if isfield(prep_params, 'lineFrequencies')
    EEG_out.automagic.prep.lineFrequencies = prep_params.lineFrequencies;
end
EEG_out.automagic.prep.refchan = info.reference.referenceSignal;
EEG_out.automagic.prep.bad_chans = bad_chans;
EEG_out.automagic.preprocessing.to_remove = union(bad_chans, to_remove);