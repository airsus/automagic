function parts = download_and_add_paths(varargin)
% Add path and download required packages
% Note that in each of the following cases a very naive approach is taken
% to see if the library is in path or not: simply check if one of the files
% exists or not.
defaults = DefaultParameters;
p = inputParser;
addParameter(p,'prep_params', defaults.prep_params, @isstruct);
addParameter(p,'pca_params', defaults.pca_params, @isstruct);
parse(p, varargin{:});
prep_params = p.Results.prep_params;
pca_params = p.Results.pca_params;

parts = [];
if(~exist('pop_fileio', 'file'))
    parts = add_eeglab_path();
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
    
end