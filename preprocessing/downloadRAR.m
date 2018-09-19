function downloadRAR()
% downloadRAR  Download the Prep (Robust Average Referencing) package
%   It asks the user whether they want to download the package or not. If
%   not, the preprocessing is stopped. Otherwise, in a first attepmt, the
%   folder matlab_scripts in the parent directory is selected to download
%   the package into it. If the folder does not exist, the user is asked to
%   select a folder in which the package will be downloaded.
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
% along with this program.  If not, see <http://www.gnu.org/licenses/>

% System dependence:
if(ispc)
    slash = '\';
else
    slash = '/';
end

CSTS = PreprocessingConstants;
RAR_URL = CSTS.PrepCsts.RAR_URL;

% Ask user if they want to download the package now
ques = ['performReference.m is necessary for Robust Average Referencing.'...
    ' Do you want to download it now?'];
ques_title = 'Robust Average Referencing Requirement installation';
if(exist('questdlg2', 'file'))
    res = questdlg2( ques , ques_title, 'No', 'Yes', 'Yes' );
else
    res = questdlg( ques , ques_title, 'No', 'Yes', 'Yes' );
end

if(strcmp(res, 'No'))
   msg = ['Preprocessing failed as RAR package is not yet installed.'...
       ' Please either isntall it or choose not to use RAR.'];
    if(exist('warndlg2', 'file'))
        warndlg2(msg);
    else
        warndlg(msg);
    end
    return; 
end

% Choose the folder in which the package gets downloaded
folder = pwd;
if(regexp(folder, 'gui'))
    folder = ['..' slash 'matlab_scripts' slash];
elseif(regexp(folder, 'eeglab'))
    folder = ['plugins' slash 'automagic' slash 'matlab_scripts' slash];
else
  while(isempty(regexp(folder, 'gui', 'once')) && ...
        isempty(regexp(folder, 'eeglab', 'once')))

    msg = ['For the installation, please choose the root folder of the'...
        ' EEGLAB: your_path/eeglab or the gui folder of the automagic: '...
        'your_path/automagic/gui/'];
    if(exist('warndlg2', 'file'))
        warndlg2(msg);
    else
        warndlg(msg);
    end
    folder = uigetdir(pwd, msg);

    if(isempty(folder))
        return;
    end

  end
end

% Download the package
zip_name = [folder 'VisLab-EEG-Clean-Tools.zip'];  
outfilename = websave(zip_name, RAR_URL);
unzip(outfilename,strcat(folder, 'VisLab-EEG-Clean-Tools/'));
addpath(genpath(strcat(folder, 'VisLab-EEG-Clean-Tools/')));
delete(zip_name);
fprintf(['Robust Average Referencing package successfully installed.'...
    ' Continuing preprocessing....']);
    
end