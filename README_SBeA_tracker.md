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
(1) The SBeA_tracker is developed in Conda using Python. You need to prepare [Conda environment](https://www.anaconda.com/) first. 
(2) Switch to the [environment.yml](https://github.com/YNCris/SBeA_release/blob/main/SBeA_tracker/SBeA-Windows-main/environment.yml) path in Anaconda Prompt, and run   
`conda env -create -f environment.yml` to install virtual environment.   
You can change the environmental name in [environment.yml](https://github.com/YNCris/SBeA_release/blob/main/SBeA_tracker/SBeA-Windows-main/environment.yml).  
(3) Run `conda activate [your environment]`.  



Case data: [fig2_data\pose tracking](https://figshare.com/projects/Social_behavior_atlas/162718) 
## Run
### 1. Seperate multi-animal to single-animal trajectories  
The first step is a preparation of later steps.  
Demo results:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/demo_step1.png)  
Notes:  
Green line: the trajectories of animal 1  
Orange line: the trajectories of animal 2  
Trajectories: the trajectories are arranged by the order of XYZ
  
Script: [SBeA_step_1.m](https://github.com/YNCris/SBeA_release/blob/main/SBeA_mapper/SBeA_step_1.m)  
  
Input:  
*id3d.mat: multi-animal trajectories with identities  
*-camera-0.avi: one camera view video  
  
Output:  
*.mat: single-animal trajectories  
*.avi: corresponding videos of single-animal trajectories  