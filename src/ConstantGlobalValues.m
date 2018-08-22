classdef ConstantGlobalValues
    %ConstantGlobalValues is a class containing all constant values used
    %throughout the application.
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

        version = '1.7.4';
            
        DEFAULT_keyword = 'Default';
                
        NONE_keyword = 'None';
        
        new_project = struct('LIST_NAME', 'Create New Project...', ...
            'NAME', 'Type the name of your new project...', ...
            'DATA_FOLDER', 'Choose where your raw data is...', ...
            'FOLDER', 'Choose where you want the results to be saved...');
        
        load_selected_project = struct('LIST_NAME', 'Load an existing project...');
        
        prefix_pattern = '^[gobni]i?p_';
        
        ratings = struct('Good',        'Good', ...
                         'Bad',          'Bad', ...
                         'OK',           'OK', ...
                         'Interpolate',  'Interpolate', ...
                         'NotRated',     'Not Rated');
        
        extensions = struct('mat', '.mat', ...
                            'text', {'.txt', '.asc', '.csv'}, ...
                            'fif', '.fif',...
                            'set', '.set')
        
        KEYBOARD_SHORTCUTS = struct('GOOD',         {'g', '1'}, ...
                                    'OK',           {'o', '2'}, ...
                                    'BAD',          {'b', '3'}, ...
                                    'INTERPOLATE',  {'i', '4'}, ...
                                    'NOTRATED',     {'n', '5'}, ...
                                    'NEXT',         'rightarrow', ...
                                    'PREVIOUS',     'leftarrow')
                                 
        default_params = DefaultParameters
        
        default_visualisation_params = DefaultVisualisationParameters
        
        rec_params = RecommendedParameters
        
        preprocessing_constants = PreprocessingConstants
    end
    
    methods
        function self = ConstantGlobalValues
            % Checks 'DefaultParameters.m' as an example of a file in 
            % /preprocessing. Could be any other file in that folder
            if( ~ exist('DefaultParameters.m', 'file')) 
                addpath('../preprocessing/');
            end
            if( ~ exist('DefaultVisualisationParameters.m', 'file')) 
                addpath('../gui/');
            end
        end
    end
    
    methods(Static)
        function state_file = state_file()
            if ispc
                home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
                slash = '\';
            else
                home = getenv('HOME');
                slash = '/';
            end
            
            state_file = struct('NAME', 'state.mat', ...
                            'PROJECT_NAME', 'project_state.mat', ...
                            'FOLDER', [home slash 'methlab_pipeline' slash], ...
                            'ADDRESS', [home slash 'methlab_pipeline' slash 'state.mat']);
        end
    end
end
