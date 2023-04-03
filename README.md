# SBeA_release
The release version of SBeA.  
  
The study of social behaviors in animals is essential for understanding their survival and reproductive strategies. However, accurately tracking and analyzing the social interactions of free-moving animals has remained a challenge. Existing multi-animal pose estimation techniques suffer from drawbacks such as the need for extensive manual annotation and difficulty in discriminating between similar-looking animals in close social interactions. In this paper, we present the Social Behavior Atlas (SBeA), a novel computational framework that solves these challenges by employing a deep learning-based video instance segmentation model, 3D pose reconstruction, and unsupervised dynamic behavioral clustering. SBeA framework also involves a multi-camera setup to prevent occlusion, and a novel approach to identify individual animals in close social interactions. We demonstrate the effectiveness of SBeA in tracking and mapping the 3D close interactions of free-moving animals using the example of genetic mutant mice, birds, and dogs. Our results show that SBeA is capable of identifying subtle social interaction abnormalities, and the models and frameworks developed can be applied to a wide range of animal species. SBeA is a powerful tool for researchers in the fields of neuroscience and ecology to study animal social behaviors with a high degree of accuracy and reliability.  
  
Linked paper: [Social Behavior Atlas: A computational framework for tracking and mapping 3D close interactions of free-moving animals](https://www.biorxiv.org/content/10.1101/2023.03.05.531235v1)  
## 1. The demo of SBeA 
### Multi-animal tracking cross species
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/rec11-A1A6-20220822_visual.gif)  
#### Tracking parrots
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/rec3-B1B2-20220919_visual.gif)  
#### Tracking dogs
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/rec3-D1D2-20221009_visual.gif)  
Notes:  
Blue color: animal 1  
Red color: animal 2  
Masks: the segmentation of them  
Bounding boxes: generated by the maximum external boxes of masks  
Left: Video capture with multi-view cameras  
Center: Cropped identities
Right: 3D poses with identities of multiple animals  
### Social behavior clustering of mice autism model
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/embed_demo.gif)  
Notes:  
Left three frames: the free-social interactions of three group of mice
WT: Wild type mouse  
KO: Shank3B knockout mouse  
Right: social behavior atlas with distance map
Circle: current social behavior module of left three groups  
Trace: previous social behavior modules last 100 frames  
## 2. The tutorials of SBeA 
[SBeA_tracker](https://github.com/YNCris/SBeA_release/blob/main/README_SBeA_tracker.md)   
[SBeA_mapper](https://github.com/YNCris/SBeA_release/blob/main/README_SBeA_mapper.md)
