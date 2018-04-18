function download_rar()

% System dependence:
if(ispc)
    slash = '\';
else
    slash = '/';
end

constants = PreprocessingConstants;
rar_url = constants.prep_constants.rar_url;

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
zip_name = [folder 'VisLab-EEG-Clean-Tools.zip'];  

outfilename = websave(zip_name, rar_url);
unzip(outfilename,strcat(folder, 'VisLab-EEG-Clean-Tools/'));
addpath(genpath(strcat(folder, 'VisLab-EEG-Clean-Tools/')));
delete(zip_name);
display(['Robust Average Referencing package successfully installed.'...
    ' Continuing preprocessing....']);
    
end