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



Case data:  
[fig2_data\pose tracking](https://figshare.com/projects/Social_behavior_atlas/162718) 
[fig3_data\identification\oft_50cm_id](https://figshare.com/projects/Social_behavior_atlas/162718) 
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
   
The backgrounds in .\datasets\video_backgrounds  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/background.png)  
  
The trajectories in .\datasets\video_trajectories  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/trajectories.png)  
  
The manual label frames in .\datasets\manual_labels  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/manual_label_data.png)  
  
GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/load_gui.png)   
  
Input:  
Social and ID data.
  
Output:  
The preprocessed data.

### 4. Label and train
The fourth step is to label frames and train models. In this part, you can label frames and train models in parallel, which save the running time.

Demo results:  
Label mask frames calling [labelme](https://github.com/wkentaro/labelme):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/label_frames.png)  

Label pose frames calling [DeepLabCut](https://github.com/DeepLabCut/DeepLabCut):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/label_poses.png) 

Training data generation based on [YOLACT++](https://github.com/dbolya/yolact):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/virtual_data.png) 
   
GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/labeltrain_gui.png)   
  
Input:  
The frame data extracted by step 2 for mask label.  
The identity data for pose annotation.  
The label frame data, backgrounds and trajectories for training data generation.
  
Output:  
Well-trained video instance segmentation model based on [VisTR](https://github.com/Epiphqny/VisTR).  
Well-trained single animal pose estimation model. 
Well-trained animal identification model based on [EfficientNet](https://github.com/lukemelas/EfficientNet-PyTorch). 

### 4. Evaluation (Optional)
The fourth step is to label frames and train models. In this part, you can label frames and train models in parallel, which save the running time.

Demo results:  
Label mask frames calling [labelme](https://github.com/wkentaro/labelme):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/label_frames.png)  

Label pose frames calling [DeepLabCut](https://github.com/DeepLabCut/DeepLabCut):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/label_poses.png) 

Training data generation based on [YOLACT++](https://github.com/dbolya/yolact):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/virtual_data.png) 
   
GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/labeltrain_gui.png)   
  
Input:  
The frame data extracted by step 2 for mask label.  
The identity data for pose annotation and identification model training.  
The label frame data, backgrounds and trajectories for training data generation.
  
Output:  
Well-trained video instance segmentation model based on [VisTR](https://github.com/Epiphqny/VisTR).  
Well-trained single animal pose estimation model. 
Well-trained animal identification model based on [EfficientNet](https://github.com/lukemelas/EfficientNet-PyTorch). 

### 5. Predict
The fifth step is to predict 3D poses with identities of new videos.

Demo results:  
Output files:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/final_output.png)  
Notes:  
*-rawresult.json: raw results of video instance segmentation  
*-correctedresult.json: corrected results of video instance segmentation by interframe continuity  
*-predid.csv: raw file of identities predicted by SBeA  
*-corrpredid.csv: corrected ID file by continuity  
*-raw3d.mat: raw 3D skeletons of two animals without identities  
*-rot3d.mat: 3D skeletons rotated to ground (world coordinate system) without identities  
*-id3d.mat: 3D skeletons rotated to ground with identities  

GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/prediction_gui.png)   
  
Input:  
The frame data extracted by step 2 for mask label.  
The identity data for pose annotation and identification model training.  
The label frame data, backgrounds and trajectories for training data generation.
  
Output:  
Well-trained video instance segmentation model based on [VisTR](https://github.com/Epiphqny/VisTR).  
Well-trained single animal pose estimation model. 
Well-trained animal identification model based on [EfficientNet](https://github.com/lukemelas/EfficientNet-PyTorch). 