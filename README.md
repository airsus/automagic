# Automagic

![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/automagic.jpg)

## What is Automagic ?

![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/main_gui.png)

## 1. Setup

### 1.1. System Requirements
You need MATLAB installed and activated on your system to use *Automagic*. *Automagic* was developed and tested in MATLAB R2015b and newer releases.

### 1.2. How to start

There are three different ways of using the application.

1. The easiest and recommended way is to simply install the application from the app installer file *automagic.mlappinstall*. Please see [GUI Manual](#2-gui-manual)
2. You can also use the preprocessing files independent from the gui. See [Application structure](#3-application-structure) and [How to run the app from the code](#4-how-to-run-the-application-from-the-code)  
3. Or if you wish to make any modifications to any part of the application, be it the gui or the preprocessing part, you can run the application from the code instead of the installer file.  See [Application structure](#3-application-structure) and [How to run the app from the code](#4-how-to-run-the-application-from-the-code)  


## 2. GUI Manual 

### 2.1. Setup

#### 2.1.1. System Requirements
You need MATLAB installed and activated on your system to use *Automagic*. *Automagic* was developed and tested in MATLAB R2015b and newer releases.

#### 2.1.2. Installation
1. Download the *Automagic EEG Toolbox* to a folder of your choice. 
2. Navigate to *gui/* folder
3. Double click the file named *Automagic* or *Automagic.mlappinstall*. Wait until MATLAB displays a dialogue box.
4. Please select Install. You will be notified as soon as the installation is complete.

#### 2.1.3. How to Run Automagic
1. Start MATLAB. 
2. Select the APPS tab. 
3. Click on the Automagic icon. You might have to expand the APPS tab to see the *Automagic* icon by clicking the small triangle pointing down on the far right of the APPS tab.

### 2.2. Basic Workflow
In this section of the manual, only the basic functionality of Automagic will be explained. This covers the basic workflow from selecting a project to rating the data. Please refer to chapters 3 to 6 for detailed information all functions within the main GUI.

1. [Create a new project or load an existing project](#231-creating-a-new-project).
2. [Preprocess the data](#24-the-pre-processing-panel).
3. [Rate data and manually select bad channels if any](#25-the-manual-rating-panel).
4. [Interpolate all manually selected channels] (#26-the-interpolation-panel).
5. Repeat steps 3 and 4 until all data is rated.
 * NOTE: You can not close the main gui window during the preprocessing. If you wish to stop the preprocessing at any time, you can use *CTRL-C*. In this case, or if by any other reason the preprocessing is stopped before being completely finished, all preprocessed files to that moment will be saved, and you can resume the preprocessing only for the files which are not preprocessed yet. 

* Important:	Since synchronisation is rather basic, people should never work on the same project simultaneously.

### 2.3. The Project Panel

![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/project_panel.png)

#### 2.3.1. Creating a New Project
1. Navigate to the drop-down list labelled *Select Project*.
2. Select *Create New Project...*
3. Name your project.
4. Write down the file extension that corresponds to your data’s file format. For example raw image files (.raw or .RAW), fractal image files (.fif) or generic data files (.dat).
5. Choose the EEG System in which your data is recorded. Currently only EGI HCGSN is fully supported for both number of channels 128 and 256 (or 129 and 257 respectively). This information is needed mainly to find channel locations. In case you choose the option 'Other' for your EEG System, you must provide a file in which channel locations are specified. The file format must be one which is also supported by EEG lab (pop_chanedit function). In addition, you must provide a list of indices of the EOG channels of your dataset. Note that here the list contains the indices of those channels and not their labels.
 * The *Channel location file* must be the entire name of the file, which must be located in the folder '/matlab_scripts'
 * The *Channel location file type* must specify the type of the file as required by pop_chanedit. eg. sfp
 * The list of EOG channels must be integers seperated by space or comma, e.g. 1 32 8 14 17 21 25 125 126 127 128
 * Please note that in case you choose 'Other' as your EEG system, no reduction in number of channels is supported.
 * ICA is supported for 'Other' only in case your channel labels are as it is required by processMARA. They must be of the form FPz, F3, Fz, F4, Cz, Oz, etc. Otherwise the ICA is simply skipped. If only some of your labels have the required format, only those channels are considered for ICA. For more information please see 
6. Set the downsampling rate on the manual rating panel. The downsampling only affects the visual representation of your data. A higher downsampling rate will shorten loading times. In general, a downsampling rate of 2 is a good choice. 
 * Important:	You cannot alter paths, the filtering, or the downsampling rate after creating your project.
7. Specify the path of your data folder. *Automagic* will scan all folders in your data folder for data files. Files and folders in the data folder will not be altered by *Automagic*.
 * Important: 	The data folder must contain a folder for each subject (subject folders). Your data folder should not contain any other kinds of folders since this will lead to a wrong number of subjects. 
8. Specify the path of your project folder. If the specified folder does not yet exist, *Automagic* will create it for you. *Automagic* will save all processed data to your project folder. By default, *Automagic* opts for your data folder’s path and adds *_results* to your data folder’s name, e.g. *\PathDataFolder\MyDataFolder_results\*
 * Important:	A subject folder must contain EEG files. Automagic can only load data saved in subject folders. Since subject folders are defined as folders in the data folder, no specific naming is required.
 
 ![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/folder_structure.png)
 
9. Specify the path of the folder where you wish to store the results of preprocessing. *Automagic* will save all processed data to your project folder. If the specified folder does not exist yet, *Automagic* will create it for you. By default, *Automagic* opts for your data folder’s path and adds *_results* to your data folder’s name, e.g. *\PathDataFolder\MyDataFolder_results\*
10. Choose your filtering parameters in the Filtering panel. 
 * Notch Filter: Choose US if your data was recorded in adherence to US standards (60 Hz). Chose EU if your data was recorded in adherence to EU standards (50 Hz).
 * By default a High pass filtering is performed on data. You can change the freuqency or simply uncheck the High pass filtering. You can also choose to have a Low pass filtering. Bu default there is no Low pass filtering.
11. [By clicking on the *Configurations...*](#237-customize-settings) button you can modify additional optional parameters of the preprocessing. This is not necessary, and you can leave it so that the default values are used.
12. Click on *Create New* in the lower right corner of the project panel to create your new project. If the specified data and project folders do not yet exist, *Automagic* will now create them for you.

#### 2.3.2. Loading an Existing Project
There are two options to load an existing project. The first option can only be used to open projects that have been created on your system or that have been loaded before:

1. Navigate to the drop-down list labelled *Select Project*.
2. Select the project you want to load.

The second option can be used to load any *Automagic* project:

1. Navigate to the drop-down list labelled *Select Project*.
2. Select *Load an existing project...*
3. A browser window will open. Navigate to the existing project...s project folder.
4. Select and open the file named *project_state.mat*

#### 2.3.3. Merging Projects
To merge any number of existing projects without losing the individual projects, please follow these steps:

1. Create a new data folder using Finder (Mac), Explorer (Windows) or your Linux equivalent.
2. Create a new project folder using Finder (Mac), Explorer (Windows) or your Linux equivalent.
3. For all the projects that you want to merge: Copy the contents from the data and project folders to the new data and project folders.
 * Important: 	Each of your existing project folders contains a file named project_state.mat. Do not copy these files to your new project folder.
4. In *Automagic*: Create a new project using the newly created data and project folders.

#### 2.3.4. Adding Data to an Existing Project
1. Add subject folders to your data folder using Finder (Mac), Explorer (Windows) or your Linux equivalent.
2. Refresh the *Automagic* GUI using one of these options:
 * Start or restart Automagic.
 * Navigate to the drop-down list labelled Select Project and load (or reload) the project containing new data by clicking on its name.
3. The number of subjects and files in both the project panel and the pre-processing panel should now be updated.

#### 2.3.5. Deleting Data from an Existing Project
1. Delete subject folders from your data folder using Finder (Mac), Explorer (Windows) or your Linux equivalent.
2. Refresh the *Automagic* GUI using one of these options:
 * Start or restart Automagic.
 * Navigate to the drop-down list labelled Select Project and load (or reload) the project containing new data by clicking on its name.
3. The number of subjects and files in both the project panel and the pre-processing panel should now be updated.

#### 2.3.6. Deleting a Project
1. Click on *Delete Project* in the lower right corner of the project panel. A dialog box will appear.
2. Take responsibility by clicking on Delete.
 * Important: 	This will only delete the file named project_state.mat in the project folder and remove the project from the Automagic GUI. Please use Finder (Mac), Explorer (Windows) or your Linux equivalent to delete your project data and/or project folder.

#### 2.3.7. Customize Settings
![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/settings.png)

After clicking on *Configurations...* button a new window is opened where you can customize preprocessing steps:

1. If *Reduce number of channels* is checked, then before preprocessing number of channgels is reduced. [Click here](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/reduced_channels.txt) to see list of channels selected. In case you choose *Other* as your EEG System in the *main_gui* then this element is deactivated: not channel reduction is supported for other EEG Systems. 
2. In the *Filtering* section you can choose the order of the filtering. The default value corresponds to the default value computed by *pop_eegfiltnew.m*.
3. In the *Channel rejection criterias* you can select or deselect the three different criterias *Kurtosis*, *Probability* and *Spectrum* to reject channels (See *pop_rejchan.m*). The corresponding thresholds can also be customized.
4. *EOG Regression* can be deselected.
5. *ICA* can be selected or deselected. Note that ICA and PCA can not be chosen together at the same time. The ICA uses the algorithm in MARA extension of MATLAB.
6. *PCA* can be selected or deselected. The parameters correspond to paramters of *inexact_alm_rpca.m*. The default value *lambda* is ![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/sqrt.jpg) where m is the number of channels.
7. The mode of interpolation can be determined. The default value is *spherical*.


### 2.4. The Pre-Processing Panel
 * Important:	The filtering can only be set during project creation.
Click on Run to start the pre-processing of your data. This is the first thing you should do after creating a new project or after adding data to an existing project. Pre-processing includes filtering, detection of bad channels, EOG regression, PCA, and automatic interpolation.

Should the project folder already contain files (i.e. should some of the projects data already have been pre-processed), you will be able to choose whether existing files will be overwritten or skipped after clicking on Run. 
* Important:	Please wait until all files have been pre-processed before doing anything else in this instance of MATLAB.

### 2.5. The Manual Rating Panel

![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/rating_gui.png)


 * Important:	 The downsampling rate can only be set during project creation.
Click on *Start...* to open the rating GUI.
 * Important: 	Only pre-processed files can be rated manually.
 
A visualisation of the currently selected file is displayed. Time corresponds to the x-axis, EEG channels correspond to the y-axis. You can use the tools in the top left corner to e.g. magnify an area or select a specific point of the current visualisation. Use the filters right below the tools to focus on a subset of your files based on their rating. You can navigate between files of the current subset by clicking on *Previous* and *Next* or by selecting a file from the drop-down list in the top right corner.

You can rate the quality of the visualised data on the very right. You can choose between **Good**, **OK**, and **Bad**. These ratings are subjective and relative rather than absolute: The overall quality of your data should be used as point of reference. The colouring allows you to rate the quality of your data: Ideally, everything is green. Darker colours signify lower quality, i.e. artifacts etc. As a rule of thumb, horizontal artifacts are worse than vertical artifacts of the same size and colouring. After choosing a rating, you will automatically proceed to the next file.

Should you spot bad channels (represented by horizontal lines which are darker than their surroundings), please select **Interpolate**. This will activate selection mode. Manually navigate to bad channels and select them by clicking on them. Click on *Turn off* after selecting all bad channels. Click on Next to proceed to the next file. You will be able to rate these files after interpolating all selected channels. 
* Important: 	Manual rating can be interrupted anytime by closing the rating GUI. No data will be lost and you can resume rating later.

### 2.6. The Interpolation Panel
1. Click on *Interpolate All* to interpolate all channels you selected during manual rating.
 * Important: 	Wait until all channels have been interpolated before doing anything else in this instance of MATLAB.
2. Refresh the *Automagic* GUI using one of these options:
 * Start or restart Automagic.
 * Navigate to the drop-down list labelled *Select Project* and load (or reload) the project containing new data by clicking on its name.
3. Manually rate the files that contained bad channels. 
 * Important:	You can select and interpolate bad channels as often as you want in each file.



## 3. Application Structure

There are three main folders: 

1. **preprocessing**
 This folder contains all relevant files of preprocessing step. The folder is standalone and can be used independent from the entire application. The main function to be called is *pre_process.m* which as argument needs the raw data loaded by *pop_fileio* function of *eeglab*, the address of that file and the preprocessing parameters (See documations, ie. pre_process.m). For more information on how to run the code the without installer please see  [How to run the app from the code](#4-how-to-run-the-application-from-the-code).

2. **gui**
 This folder contains files created by *MATLAB GUIDE*. All call-back operations related to the gui are implemented here.
 1. *main\_gui.m* is the main function of the project which must be started to run the application.
 2. *rating\_gui.m* is the gui that can be started within the *main\_gui.m* and is used to rate subjects and files.
 3. *settings.m* is the gui corresponsing to configuration button on the main gui. It allows to customize the preprocessing steps.
 4. *Automagic.mlappinstall* which is the app installer mentionned in [Installation](#2-1-2-Installation) section.

3. **src**
 This folder contains all other files that are called by the guis:
 1. *Project.m*, *Subject.m* and *Block.m* are classes representing a project created in the gui and its corresponding subjects and the raw files of each subject, respectievly.
4. **matlab_scripts** 
    This folder (must) contain all external files from *eeg_lab* and other libraries.

## 4. How to run the application from the code
For this code to be able to run, functions from [*eeglab*](https://sccn.ucsd.edu/eeglab/),  [*Augmented Lagrange Multiplier (ALM) Method*](http://perception.csl.illinois.edu/matrix-rank/sample_code.html) and [*fieldtrip*](http://www.fieldtriptoolbox.org) are needed to be on your path:

1. Download the [*eeglab*](https://sccn.ucsd.edu/eeglab/downloadtoolbox.php) library and put them in the *matlab_scripts* folder.
2. Download the  *inexact ALM* ( containing the function *[A, E] = inexact_alm_rpca(D, λ)*) from [*(ALM) Method*](http://perception.csl.illinois.edu/matrix-rank/sample_code.html) and put it in the *matlab_scripts* as well. 
3. Download the [*fieldtrip*](http://www.fieldtriptoolbox.org/download) which is an *eeglab* extension and put it in *matlab_scripts/eeglab13_6_5b/plugins/*.
4. Now you are able to run the code by running the *gui/main_gui.m*


Note that you can modify anything in the code if you want and change all files and folder structures including matlab paths. 


## Contact us
You can find us [here](http://www.psychologie.uzh.ch/de/fachrichtungen/plafor.html).
If you have any questions, feedbacks please email us at amirreza [dot] bahreini [at] uzh [dot] ch
