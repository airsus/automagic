classdef PreprocessingConstants
    %PreprocessingConstants is a class containing static constant variables 
    % used throughout the preprocessing. 
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
    properties(Constant)
        filter_constants = struct('notch_eu',      50, ...
                                  'notch_us',      60, ...
                                  'notch_other',   [], ...
                                  'run_message', 'Perform Filtering...')
        
        asr_constants = struct('asr_url', 'http://sccn.ucsd.edu/eeglab/plugins/clean_rawdata0.32.zip', ...
                               'run_message', 'Finding bad channels...');
                           
        prep_constants = struct('rar_url', 'https://github.com/VisLab/EEG-Clean-Tools/archive/master.zip')
        
        pca_constants = struct(...
            'pca_url', 'http://perception.csl.illinois.edu/matrix-rank/Files/inexact_alm_rpca.zip', ...
            'run_message', 'Performing PCA  (this may take a while...)');
                        
        ica_constants = struct(...
            'req_chan_labels', {{'C3','C4','Cz','F3','F4','F7','F8',...
            'Fp1','Fp2','Fz','LM','NAS','O1','O2','Oz','P3','P4','P7'...
            ,'P8','Pz','RM','T7','T8'}}, ...
            'run_message', 'Performing ICA  (this may take a while...)')
                    
        eog_regression_constants = ...
            struct('run_message', 'Perform EOG Regression...');
                        
        general_constants = struct('original_file', '', ...
                            'reduced_name', 'reduced');
                        
        eeg_system_constants = ...
            struct('sys10_20_file', 'standard-10-5-cap385.elp',...
                    'EGI_name', 'EGI',...
                     'Others_name', 'Others');
                    
    end
end