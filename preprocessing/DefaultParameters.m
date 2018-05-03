classdef DefaultParameters
    %DefaultParameters is a class containing default parameters for
    %   different preprocessing steps.
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
       filter_params = struct('notch',    struct('freq', 50),...
                              'high',     struct('freq', 0.5,...
                                                 'order', []),... % Default
                              'low',      struct([]))      % Deactivated
                            
        asr_params = struct('ChannelCriterion',     0.85,...
                            'LineNoiseCriterion',   4,...
                            'BurstCriterion',       'off',...
                            'WindowCriterion',      'off', ...
                            'Highpass',             [0.25 0.75]);
        
        prep_params = struct([]);                           % Deactivated
        
        interpolation_params = struct('method', 'spherical');
        
        pca_params = struct([]);                            % Deactivated
        
        ica_params = struct('chanloc_map', containers.Map, ...
                            'large_map', 0)
                    
        eog_regression_params = struct('perform_eog_regression', 1, ...
                                       'eog_chans', '');
                        
        channel_reduction_params = struct('perform_reduce_channels', 1, ...
                                          'tobe_excluded_chans', '');
                                      
                                      
        eeg_system = struct('name', 'EGI',...
                            'sys10_20', 0, ...
                            'loc_file', '', ...
                            'ref_chan', [], ...
                            'file_loc_type', '');
    end
end