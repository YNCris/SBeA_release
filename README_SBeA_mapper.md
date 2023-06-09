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
Typical time: ~10 seconds per data  

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
Typical time: ~10 minutes per data  
 
### 3. Multiple animal social behavior segmentation
The third step is to segment social behavior.  
Demo results:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/demo_step3.png)  
Notes:  
Green line: the trajectories of animal 1  
Orange line: the trajectories of animal 2  
Trajectories: the trajectories are arranged by the order of [X_nose,X_left_ear,...,Y_nose,Y_left_ear,...,Z_nose,Z_left_ear...]  
NM: the decomposition of non-locomotor movement  
L: the decomposition of locomotion  
D: the decomposition of distance  
All: merge segmentations  
  
Script: [SBeA_step_3.m](https://github.com/YNCris/SBeA_release/blob/main/SBeA_mapper/SBeA_step_3.m)  
  
Input:  
*_struct.mat:  BeA struct of single animal
  
Output:  
*_social_struct.mat:  SBeA struct of social behaviors  
Typical time: ~30 minutes per data  

### 4. Social behavior clustering
The fourth step is to map and cluster all the social behavior modules across different videos under the same metric in the same low dimensional space.  
Demo results:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/demo_step4.png)  
Notes:  
Left: feature matrix of all social behavior modules  
Center: social behavior atlas with upper boundary clusters (gray line) and lower boundary clusters (Different color of dots)  
Right: distance map of social behavior atlas
  
Script: [SBeA_step_4.m](https://github.com/YNCris/SBeA_release/blob/main/SBeA_mapper/SBeA_step_4.m)  
  
Input:  
*_social_struct.mat:  SBeA struct of social behaviors
  
Output:  
*data_sample_cell.mat: all of the segmentation data of social_struct used for clustering  
*dist_mat_all.mat: the feature matrix  
*wc_struct.mat: the adaptive watershed clustering results  
Typical time: ~10 hours 

### 5. Group analysis (optional)
The fifth step is to analyze the fractions of each social behavior modules.  
Demo results:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/demo_step5.png)  
Notes:  
Left top: the fraction matrix with lower classes  
Left bottom: the fraction matrix with upper classes   
Right: phenotype space of social groups
  
Script: [SBeA_step_5_group_analysis.m](https://github.com/YNCris/SBeA_release/blob/main/SBeA_mapper/SBeA_step_5_group_analysis.m)  
  
Input:  
*data_sample_cell.mat: all of the segmentation data of social_struct used for clustering  
  
Output:  
*fractions_little.mat: the social behavior module fractions of each group with lower boundary of clustering  
*fractions_much.mat: the social behavior module fractions of each group with upper boundary of clustering   
*sort_group_names.mat: name information of social groups  
*LDE.mat: phenotype space of different groups

 
