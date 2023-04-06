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
  
GUI: ![image](https://github.com/YNCris/SBeA_release/blob/main/demo/tracker_gui.png)   
  
Input:  
Create A New 'configfile.yaml'. Select a path and define a name to save your project (workspace).
  
Output:  
The workspace of your project.

### 1. Create/load project  
SBeA_tracker is managed in a project folder. The first step is to create or load a project.  
Demo results:  
![image](https://github.com/YNCris/SBeA_release/blob/main/demo/create_project.png)  
Notes:  
datasets folder: save datasets  
evals folder: save model evaluation results  
models folder: save deep learning models  
configfile.yaml: the configuration of SBeA_tracker 
  
GUI: ![image](https://github.com/YNCris/SBeA_release/blob/main/demo/tracker_gui.png)   
  
Input:  
Create A New 'configfile.yaml'. Select a path and define a name to save your project (workspace).
  
Output:  
The workspace of your project.