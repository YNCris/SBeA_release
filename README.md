# SBeA_release
The release version of SBeA.  
Linked paper: [Multi-animal 3D social pose estimation, identification and behaviour embedding with a few-shot learning framework](https://www.nature.com/articles/s42256-023-00776-5)  

For the single animal usage, please jump to [Behavior Atlas](https://github.com/huangkang314/Behavior-Atlas), and the related paper is [A hierarchical 3D-motion learning framework for animal spontaneous behavior mapping](https://www.nature.com/articles/s41467-021-22970-y)    
## 1. The demo of SBeA 
### Multi-animal tracking cross species
#### Tracking mice
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
