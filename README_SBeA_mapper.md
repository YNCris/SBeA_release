# SBeA_mapper
The social behavior mapping of SBeA. In order to understand the complex 3D social behavior trajectories of multiple animals, a behavior segmentation and mapping method is required. Here, we extend our previous behavior segmentation and mapping tool "[Behavior Atlas](https://behavioratlas.tech/)" from single animal to multiple animals.
## Installation  
The SBeA_mapper is written by MATLAB, and can be run in scripts step by step.
### Configuration requirements
Tested PC:  
CPU: i9-12900K  
RAM: 128GB  
ROM: 10TB  
Operating system: Windows 11  
Software: MATLAB R2022b

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

### 2. Single animal behavior segmentation by Behavior Atlas (BeA)  
The second step is to decompose the behvior of single animal.  
Demo results:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/demo_step2.png)  
Notes:  
Panel: behavior atlas of each animal  
Color: different clusters of single animal behavior modules

Script: [SBeA_step_2_mice.m](https://github.com/YNCris/SBeA_release/blob/main/SBeA_mapper/SBeA_step_2_mice.m)  
  
Input:  
*.mat: single-animal trajectories  
*.avi: corresponding videos of single-animal trajectories  
  
Output:  
*_struct.mat:  BeA struct of single animal
 
### 3. 
Script: [SBeA_step_1.m](https://github.com/YNCris/SBeA_release/blob/main/SBeA_mapper/SBeA_step_1.m)  
  
Input:  
*id3d.mat: multi-animal trajectories with identities  
*-camera-0.avi: one camera view video  
Demo results:  
![image]()  
  
Output:
*.mat: single-animal trajectories
*.avi: corresponding videos of single-animal trajectories  
Demo results:  
![image]()  
### 4. 
Script: [SBeA_step_1.m](https://github.com/YNCris/SBeA_release/blob/main/SBeA_mapper/SBeA_step_1.m)  
  
Input:  
*id3d.mat: multi-animal trajectories with identities  
*-camera-0.avi: one camera view video  
Demo results:  
![image]()  
  
Output:
*.mat: single-animal trajectories
*.avi: corresponding videos of single-animal trajectories  
Demo results:  
![image]()  
### 5. 
Script: [SBeA_step_1.m](https://github.com/YNCris/SBeA_release/blob/main/SBeA_mapper/SBeA_step_1.m)  
  
Input:  
*id3d.mat: multi-animal trajectories with identities  
*-camera-0.avi: one camera view video  
Demo results:  
![image]()  
  
Output:
*.mat: single-animal trajectories
*.avi: corresponding videos of single-animal trajectories  
Demo results:  
![image]()  

 