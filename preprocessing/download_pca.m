function download_pca()

% System dependence:
if(ispc)
    slash = '\';
else
    slash = '/';
end

constants = PreprocessingConstants;
pca_url = constants.pca_constants.pca_url;

ques = 'inexact_alm_rpca is necessary for PCA. Do you want to download it now?';
ques_title = 'PCA Requirement installation';
if(exist('questdlg2', 'file'))
    res = questdlg2( ques , ques_title, 'No', 'Yes', 'Yes' );
else
    res = questdlg( ques , ques_title, 'No', 'Yes', 'Yes' );
end

if(strcmp(res, 'No'))
   msg = ['Preprocessing failed as PCA package is not yet installed. '...
       'Please either install it or choose not to use PCA.'];
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
zip_name = [folder 'inexact_alm_rpca.zip'];  

outfilename = websave(zip_name,pca_url);
unzip(outfilename,folder);
addpath(genpath([folder 'inexact_alm_rpca' slash]));
delete(zip_name);
display('PCA package successfully installed. Continuing preprocessing....');
    
end