function [EEG, EOG, eeg_system, ica_params] = system_dependent_params(data, eeg_system, channel_reduction_params, eog_regression_params,ica_params)

constants = PreprocessingConstants;
                          
% Add the 10_20 file to eeg_system
parts = add_eeglab_path();
if(~isempty(parts)) 
    
    % System dependence:
    if(ispc)
        slash = '\';
    else
        slash = '/';
    end

    eeg_system.sys10_20_file = constants.eeg_system_constants.sys10_20_file;
        Index = not(~contains(parts, 'BESA'));
        eeg_system.sys10_20_file = strcat(parts{Index}, slash, ...
                 constants.eeg_system_constants.sys10_20_file);
end

%% Determine the eeg system
% Case of others where the location file must have been provided
if (~isempty(eeg_system.name) && ...
        strcmp(eeg_system.name, constants.eeg_system_constants.Others_name))
    
    if(isempty(eeg_system.ref_chan))
        data.data(end+1,:) = 0;
        data.nbchan = data.nbchan + 1;
        eeg_system.ref_chan = data.nbchan;
    end
    all_chans = 1:data.nbchan;
    tobe_excluded_chans = channel_reduction_params.tobe_excluded_chans;
    eog_channels = eog_regression_params.eog_chans;
    eeg_channels = setdiff(all_chans, union(eog_channels, tobe_excluded_chans));
    clear tobe_excluded_chans all_chans;
    
    % if the reference channel is not included in chanlocs, add it there
    % with an arbitrary location.
    if (size(data.chanlocs,2) ~= size(data.data,1))
        data.chanlocs(size(data.data,1)) = data.chanlocs(end);
        data.chanlocs(end).labels = 'REF';
    end
    
    
    % If chanloc is not a provided field load it from the provided file
    if(isempty(data.chanlocs) || isempty([data.chanlocs.X]) || ...
        length(data.chanlocs) ~= data.nbchan)
        if(~ eeg_system.sys10_20)
            [~, data] = evalc(['pop_chanedit(data,' ...
                '''load'',{ eeg_system.loc_file , ''filetype'', eeg_system.file_loc_type})']);
        else
            [~, data] = evalc(['pop_chanedit(data, ''lookup'', eeg_system.sys10_20_file,' ...
                '''load'',{ eeg_system.loc_file , ''filetype'', ''autodetect''})']);
        end
    end

% Case of EGI
elseif(~isempty(eeg_system.name) && ...
        strcmp(eeg_system.name, constants.eeg_system_constants.EGI_name))
    
    if( channel_reduction_params.perform_reduce_channels )
        chan128 = [2 3 4 5 6 7 9 10 11 12 13 15 16 18 19 20 22 23 24 26 27 ...
            28 29 30 31 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 50 51 ...
            52 53 54 55 57 58 59 60 61 62 64 65 66 67 69 70 71 72 74 75 76 ...
            77 78 79 80 82 83 84 85 86 87 89 90 91 92 93 95 96 97 98 100 ...
            101 102 103 104 105 106 108 109 110 111 112 114 115 116 117 ...
            118 120 121 122 123 124 129];

        chan256  = [2 3 4 5 6 7 8 9 11 12 13 14 15 16 17 19 20 21 22 ...
            23 24 26 27 28 29 30 33 34 35 36 38 39 40 41 42 43 44 45 ...
            47 48 49 50 51 52 53 55 56 57 58 59 60 61 62 63 64 65 66 ...
            68 69 70 71 72 74 75 76 77 78 79 80 81 83 84 85 86 87 88 ...
            89 90 93 94 95 96 97 98 99 100 101 103 104 105 106 107 108 ...
            109 110 112 113 114 115 116 117 118 119 121 122 123 124 125 ...
            126 127 128 129 130 131 132 134 135 136 137 138 139 140 141 ...
            142 143 144 146 147 148 149 150 151 152 153 154 155 156 157 ...
            158 159 160 161 162 163 164 166 167 168 169 170 171 172 173 ...
            175 176 177 178 179 180 181 182 183 184 185 186 188 189 190 ...
            191 192 193 194 195 196 197 198 200 201 202 203 204 205 206 ...
            207 210 211 212 213 214 215 220 221 222 223 224 257];
    else
        chan128 = 1:129;
        chan256 = 1:257;
    end

    switch data.nbchan
        case 128
            eog_channels = sort([1 32 8 14 17 21 25 125 126 127 128]);
            eeg_channels = setdiff(chan128, eog_channels);
            data.data(end+1,:) = 0;
            data.nbchan = data.nbchan + 1;
            eeg_system.ref_chan = data.nbchan;
            
            if(isempty(data.chanlocs) || isempty([data.chanlocs.X]) || ...
                    length(data.chanlocs) ~= data.nbchan)
                if(~ eeg_system.sys10_20)
                    [~, data] = evalc(['pop_chanedit(data,' ...
                        '''load'',{ ''GSN-HydroCel-129.sfp'' , ''filetype'', ''sfp''})']);
                else
                    [~, data] = evalc(['pop_chanedit(data, ''lookup'', eeg_system.sys10_20_file,' ...
                        '''load'',{ ''GSN-HydroCel-129.sfp'' , ''filetype'', ''autodetect''})']);
                end
            end
        case (128 + 1)
            eog_channels = sort([1 32 8 14 17 21 25 125 126 127 128]);
            eeg_channels = setdiff(chan128, eog_channels);
            eeg_system.ref_chan = data.nbchan;
            if(isempty(data.chanlocs) || isempty([data.chanlocs.X]) || ...
                    length(data.chanlocs) ~= data.nbchan)
                if(~ eeg_system.sys10_20)
                    [~, data] = evalc(['pop_chanedit(data,' ...
                        '''load'',{ ''GSN-HydroCel-129.sfp'' , ''filetype'', ''sfp''})']);
                else
                    [~, data] = evalc(['pop_chanedit(data, ''lookup'', eeg_system.sys10_20_file,' ...
                        '''load'',{ ''GSN-HydroCel-129.sfp'' , ''filetype'', ''autodetect''})']);
                end
            end
        case 256
            eog_channels = sort([31 32 37 46 54 252 248 244 241 25 18 10 1 226 ...
                230 234 238]);
            eeg_channels = setdiff(chan256, eog_channels);
            data.data(end+1,:) = 0;
            data.nbchan = data.nbchan + 1;
            eeg_system.ref_chan = data.nbchan;
            if(isempty(data.chanlocs) || isempty([data.chanlocs.X]) || ...
                    length(data.chanlocs) ~= data.nbchan)
                if(~ eeg_system.sys10_20)
                    [~, data] = evalc(['pop_chanedit(data,' ...
                        '''load'',{ ''GSN-HydroCel-257_be.sfp'' , ''filetype'', ''sfp''})']);
                else
                    [~, data] = evalc(['pop_chanedit(data, ''lookup'', eeg_system.sys10_20_file,' ...
                        '''load'',{ ''GSN-HydroCel-257_be.sfp'' , ''filetype'', ''autodetect''})']);
                end
            end
        case (256 + 1)
            eog_channels = sort([31 32 37 46 54 252 248 244 241 25 18 10 1 226 ...
                230 234 238]);
            eeg_channels = setdiff(chan256, eog_channels);
            eeg_system.ref_chan = data.nbchan;
            if(isempty(data.chanlocs) || isempty([data.chanlocs.X]) || ...
                    length(data.chanlocs) ~= data.nbchan)
                if(~ eeg_system.sys10_20)
                    [~, data] = evalc(['pop_chanedit(data,' ...
                        '''load'',{ ''GSN-HydroCel-257_be.sfp'' , ''filetype'', ''sfp''})']);
                else
                    [~, data] = evalc(['pop_chanedit(data, ''lookup'', eeg_system.sys10_20_file,' ...
                        '''load'',{ ''GSN-HydroCel-257_be.sfp'' , ''filetype'', ''autodetect''})']);
                end
            end
        case 395  %% .fif files
            addpath('../fieldtrip-20160630/'); 
            % Get rid of two wrong channels 63 and 64
            eegs = arrayfun(@(x) strncmp('EEG',x.labels, length('EEG')), data.chanlocs, 'UniformOutput', false);
            not_ecg = arrayfun(@(x) ~ strncmp('EEG063',x.labels, length('EEG063')), data.chanlocs, 'UniformOutput', false);
            not_wrong = arrayfun(@(x) ~ strncmp('EEG064',x.labels, length('EEG064')), data.chanlocs, 'UniformOutput', false);
            eeg_channels = find(cell2mat(eegs) & cell2mat(not_ecg) & cell2mat(not_wrong)); %#ok<NASGU>
            [~, data] = evalc('pop_select( data , ''channel'', channels)');
            data.data = data.data * 1e6;% Change from volt to microvolt
            % Convert channel positions to EEG_lab format 
            [~, hd] = evalc('ft_read_header(original_file_address)');
            hd_idx = true(1,74);
            hd_idx(63:64) = false;
            positions = hd.elec.chanpos(hd_idx,:);
            fid = fopen( 'pos_temp.txt', 'wt' );
            fprintf( fid, 'NumberPositions=	72\n');
            fprintf( fid, 'UnitPosition	cm\n');
            fprintf( fid, 'Positions\n');
            for pos = 1:length(positions)
              fprintf( fid, '%.8f %.8f %.8f\n', positions(pos,:));
            end
            fprintf( fid, 'Labels\n');
            fprintf( fid, ['EEG01	EEG02	EEG03	EEG04	EEG05	EEG06	EEG07	EEG08	EEG09	EEG010	EEG011	EEG012 '...
                          'EEG013	EEG014	EEG015	EEG016	EEG017	EEG018	EEG019	EEG020	EEG021	EEG022	EEG023	EEG024 '...
                          'EEG025	EEG026	EEG027	EEG028	EEG029	EEG030	EEG031	EEG032	EEG033	EEG034	EEG035	EEG036 '...
                          'EEG037	EEG038	EEG039	EEG040	EEG041	EEG042	EEG043	EEG044	EEG045	EEG046	EEG047	EEG048 '...
                          'EEG049	EEG050	EEG051	EEG052	EEG053	EEG054	EEG055	EEG056	EEG057	EEG058	EEG059	EEG060 '...
                          'EEG061	EEG062 EEG065	EEG066	EEG067	EEG068	EEG069	EEG070	EEG071	EEG072 '...
                          'EEG073	EEG074']);
            fprintf( fid, '\n');
            fclose(fid);
            eeglab_pos = readeetraklocs('pos_temp.txt');
            delete('pos_temp.txt');
            data.chanlocs = eeglab_pos;

            % Distinguish EOGs(61 & 62) from EEGs
            eegs = arrayfun(@(x) strncmp('EEG',x.labels, length('EEG')), data.chanlocs, 'UniformOutput', false);
            eog1 = arrayfun(@(x) strncmp('EEG061',x.labels, length('EEG061')), data.chanlocs, 'UniformOutput', false);
            eog2 = arrayfun(@(x) strncmp('EEG062',x.labels, length('EEG062')), data.chanlocs, 'UniformOutput', false); 

            eeg_channels = find((cellfun(@(x) x == 1, eegs)));
            channel1 = find((cellfun(@(x) x == 1, eog1)));
            channel2 = find((cellfun(@(x) x == 1, eog2)));
            eog_channels = [channel1 channel2];
            eeg_channels = setdiff(eeg_channels, eog_channels); 
            eeg_system.ref_chan = data.nbchan;
            clear channel1 channel2 eegs eog1 eog2 eeglab_pos fid hd_idx hd not_wrong not_ecg eegs;
        otherwise
            error('This number of channel is not supported.')

    end
    clear chan128 chan256;
    
    % Make ICA map of channels
    if (~isempty(ica_params))
        switch data.nbchan
            case 129
                % Make the map for ICA
                if(ica_params.large_map)
                    keySet = {'E36', 'E104', 'E129', 'E24', 'E124', 'E33', 'E122', 'E22', 'E9', ...
                        'E14', 'E11', 'E70', 'E83', 'E52', 'E92', 'E58', 'E96', 'E45', ...
                        'E108', 'E23', 'E3', 'E26', 'E2', 'E16', 'E30', 'E105', 'E41', 'E103', 'E37', ...
                        'E87', 'E42', 'E93', 'E47', 'E98', 'E55', 'E19', 'E1', 'E4', 'E27', ...
                        'E123', 'E32', 'E13', 'E112', 'E29', 'E111', 'E28', 'E117', 'E6', ...
                        'E12', 'E34', 'E116', 'E38', 'E75', 'E60', 'E64', 'E95', 'E85', ...
                        'E51', 'E97', 'E64', 'E67', 'E77', 'E65', 'E90', 'E72', 'E62', ...
                        'E114', 'E45', 'E108', 'E44', 'E100', 'E46', 'E102', 'E57'};
                    valueSet =   {'C3', 'C4', 'Cz', 'F3', 'F4', 'F7', 'F8', 'FP1', 'FP2', ...
                        'FPZ', 'Fz', 'O1', 'O2', 'P3', 'P4', 'P7', 'P8', 'T7', 'T8', 'AF3',...
                        'AF4', 'AF7', 'AF8', 'Afz', 'C1', 'C2', 'C5', 'C6', 'CP1', 'Cp2', ...
                        'CP3', 'CP4', 'Cp5', 'CP6', 'CpZ', 'F1', 'F10', 'F2', 'F5', 'F6', ...
                        'F9', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Fcz', 'Ft10', ...
                        'FT7', 'FT8', 'Ft9', 'Oz', 'P1', 'P9', 'P10', 'P2', 'P5', 'P6', ...
                        'P9', 'PO3', 'PO4', 'PO7', 'PO8', 'Poz', 'Pz', 'T10', 'T11', 'T12',...
                        'T9', 'TP10', 'Tp7', 'TP8', 'TP9'};
                else
                    keySet = {'E17', 'E22', 'E9', 'E11', 'E24', 'E124', 'E33', 'E122', ...
                        'E129', 'E36', 'E104', 'E45', 'E108', 'E52', 'E92', 'E57', 'E100', ...
                        'E58', 'E96', 'E70', 'E75', 'E83', 'E62', 'E14'};
                    valueSet =   {'NAS', 'Fp1', 'Fp2', 'Fz', 'F3', 'F4', 'F7', 'F8', 'Cz', ...
                        'C3', 'C4', 'T7', 'T8', 'P3', 'P4', 'LM', 'RM', 'P7', 'P8', 'O1', ...
                        'Oz', 'O2', 'Pz', 'FPZ'};
                end
                ica_params.chanloc_map = containers.Map(keySet,valueSet);
            case 257
                if(ica_params.large_map)
                    keySet = {'E59', 'E183', 'E257', 'E36', 'E224', 'E47', 'E2', 'E37', ...
                        'E18', 'E26', 'E21', 'E116', 'E150', 'E87', 'E153', 'E69', 'E202', ...
                        'E96', 'E170', 'E101', 'E119', 'E5', 'E49', 'E219', 'E194', 'E67', ...
                        'E222', 'E211', 'E10', 'E81', 'E172', 'E64', 'E164', 'E169', 'E252', ...
                        'E88', 'E86', 'E34', 'E44', 'E161', 'E12', 'E20', 'E179', 'E42', ...
                        'E66', 'E162', 'E109', 'E185', 'E24', 'E140', 'E126', 'E143', 'E207',...
                        'E79', 'E94', 'E29', 'E15', 'E190', 'E226', 'E142', 'E48', 'E106', ...
                        'E206', 'E76', 'E213', 'E27', 'E97', 'E46', 'E26', 'E84', 'E62', 'E68', 'E210'};
                    valueSet =   {'C3', 'C4', 'Cz', 'F3', 'F4', 'F7', 'F8', 'FP1', 'FP2', ...
                        'FPZ', 'Fz', 'O1', 'O2', 'P3', 'P4', 'T7', 'T8', 'P7', 'P8', 'Pz',...
                        'Poz', 'F2', 'FC5', 'Ft10', 'C6', 'Ft9', 'F6', 'FT8', 'AF8', 'CpZ',...
                        'CP6', 'C5', 'CP4', 'P10', 'F9', 'P1', 'P5', 'AF3', 'C1', 'PO8', ...
                        'AF4', 'Afz', 'TP8', 'FC3', 'CP3', 'P6', 'PO3', 'C2', 'FC1', 'PO4', ...
                        'Oz', 'Cp2', 'FC2', 'CP1', 'TP9', 'F1', 'Fcz', 'TP10', 'F10', 'P2', ...
                        'F5', 'P9', 'FC4', 'Cp5', 'FC6', 'Afz', 'Po7', 'AF7', 'Afz', 'Tp7', ...
                        'FT7', 'T9', 'T10'};
                else
                    keySet = {'E31', 'E37', 'E18', 'E21', 'E36', 'E224', 'E47', ...
                        'E2', 'E257', 'E59', 'E183', 'E69', 'E202', 'E87', 'E153', ...
                        'E94', 'E190', 'E96', 'E170', 'E116', 'E126', 'E150', 'E101', 'E26'};
                    valueSet =   {'NAS', 'Fp1', 'Fp2', 'Fz', 'F3', 'F4', 'F7', 'F8', 'Cz', ...
                        'C3', 'C4', 'T7', 'T8', 'P3', 'P4', 'LM', 'RM', 'P7', 'P8', 'O1', ...
                        'Oz', 'O2', 'Pz', 'FPZ'};
                end
                ica_params.chanloc_map = containers.Map(keySet,valueSet);
        end
        clear keySet valueSet;
    end
else
   if(isempty(data.chanlocs) || isempty([data.chanlocs.X]) || ...
                    length(data.chanlocs) ~= data.nbchan)
       error('data.chanlocs is necessary for interpolation.');
   end
    all_chans = 1:data.nbchan;
    eog_channels = eog_regression_params.eog_chans;
    tobe_excluded_chans = channel_reduction_params.tobe_excluded_chans;
    eeg_channels = setdiff(all_chans, union(eog_channels, tobe_excluded_chans));
    clear tobe_excluded_chans all_chans;
end

%% Preprocessing
% Seperate EEG channels from EOG channels
[~, EOG] = evalc('pop_select( data , ''channel'', eog_channels)');
[~, EEG] = evalc('pop_select( data , ''channel'', eeg_channels)');
% Map original channel lists to new ones after the above separation
[~, idx] = ismember(eeg_system.ref_chan, eeg_channels);
eeg_system.ref_chan = idx(idx ~= 0);

data.automagic.eeg_sytem.params = eeg_system;
data.automagic.channel_reduction.params = channel_reduction_params;
data.automagic.channel_reduction.used_eeg_channels = eeg_channels;
data.automagic.channel_reduction.used_eog_channels = eog_channels;

end