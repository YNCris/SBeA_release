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
`conda env create -f environment.yml` to install virtual environment.   
You can change the environmental name in [environment.yml](https://github.com/YNCris/SBeA_release/blob/main/SBeA_tracker/SBeA-Windows-main/environment.yml).  
(2) Run `conda activate [your environment]`.  
(3) Run `python setup.py install` to install the [DCN](https://github.com/CharlesShang/DCNv2/tree/pytorch_1.0) module.   
(4) Switch to `.\gui` path, and run `python main.py` to launch the GUI of SBeA_tracker.  
Here is the start interface of SBeA_tracker:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/start_gui.png)  



Case data:  
[fig2_data\pose tracking](https://figshare.com/projects/Social_behavior_atlas/162718) 
[fig3_data\identification\oft_50cm_id](https://figshare.com/projects/Social_behavior_atlas/162718) 
## Run
### 1. Create/load project  
SBeA_tracker is managed in a project folder. The first step is to create or load a project.  

GUI:  
 ![image](https://github.com/YNCris/SBeA_release/blob/main/demo/start_gui.png)   
  
Input:  
Create A New 'configfile.yaml'. Select a path and define a name to save your project (workspace). Or load existing 'configfile.yaml' in the first textbox.
  
Output:  
The workspace of your project.  
  
Demo results:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/create_project.png)  
Notes:  
datasets folder: save datasets  
evals folder: save model evaluation results  
models folder: save deep learning models  
configfile.yaml: the configuration of SBeA_tracker 
  
### 2. Set configurations
The second step is to set the configurations for training.  

GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/configure_gui.png)   
  
Input:  
Your path of social and ID data.
  
Output:  
Changed configfile.yaml.   
  
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

Tips:  
The changes of configurations in user interface would update to configfile.yaml automatically. If the configfile.yaml is changed manually, the program would load it in first priority.
### 3. Load, label, and train
The third step is to load data, label data, and train models according to configfile.yaml. In order to reduce the waiting time, we design the program to label data and train models in parallel. The training of models would not block the process of loading and labeling data. 

GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/load_label_train_gui.png)   
  
Input:  
The previous configurations. 
  
Output:  
The preprocessed data.  

Demo results:  
Mask box:  
Load data:  
The raw frames in .\datasets\raw_video_images  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/raw_video_images.png)  
   
The backgrounds in .\datasets\video_backgrounds  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/background.png)  
  
The trajectories in .\datasets\video_trajectories  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/trajectories.png)  
  
The manual label frames in .\datasets\manual_labels  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/manual_label_data.png)  
  
Label data:  
Label mask frames calling [labelme](https://github.com/wkentaro/labelme):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/label_frames.png)  
  
Train model:  
The well-trained data generation model in .\models\yolact  
The well-trained video instance segmentation model in .\models\vistr  
Training data generation based on [YOLACT++](https://github.com/dbolya/yolact):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/virtual_data.png) 

Well-trained video instance segmentation model based on [VisTR](https://github.com/Epiphqny/VisTR).  

Pose box:  
Load pose videos, label pose frames, and train pose estimation models calling [DeepLabCut](https://github.com/DeepLabCut/DeepLabCut):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/label_poses.png) 

ID box:  
Load data:  
Cascaded identity images in .\datasets\id_images  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/id_img_50.png)  

Train model:  
The well-trained model in .\models\reid  
Well-trained animal identification model based on [EfficientNet](https://github.com/lukemelas/EfficientNet-PyTorch). 

### 4. Evaluation (Optional)
The fourth step is to evaluate the models trained in step 3. This step includes the options to evaluate VIS models and ID models. 

GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/eval_gui.png)   
  
Input:  
The well-trained video instance segmentation model in .\models\vistr  
The well-trained ID model in .\models\reid  
Optional:
The ground truth video isntance segmentation data to evaluate model by GT.
The config.yaml file of pose estimation to evaluate the feature of identification.
  
Output:  
The evaluation results of VIS model in .\evals\checkpoint*
The evaluation results of ID model in .\evals\reidmodel*

Demo results:  
The evaluation of VIS model:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/eval_no_gt.png)   
Notes:  
result.json: raw results of video instance segmentation for evaluation data  
corrected_result.json: corrected results of video instance segmentation by interframe continuity  
*.avi: visualization of each evaluation video
  
The evaluation of VIS model with ground truth:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/eval_gt.png)  
Notes:  
result.json: raw results of video instance segmentation for evaluation data  
eval.json: the performance of VIS model include IST (identity swap time), IST_P (identity swap time percentage), IOU_NID (Intersection over Union without considering ID), IOU_ID (Intersection over Union considering ID), AP_NID/ID_50/70/90 (mean average precision with/without considering ID with IOU larger than 50/70/90)  
*.avi: visualization of each evaluation video
  
The evaluation of ID model:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/feature.png)   
Notes:  
cam folder: folder saves LayerCAM results.   
confusion_matrix.jpg: confusion matrix of identities  
pca_representations.jpg: PCA to visualize the feature representation of ID models  
tsne_representations.jpg: t-SNE to visualize the feature representation of ID models  
  
The evaluation of ID features using [LayerCAM](https://github.com/PengtaoJiang/LayerCAM-jittor):  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/cam.png)   
  
### 5. Predict
The fifth step is to predict 3D poses with identities of new videos.

GUI:   
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/pred_gui.png)   
  
Input:  
New videos and calibration files like step 1.
  
Output:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/final_output.png)  
Notes:  
*-rawresult.json: raw results of video instance segmentation  
*-correctedresult.json: corrected results of video instance segmentation by interframe continuity  
*-predid.csv: raw file of identities predicted by SBeA  
*-corrpredid.csv: corrected ID file by continuity  
*-raw3d.mat: raw 3D skeletons of two animals without identities  
*-rot3d.mat: 3D skeletons rotated to ground (world coordinate system) without identities  
*-id3d.mat: 3D skeletons rotated to ground with identities  

The result visualization can be find in [README.md](https://github.com/YNCris/SBeA_release/blob/main/README.md)
