function [result, fig] = preprocess(data, varargin)
% preprocess  preprocess the data 
%   [result, fig] = preprocess(data, varargin)
%   where data is the EEGLAB data structure and varargin is an 
%   optional parameter which must be a structure with optional fields 
%   'filter_params', 'asr_params', 'pca_params', 'ica_params'
%   'interpolation_params', 'eog_regression_params', 'eeg_system', 
%   'channel_reduction_params' and 'original_file' to specify parameters for 
%   filtering, channel rejection, pca, ica, interpolation, EOG regression, 
%   channel locations, reducing channels and original file address 
%   respectively. The latter one is needed only if a '*.fif' file is used,
%   otherwise it can be omitted.
%   
%   To learn more about 'filter_params', 'ica_params' and 'pca_params' 
%   please see their corresponding functions perform_filter.m, 
%   perform_ica.m and perform_pca.m.
%
%   'asr_params' is an optional structure which has the same parameters as 
%   required by clean_artifacts(). For more information please
%   see clean_artifacts() in Artefact Subspace Reconstruction.
%   
%   'interpolation_params' is an optional structure with an optional field
%   'method' which can be on of the following chars: 'spherical',
%   'invdist' and 'spacetime'. The default value is
%   interpolation_params.method = 'spherical'. To learn more about these
%   three methods please see eeg_interp.m of EEGLAB.
%   
%   'eog_regression_params' has a field 'perform_eog_regression' that 
%   must be a boolean indication whether to perform EOG Regression or not. 
%   The default value is 'eog_regression_params.perform_eog_regression = 1'
%   which performs eog regression. The other field 
%   'eog_regression_params.eog_chans' must be an array of numbers 
%   indicating indices of the EOG channels in the data.
%   
%   'channel_reduction_params.perform_reduce_channels' must be a boolean 
%   indicating whether to reduce the number of channels or not. The 
%   default value is 'channel_reduction_params.perform_reduce_channels = 1'
%   'channel_reduction_params.tobe_excluded_chans' must be an array of 
%   numbers indicating indices of the channels to be excluded from the 
%   analysis
%   
%   'original_file' is necassary only in case of '*.fif' files. In that case,
%   this should be the address of the file where this EEG data is loaded
%   from.
%   
%   eeg_system must be a structure with fields 'name', 'sys10_20', 'ref_chan', 
%   'loc_file' and 'file_loc_type'.  eeg_system.name can be either 'EGI' or 
%   'Others'. eeg_system.sys10_20 is a boolean indicating whether to use 
%   10-20 system to find channel locations or not. All other following 
%   fields are optional if eeg_system.name='EGI' and can be left empty. 
%   But in the case of eeg_system.name='Others':
%   eeg_system.ref_chan is the index of the reference channel in dataset. 
%   If it's left empty, a new reference channel will be added as the last 
%   channel of the dataset where all values are zeros and this new channel 
%   will be considered as the reference channel. If eeg_system.ref_chan == -1 
%   no reference channel is added and no channel is considered as reference 
%   channel at all. eeg_system.loc_file must be the name of the file located 
%   in 'matlab_scripts' folder that can be used by pop_chanedit to find 
%   channel locations and finally eeg_system.file_loc_type must be the type 
%   of that file. Please see pop_chanedit for more information. Obviously 
%   only types supported by pop_chanedit are supported.
%   
%   If varargin is ommited, default values are used. If any of the fields
%   of varargin are ommited, corresponsing default values are used. If a
%   structure is given as 'struct([])' then the corresponding operation is
%   omitted and is not performed; for example, ica_params = struct([])
%   skips the ICA and does not perform any ICA. Wheras if ica_params =
%   struct() if ica_params is simply not given, then the default value will
%   be used.
%
% Copyright (C) 2017  Amirreza Bahreini, amirreza.bahreini@uzh.ch
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

result = [];
fig = [];

%% Parse arguments
defaults = DefaultParameters;
constants = PreprocessingConstants;
p = inputParser;
addParameter(p,'eeg_system', defaults.eeg_system, @isstruct);
addParameter(p,'filter_params', defaults.filter_params, @isstruct);
addParameter(p,'prep_params', defaults.prep_params, @isstruct);
addParameter(p,'asr_params', defaults.asr_params, @isstruct);
addParameter(p,'pca_params', defaults.pca_params, @isstruct);
addParameter(p,'ica_params', defaults.ica_params, @isstruct);
addParameter(p,'interpolation_params', defaults.interpolation_params, @isstruct);
addParameter(p,'eog_regression_params', defaults.eog_regression_params, @isstruct);
addParameter(p,'channel_reduction_params', defaults.channel_reduction_params, @isstruct);
addParameter(p,'original_file', constants.general_constants.original_file, @ischar);
parse(p, varargin{:});
params = p.Results;
eeg_system = p.Results.eeg_system;
filter_params = p.Results.filter_params;
asr_params = p.Results.asr_params;
prep_params = p.Results.prep_params;
pca_params = p.Results.pca_params;
ica_params = p.Results.ica_params;
interpolation_params = p.Results.interpolation_params; %#ok<NASGU>
eog_regression_params = p.Results.eog_regression_params;
channel_reduction_params = p.Results.channel_reduction_params;
original_file_address = p.Results.original_file; %#ok<NASGU>
assert( isempty(ica_params) || isempty(pca_params), ...
    'Can not perform both ICA and PCA.');
clear p varargin;
%% Add path and download required packages
% Note that in each of the following cases a very naive approach is taken
% to see if the library is in path or not: simply check if one of the files
% exists or not.
eeg_system.sys10_20_file = constants.eeg_system_constants.sys10_20_file;
if(~exist('pop_fileio', 'file'))
    parts = add_eeglab_path();
    % Add path for 10_20 system
    
    % System dependence:
    if(ispc)
        slash = '\';
    else
        slash = '/';
    end
    
    IndexC = strfind(parts, 'BESA');
    Index = not(cellfun('isempty', IndexC));
    eeg_system.sys10_20_file = strcat(parts{Index}, slash, ...
        constants.eeg_system_constants.sys10_20_file);
    clear parts IndexC Index slash;
end

% Check and download if PCA does not exist
if( ~isempty(pca_params) && ~exist('inexact_alm_rpca.m', 'file'))
    download_pca();
end

% Check and download if Robust Average Referencing does not exist
if( ~isempty(prep_params) && ~ exist('performReference.m', 'file'))
    download_rar();
end

% Check and download if Artifact Subspace Reconstruction does not exist
if( ~ exist('clean_artifacts.m', 'file'))
    download_asr();
end

%% Determine the eeg system
% Case of others where the location file must have been provided
if (~isempty(eeg_system.name) && strcmp(eeg_system.name, constants.eeg_system_constants.Others_name))
    
    all_chans = 1:data.nbchan;
    tobe_excluded_chans = channel_reduction_params.tobe_excluded_chans;
    eog_channels = eog_regression_params.eog_chans;
    channels = setdiff(all_chans, union(eog_channels, tobe_excluded_chans));
    clear tobe_excluded_chans all_chans;
    
    if(isempty(eeg_system.ref_chan))
        data.data(end+1,:) = 0;
        data.nbchan = data.nbchan + 1;
        eeg_system.ref_chan = data.nbchan;
    end
    
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
elseif(~isempty(eeg_system.name) && strcmp(eeg_system.name, constants.eeg_system_constants.EGI_name))
    
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
            channels = setdiff(chan128, eog_channels);
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
            channels = setdiff(chan128, eog_channels);
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
            channels = setdiff(chan256, eog_channels);
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
            channels = setdiff(chan256, eog_channels);
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
            channels = find(cell2mat(eegs) & cell2mat(not_ecg) & cell2mat(not_wrong)); %#ok<NASGU>
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

            channels = find((cellfun(@(x) x == 1, eegs)));
            channel1 = find((cellfun(@(x) x == 1, eog1)));
            channel2 = find((cellfun(@(x) x == 1, eog2)));
            eog_channels = [channel1 channel2];
            channels = setdiff(channels, eog_channels); 
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
    channels = setdiff(all_chans, union(eog_channels, tobe_excluded_chans));
    clear tobe_excluded_chans all_chans;
end
s = size(data.data);
assert(data.nbchan == s(1)); clear s;
data.automagic.eeg_sytem.params = eeg_system;
data.automagic.channel_reduction.params = channel_reduction_params;
data.automagic.channel_reduction.used_eeg_channels = channels;
data.automagic.channel_reduction.used_eog_channels = eog_channels;

%% Preprocessing
% Seperate EEG channels from EOG channels
[~, EOG] = evalc('pop_select( data , ''channel'', eog_channels)');
[~, EEG] = evalc('pop_select( data , ''channel'', channels)');
% Map original channel lists to new ones after the above separation
[~, idx] = ismember(eeg_system.ref_chan, channels);
eeg_system.ref_chan = idx(idx ~= 0);
data.automagic.channel_reduction.new_ref_chan = eeg_system.ref_chan;

% Clean EEG using Artefact Supspace Reconstruction
[s, ~] = size(EEG.data);
asr_removed_chans_mask = false(1, s); clear s;
EEG_cleaned = EEG;
EEG_cleaned.automagic.asr.performed = 'no';
if ( ~isempty(asr_params) )
    display('Removing bad channels using Artifact Subspace Reconstruction...');
    [~, EEG_cleaned] = evalc('clean_artifacts(EEG, asr_params)');
    
    % If only channels are removed, remove them from the original EEG so
    % that the effect of high pass filtering is not there anymore
    if(strcmp(asr_params.BurstCriterion, 'off') && strcmp(asr_params.WindowCriterion, 'off'))
        etcfield = struct;
        if(isfield(EEG_cleaned, 'etc'))
            etcfield = EEG_cleaned.etc;
            
            if(isfield(EEG_cleaned.etc, 'clean_channel_mask'))
                remove_mask = ~EEG_cleaned.etc.clean_channel_mask;
                to_remove = find(remove_mask);
            end
        end
        
        [~, EEG_cleaned] = evalc('pop_select(EEG, ''nochannel'', to_remove)');
        EEG_cleaned.etc = etcfield;
        clear etcfield to_remove remove_mask;
    end
    
    EEG_cleaned.automagic.asr.performed = 'yes';
    if(isfield(EEG_cleaned, 'etc'))
        % Get the removed channels list
        if(isfield(EEG_cleaned.etc, 'clean_channel_mask'))
            asr_removed_chans_mask(~asr_removed_chans_mask) = ...
                ~EEG_cleaned.etc.clean_channel_mask;
        end

        % Remove the same time-windows from the EOG channels
       if(isfield(EEG_cleaned.etc, 'clean_sample_mask'))
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
           [~, EOG] = evalc('pop_select(EOG, ''nopoint'', remove_range)');
           clear remove_range firsts seconds removed;
       end
    end
end

% Robust Average Referecing
[s, ~] = size(EEG.data);
prep_removed_chans_mask = false(1, s); clear s;
EEG_cleaned.automagic.prep.performed = 'no';
if ( ~isempty(prep_params) )
    display(sprintf('Running Robust Average Referencing...'));
    % Remove the ref_chan containing zeros from prep preprocessing
    rar_chans = setdiff(1:EEG.nbchan, eeg_system.ref_chan);
    if isfield(prep_params, 'referenceChannels')
        prep_params.referenceChannels =  setdiff(prep_params.referenceChannels, eeg_system.ref_chan);
    else
        prep_params.referenceChannels = setdiff(rar_chans, eeg_system.ref_chan);
    end
    
    if isfield(prep_params, 'evaluationChannels')
        prep_params.evaluationChannels =  setdiff(prep_params.evaluationChannels, eeg_system.ref_chan);
    else
        prep_params.evaluationChannels = setdiff(rar_chans, eeg_system.ref_chan);
    end
    
    if isfield(prep_params, 'rereference')
        prep_params.rereference =  setdiff(prep_params.rereference, eeg_system.ref_chan);
    else
        prep_params.rereference = setdiff(rar_chans, eeg_system.ref_chan);
    end
    if isfield(filter_params, 'notch')
        if isfield(filter_params.notch, 'freq')
            freq = filter_params.notch.freq;
            prep_params.lineFrequencies = freq:freq:((EEG.srate/2)-1);
            clear freq;
        end
    end
    [~, EEG_preped, ~] = evalc('prepPipeline(EEG, prep_params)');
    info = EEG_preped.etc.noiseDetection;
    prep_removed_chans = union(union(info.stillNoisyChannelNumbers, ...
                                     info.interpolatedChannelNumbers), ...
                                     info.removedChannelNumbers);
    prep_removed_chans_mask(prep_removed_chans) = true;
    EEG_cleaned.automagic.prep.refchan = info.reference.referenceSignal;
    % Now convert the indices found in EEG to the corresponding indices
    % in EEG_cleaned which may have less channels as they are already 
    % removed by asr
    to_remove = prep_removed_chans_mask & ~asr_removed_chans_mask;
    to_remove = to_remove(~asr_removed_chans_mask); %#ok<NASGU>
    
    % And remove channels detected by prep which have not been detected by
    % asr
    [~, EEG_cleaned] = evalc('pop_select(EEG_cleaned, ''nochannel'', find(to_remove))');
    EEG_cleaned.automagic.prep.performed = 'yes';
    clear EEG_preped to_remove info rar_chans prep_removed_chans;
end

% Gather information from previous steps
asr_removed_chans = find(asr_removed_chans_mask);
prep_removed_chans = find(prep_removed_chans_mask);
removed_chans = union(asr_removed_chans, prep_removed_chans);
EEG_cleaned.automagic.prep.removed_chans = prep_removed_chans;
EEG_cleaned.automagic.asr.removed_chans = asr_removed_chans;
clear prep_removed_chans_mask asr_removed_chans_mask;


% Filtering on the whole dataset
EEG_filtered = perform_filter(EEG_cleaned, filter_params);
EOG_filtered = perform_filter(EOG, filter_params);


% Remove effect of EOG
EEG_filtered.automagic.eog_regression.performed = 'no';
if( eog_regression_params.perform_eog_regression )
    EEG_regressed = EOG_regression(EEG_filtered, EOG_filtered);
else
    EEG_regressed = EEG_filtered;
end


% PCA or ICA
EEG_regressed.automagic.ica.performed = 'no';
EEG_regressed.automagic.pca.performed = 'no';
if ( ~isempty(ica_params) )
    try
        EEG_cleared = perform_ica(EEG_regressed, ica_params);
    catch ME
        message = ['ICA is not done on this subject, continue with the next steps: ' ...
            ME.message];
        warning(message)
        EEG_cleared = EEG_regressed;
        EEG_cleared.automagic.ica.performed = 'FAILED';
        EEG_cleared.automagic.error_msg = message;
    end
elseif ( ~isempty(pca_params))
    [EEG_cleared, pca_noise] = perform_pca(EEG_regressed, pca_params);
else
    EEG_cleared = EEG_regressed;
end


% detrending
doubled_data = double(EEG_cleared.data);
res = bsxfun(@minus, doubled_data, mean(doubled_data, 2));
singled_data = single(res);

result = EEG_cleared;
result.data = singled_data;
clear doubled_data res singled_data;
% Put back removed channels
for chan_idx = 1:length(removed_chans)
    chan_nb = removed_chans(chan_idx);
    if( chan_nb == eeg_system.ref_chan)
        result.data = [result.data(1:chan_nb-1,:); ...
                        zeros(1,size(result.data,2));...
                        result.data(chan_nb:end,:)];
    else
        result.data = [result.data(1:chan_nb-1,:); ...
                        NaN(1,size(result.data,2));...
                        result.data(chan_nb:end,:)];
    end
    result.chanlocs = [result.chanlocs(1:chan_nb-1), EEG.chanlocs(chan_nb), ...
                    result.chanlocs(chan_nb:end)];
end
clear chan_nb;
result.nbchan = size(result.data,1);

% Write back output
result.automagic.auto_badchans = setdiff(removed_chans, eeg_system.ref_chan);
result.automagic.params = params;
%% Creating the final figure to save
fig = figure('visible', 'off');
set(gcf, 'Color', [1,1,1])
hold on
% eog figure
subplot(9,1,1)
imagesc(EOG_filtered.data);
colormap jet
caxis([-100 100])
XTicks = [] ;
XTicketLabels = [];
set(gca,'XTick', XTicks)
set(gca,'XTickLabel', XTicketLabels)
title('Filtered EOG data');
%eeg figure
subplot(9,1,2:3)
imagesc(EEG_filtered.data);
colormap jet
caxis([-100 100])
set(gca,'XTick', XTicks)
set(gca,'XTickLabel', XTicketLabels)
title('Filtered EEG data')
% figure;
subplot(9,1,4:5)
imagesc(EEG_regressed.data);
colormap jet
caxis([-100 100])
set(gca,'XTick',XTicks)
set(gca,'XTickLabel',XTicketLabels)
title('EOG regressed out');
%figure;
subplot(9,1,6:7)
imagesc(EEG_cleared.data);
colormap jet
caxis([-100 100])
set(gca,'XTick',XTicks)
set(gca,'XTickLabel',XTicketLabels)
if (~isempty(ica_params))
    title_text = 'ICA';
elseif(~isempty(pca_params))
    title_text = 'PCA';
else
    title_text = '';
end
title([title_text ' corrected clean data'])
%figure;
if( ~isempty(fieldnames(pca_params)) && (isempty(pca_params.lambda) || pca_params.lambda ~= -1))
    subplot(9,1,8:9)
    imagesc(pca_noise);
    colormap jet
    caxis([-100 100])
    XTicks = 0:length(EEG.data)/5:length(EEG.data) ;
    XTicketLabels = round(0:length(EEG.data)/EEG.srate/5:length(EEG.data)/EEG.srate);
    set(gca,'XTick',XTicks)
    set(gca,'XTickLabel',XTicketLabels)
    title('PCA noise')
end
