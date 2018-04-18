function download_asr()

% System dependence:
if(ispc)
    slash = '\';
else
    slash = '/';
end

constants = PreprocessingConstants;
asr_url = constants.asr_constants.asr_url;

ques = ['clean_artifacts.m is necessary for Artifact Subspace '...
    'Reconstruction. Do you want to download it now?'];
ques_title = 'Artifact Subspace Reconstruction Requirement installation';
if(exist('questdlg2', 'file'))
    res = questdlg2( ques , ques_title, 'No', 'Yes', 'Yes' );
else
    res = questdlg( ques , ques_title, 'No', 'Yes', 'Yes' );
end

if(strcmp(res, 'No'))
   msg = 'Preprocessing failed as ASR package is not yet installed.';
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
zip_name = [folder 'asr.zip'];  

outfilename = websave(zip_name, asr_url);
unzip(outfilename,strcat(folder, 'artifact_subspace_reconstruction/'));
addpath(genpath(strcat(folder, 'artifact_subspace_reconstruction/')));
delete(zip_name);
display(['Artifact Subspace Reconstruction package successfully installed.'...
    'Continuing preprocessing....']);
    
end