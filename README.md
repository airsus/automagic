# Automagic

![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/automagic.jpg)

## What is Automagic ?

**Automagic** is a MATLAB based toolbox for preprocessing of EEG-datasets. First, the toolbox *automagically* detects channels with artifacts (e.g. eye movements, noisy electrodes, etc.) from your raw EEG-data. In a second step, **Automagic** lets you check visually the entire dataset while indicating the detected channels. You will be able to select and interpolate these channels in an efficient way. Furthermore, you can rate the quality of individual EEG-files.

![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/main_gui.png)

## 1. Setup

You need MATLAB installed and activated on your system to use **Automagic**. **Automagic** was developed and tested in MATLAB R2015b and newer releases.

There are four different ways of using the application.

1. The easiest and recommended way is to simply install the application from the [app installer](http://www.psychologie.uzh.ch/de/bereiche/nec/plafor/automagic.html) file. This is the stable version. For more information please see [GUI Manual](http://www.psychologie.uzh.ch/de/bereiche/nec/plafor/automagic.html)
2. Automagic is also available as an **EEGLab** extension and you can use it to preprocess data loaded by **EEGLab** gui. See [Automagic as EEGLab extension](#2-automagic-as-eeglab-extension)
3. You can also use the preprocessing files independent from the gui. See [Application structure](#3-application-structure) and [How to run the app from the code](#4-how-to-run-the-application-from-the-code)  
4. Or if you wish to make any modifications to any part of the application, be it the gui or the preprocessing part, you can run the application from the code instead of the installer file. This version has always the latest modifications. See [Application structure](#3-application-structure) and [How to run the app from the code](#4-how-to-run-the-application-from-the-code)  
 
 * **Important**: Only the [app installer](http://www.psychologie.uzh.ch/de/bereiche/nec/plafor/automagic.html) contains the *stable version* of the **Automagic**. Github code has the most recent changes and may contain some bugs.
  
 
## 2. Automagic as EEGLab extension

![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/eeglab.png)

You can also run **Automagic** as an EEGLab [extension](https://sccn.ucsd.edu/wiki/EEGLAB_Extensions_and_plug-ins). To do so, you need to simply put the `automagic/` folder in the `eeglab_[your-version]/plugins/` folder. 
After this being done, on start-up, **EEGLab** will create a new menu item for **Automagic**. This menu item will have three sub-menus, each of which corresponding to the earlier explained steps of preprocessing: 
1. *Start Processing...* which corresponds to preprocessing the data.
2. *Start Manual Rating...* which corresponds to manual rating of bad channels.
3. *Start Interpolation...* which corresponds to interpolation of all manually selected channels.

The behaviour of the the second and third step is exactly as explained in [GUI Manual](http://www.psychologie.uzh.ch/de/bereiche/nec/plafor/automagic.html). The only difference happens for the first step where you can preprocess only the currently selected EEG structure instead of the list of all of your EEG structures loaded in **EEGLab**.

Also please note that, when using **EEGLab**, there is no more the notion of having projects, or creating a new project,etc. In this case, you simply load your data from within **EEGLab**, preprocess, rate and interpolate them, and all the results are given back in `ALLEEG` structure of the **EEGLab**. From there you may want to save your result yourself.

   * Note: In order to be able to start the preprocessing, you must first add the channel locations to your EEG data strucutre. For more information please see **EEGLab** documentation on this.

## 3. Application Structure

There are four main folders (in total 6 folders): 

1. **`automagic/preprocessing/`**
 This folder contains all relevant files of preprocessing step (with no GUIs). The folder is standalone and can be used independent from the entire application. The main function to be called is `preprocess.m` which needs two arguments. The first argument is the EEG data structure loaded by `pop_fileio.m` function (or a similar function) of **EEGLab** and the second argument is preprocessing parameters (see documations, ie. `preprocess.m` to learn about the second argument). The first ouput of `preprocess.m` is an EEG data structure similar to the input EEG structure, where the `EEG.data` field has the preprocessed results. This EEG data streucture has some new fields like the parameters used for preprocessing and channels that have been interpolated by automatic detection. The second output is a figure showing the effects of preprocessing. For more information on how to run the code without installer please see  [How to run the app from the code](#4-how-to-run-the-application-from-the-code).
2. **`automagic/gui/`**
 This folder contains files created by *MATLAB GUIDE*. All callback operations related to the gui are implemented here.
   1. `main_gui.m` is the main function of the project which must be started to run the application.
   2. `rating_gui.m` is the gui that is accessed from within the `main_gui.m` and is used to rate subjects and files. You don't need to use this function directly.
   3. `settings.m` is the gui corresponsing to configuration button on the main gui. It allows to customize the preprocessing steps. Again you don't need to run this file directly.
3. **`automagic/src/`**
 This folder contains all source files regarding the entire structure of the application:
   * `Project.m`, `Subject.m` and `Block.m` are classes representing a project created in the gui, its corresponding subjects and the raw files of each subject, respectievly. `ConstantGlobalValues.m` contains constant variables used throughout the application to avoid duplications.
4. **`eeglab_plugin/`**
 This folder contains necessary files to integrate **Automagic** as an **EEGLab** extension. There are corresponding `pop_` functions and equivalent functions of `automagic/src/` for the plugin. The structure is very similar to `automagic/src/`.
 
5. `matlab_scripts/` 
    This folder (must) contain all external files from **EEGLab** and other libraries.
    
6. `automagic_resources`
    Contains few images and icons for the readme, etc.

## 4. How to run the application from the code
You can also run **Automagic** without using the installer. A clear reason to do so is to make your own modifications to the code and then run it.

For this code to be able to run, functions from [**EEGLab**](https://sccn.ucsd.edu/eeglab/) and  [**Augmented Lagrange Multiplier (ALM) Method**](http://perception.csl.illinois.edu/matrix-rank/sample_code.html) are needed to be on your path:

1. Download the [**EEGLab**](https://sccn.ucsd.edu/eeglab/downloadtoolbox.php) library and put it in the `automagic/matlab_scripts` folder.
2. Download the  **inexact ALM** ( containing the function `[A, E] = inexact_alm_rpca(D, ??)`) from [**(ALM) Method**](http://perception.csl.illinois.edu/matrix-rank/sample_code.html) and put it in the `automagic/matlab_scripts/` as well.
    * Good News!: If you feel too lazy to download this extension and put it in  `automagic/matlab_scripts/`, **don't**. While using **Automagic**, if you choose to use PCA in preprocessing, you will be asked if you agree to download the package, if you answer *Yes*, the package will be downloaded *Automagically* in the right folder. Note that this feature is not yet implemented for the previous step, **EEGLab**. 
3. Download the  **Artefact Subspace Reconstruction** from EEGLAB Extensions and put it in the `automagic/matlab_scripts/` as well.
    * Again if you feel too lazy to download this extension and put it in  `automagic/matlab_scripts/`, **don't**.  **Automagic** can download the package itself while using it in the same way as explained in the previous step.
4. Now you are able to run the code by running the `automagic/gui/main_gui.m`

  * Note that other possible packages will be also downloaded automatically in case they are needed for the preprocessing. For example if you choose to use **Robust Average Referencing**, the package will be downloaded at the beginning of the preprocessing.


* NOTE: If your data is with `.fif` extension, you need to download [**fieldtrip**](http://www.fieldtriptoolbox.org/download) which is an **EEGLab** extension and put it in `matlab_scripts/eeglab13_6_5b/plugins/`.

Note that you can modify anything in the code if you want and change all files and folder structures including matlab paths. 


## Contact us
You can find us [here](http://www.psychologie.uzh.ch/de/fachrichtungen/plafor.html).
If you have any questions, feedbacks please email us at amirreza [dot] bahreini [at] uzh [dot] ch
