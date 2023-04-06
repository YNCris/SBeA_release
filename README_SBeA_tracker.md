# SBeA_tracker
The social behavior tracking of SBeA. Using SBeA_tracker, the multi-animal 3D poses with identities can be acquired.
### Configuration requirements
Tested PC:  
CPU: i9-12900K  
RAM: 128GB  
ROM: 10TB  
Operating system: Windows 11  
Software: [Anaconda](https://www.anaconda.com/) and [Visual Studio](https://visualstudio.microsoft.com/)
## Installation  
(1) Switch to the [environment.yml](https://github.com/YNCris/SBeA_release/blob/main/SBeA_tracker/SBeA-Windows-main/environment.yml) path in Anaconda Prompt, and run   
`conda env -create -f environment.yml` to install virtual environment.   
You can change the environmental name in [environment.yml](https://github.com/YNCris/SBeA_release/blob/main/SBeA_tracker/SBeA-Windows-main/environment.yml).  
(2) Run `conda activate [your environment]`.  
(3) Run `python setup.py install` to install the [DCN](https://github.com/CharlesShang/DCNv2/tree/pytorch_1.0) module.   
(4) Switch to `.\gui` path, and run `python main.py` to launch the GUI of SBeA_tracker.  
Here is the start interface of SBeA_tracker:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/tracker_gui.png)  



Case data: [fig2_data\pose tracking](https://figshare.com/projects/Social_behavior_atlas/162718) 
## Run
### 1. Create/load project  
SBeA_tracker is managed in a project folder. The first step is to create or load a project.  
Demo results:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/create_project.png)  
Notes:  
datasets folder: save datasets  
evals folder: save model evaluation results  
models folder: save deep learning models  
configfile.yaml: the configuration of SBeA_tracker 
  
GUI:  
 ![image](https://github.com/YNCris/SBeA_release/blob/main/demo/tracker_gui.png)   
  
Input:  
Create A New 'configfile.yaml'. Select a path and define a name to save your project (workspace). Or load existing 'configfile.yaml' in the first textbox.
  
Output:  
The workspace of your project.

### 2. Set configurations
The second step is to set the configurations for training.  
  
Your data need to be organized like:  
Social data:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/data_format.png)  
Notes:  
*-caliParas.mat: the calibration file  
*-camera-#.avi: the multi-view videos of number # camera  
Fields F1-F2-F3:  
F1: the recording serial number  
F2: the animal name such as A1 (animal one) and A2 (animal two)  
F3: the date
  
ID data:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/data_format_id.png)  
Notes:  
*-caliParas.mat: the calibration file  
*-camera-#.avi: the multi-view videos of number # camera  
Fields F1-F2-F3:  
F1: the recording serial number  
F2: the single animal name such as A1 (animal one)
F3: the date

GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/config_gui.png)   
  
Input:  
Your path of social and ID data.
  
Output:  
Changed configfile.yaml. 

### 3. Load data
The third step is to load data according to configfile.yaml. If the train and ID data are not in the path in step 2, this part is going to copy them in these folders. Additionally, the raw frames, trajectories, backgrounds, and frames for labeling are extracted in this step. If the train and ID data are existing in these folders, you only need to run load train videos without filling any testbox. 

Demo results:  
The raw frames in .\datasets\raw_video_images  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/raw_video_images.png)  
Notes:  
datasets folder: save datasets  
evals folder: save model evaluation results  
models folder: save deep learning models  
configfile.yaml: the configuration of SBeA_tracker 
   
The raw frames in .\datasets\video_backgrounds  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/background.png)  
Notes:  
datasets folder: save datasets  
evals folder: save model evaluation results  
models folder: save deep learning models  
configfile.yaml: the configuration of SBeA_tracker 
  
The raw frames in .\datasets\video_trajectories  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/trajectories.png)  
Notes:  
datasets folder: save datasets  
evals folder: save model evaluation results  
models folder: save deep learning models  
configfile.yaml: the configuration of SBeA_tracker 
  
The raw frames in .\datasets\manual_labels  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/manual_label_data.png)  
Notes:  
datasets folder: save datasets  
evals folder: save model evaluation results  
models folder: save deep learning models  
configfile.yaml: the configuration of SBeA_tracker 
  
GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/load_gui.png)   
  
Input:  
Your path of social and ID data.
  
Output:  
Changed configfile.yaml.