# Data Formatting Standards
**General:** Data for analysis are stored and manipulated as structures, which contain all relevant information necessary to work with that data and are in .mat files, in which commonly used data types have a standardized format as outlined in this document.
**File Name:** HB_Data_Struct.mat
**Table of Contents:** Struct Varibles

[TOC]

## DataInfo
This struct contains all the information of animal behavior videos.
**Defined struct fields:**
* DataInfo.FileName: Px1 vector listing the name of data files
* DataInfo.FilePath: Px1 vector listing the path of data files
* DataInfo.VideoName: Px1 vector listing the name of videos to analysis
* DataInfo.VideoPath: Px1 vector listing the videos' path
* DataInfo.VideoInfo: the same as VideoReader object
* DataInfo.Skl: Mx1 cell listing the definition of animal skeleton
* DataInfo.Source: Indicates the type of data source
  * 'dlc': the data from DeepLabCut

## RawData
This struct contains the corresponding raw data of DataInfo
**Defined struct fields:**
* RawData.X: NxM matrix saving the x-coordinate data of skeletions. N is time point, M is dimension.
* RawData.Y: NxM matrix saving the y-coordinate data of skeletions. N is time point, M is dimension.
* RawData.LH: Applicable if the data source is `DeepLabCut`, NxM matrix saving the likelihood of x&y-coordinate. N is time point, M is dimension. If the data doesn't have likelihood, this matrix could be empty. If the data has different accuracy representation method, this matrix could save them.

## PreproInfo
This struct contains the preprocessing workflow of raw data.
**Defined struct fields:**
* PreproInfo.CutData:saving the cut range of data.
  * PreproInfo.CutData.Start: integral varible saving the start frame of data.
  * PreproInfo.CutData.End: integral variable saving the end frame of data.
* PreproInfo.AC: saving the artifact correction parameters.
  * PreproInfo.AC.LH: mark noise points by likelihood.
    * PreproInfo.AC.LH.Flag: bool variable, 1 is on, 0 is off.
    * PreproInfo.AC.LH.Seq: integer variable mark the sequence of the preprocessing method application, 1 is the first.
    * PreproInfo.AC.LH.Param: struct saving the parameters of likelihood method
      * PreproInfo.AC.LH.Param.Thres: double varible saving the threshold of likelihood method
  * PreproInfo.AC.MP: mark noise frame by animal morphological detection
    * PreproInfo.AC.MP.Flag: bool variable, 1 is on, 0 is off.
    * PreproInfo.AC.MP.Seq: integer variable mark the sequence of the preprocessing method application, 1 is the first.
    * PreproInfo.AC.MP.Param: struct saving the parameters of morphological method
      * PreproInfo.AC.MP.Param.MinThres: double varible saving the mininum threshold of morphological method
      * PreproInfo.AC.MP.Param.MaxThres: double varible saving the maxinum threshold of morphological method
  * PreproInfo.AC.MF: median filtering of the whole data
    * PreproInfo.AC.MF.Flag: bool variable, 1 is on, 0 is off.
    * PreproInfo.AC.MF.Seq: integer variable mark the sequence of the preprocessing method application, 1 is the first.
    * PreproInfo.AC.MF.Param:  struct saving the parameters of median filtering
      * PreproInfo.AC.MF.Param.WinWD: double varible saving the window width of median filtering
  * PreproInfo.AC.NMF: median filtering of the noise data
    * PreproInfo.AC.NMF.Flag: bool variable, 1 is on, 0 is off.
    * PreproInfo.AC.NMF.Seq: integer variable mark the sequence of the preprocessing method application, 1 is the first.
    * PreproInfo.AC.NMF.Param:  struct saving the parameters of median filtering for noise data
      * PreproInfo.AC.NMF.Param.WinWD: double varible saving the window width of median filtering for noise data
  * PreproInfo.AC.AMF: adaptive median filtering of the whole data
    * PreproInfo.AC.AMF.Flag: bool variable, 1 is on, 0 is off.
    * PreproInfo.AC.AMF.Seq: integer variable mark the sequence of the preprocessing method application, 1 is the first.
    * PreproInfo.AC.AMF.Param:  struct saving the parameters of adaptive median filtering
      * PreproInfo.AC.AMF.Param.WinWD: double varible saving the window width of adaptive median filtering
  * PreproInfo.AC.NAMF: adaptive median filtering of the noise data
    * PreproInfo.AC.NAMF.Flag: bool variable, 1 is on, 0 is off.
    * PreproInfo.AC.NAMF.Seq: integer variable mark the sequence of the preprocessing method application, 1 is the first.
    * PreproInfo.AC.NAMF.Param:  struct saving the parameters of adaptive median filtering for noise data
    * PreproInfo.AC.NAMF.Param.WinWD: double varible saving the window width of adaptive median filtering for noise data
* PreproInfo.Smooth:saving the parameters of data smoothing
`此处可以继续添加需要的数据预处理方法`

## PreproData
This struct contains the preprocessing data.
**Defined struct fields:**
* PreproData.X: NxM matrix saving the x-coordinate data of skeletions. N is time point, M is dimension.
* PreproData.Y: NxM matrix saving the y-coordinate data of skeletions. N is time point, M is dimension.
* PreproData.ND: NxM matrix saving the noise detection results of x&y-coordinate. N is time point, M is dimension. 0 is good data, 1 is noise data.

## HBT_DecParam
This struct contains the parameters of HierBehaveTome decomposition.
**Defined struct fields:**
* HBT_DecParam.BA: struct variable, saving the parameters of body alignment
  * HBT_DecParam.BA.Cen: bool variable, the flag of centering skeleton. 1 is on, 0 is off.
  * HBT_DecParam.BA.VA: bool variable, the flag of skeleton vector align. 1 is on, 0 is off.
  * HBT_DecParam.BA.CenIndex: integral variable, saving the index of center point
  * HBT_DecParam.BA.VAIndex: integral variable, saving the index of vector point
* HBT_DecParam.FS: struct varible, saving the parameters of body parts features selection
  * HBT_DecParam.FS.featNames: same to DataInfo.Skl, listing the definition of animal skeleton
  * HBT_DecParam.FS.selection: bool varible, saving the flag if corresponding feature is selected
  * HBT_DecParam.FS.weight: double varible, saving the weight of the corresponding feature
* HBT_DecParam.L1: saving HBT parameters of layer 1
  * HBT_DecParam.L1.ralg: string varible, saving the clustering method for pose decomposing
  * HBT_DecParam.L1.redL: double varible, maximum segment length of a unique pose
  * HBT_DecParam.L1.calg: string varible, saving the method for pose decomposing
    * 'kmeans': k-means method for pose decomposing
    * 'density': density cluster for pose decomposing
  * HBT_DecParam.L1.kF: integral varible, saving the frame cluster, needed if the `calg` is 'kmeans'. 
* HBT_DecParam.L2: saving HBT parameters of layer 2.
  *  HBT_DecParam.L2.kerType: string varible, saving the kernel type for  kernel matrix calculating.
  *  HBT_DecParam.L2.kerBand:  string varible, saving the kernel band for  kernel matrix calculating.
  *  HBT_DecParam.L2.k: integral variable saving class number of layer 2.
  *  HBT_DecParam.L2.nMi: integral varible saving the minimum length of every motifs.
  *  HBT_DecParam.L2.nMa: integral varible saving the maximum length of every motifs.
  *  HBT_DecParam.L2.Ini: char varible indicating the initialization method of layer 2 decomposition, 'p' for pectral clustering, 'r' for random initialization.

* HBT_DecParam.L3: saving HBT parameters of layer 3.
  *  HBT_DecParam.L3.k: integral variable saving class number of layer 3.
  *  HBT_DecParam.L3.nMi: integral varible saving the minimum length of every motifs.
  *  HBT_DecParam.L3.nMa: integral varible saving the maximum length of every modules.
  *  HBT_DecParam.L3.Ini: char varible indicating the initialization method of layer 3 decomposition, 'p' for pectral clustering, 'r' for random initialization.

## HBT_DecData
This struct contains the data of HierBehaveTome decomposition.
**Defined struct fields:**
* HBT_DecData.XY: MxN matrix saving the processed dimension of data. M is the number of dimensions, N is the number of time points.
* HBT_DecData.K: PxP matrix saving the distance matrix.
* HBT_DecData.L1: saving the HBT data of layer 1
  * HBT_DecData.L1.ReMap: saving the mapping list of layer 1 with data
  * HBT_DecData.L1.Seglist: saving the decomposition results of layer 1
  * HBT_DecData.L1.MedData: a struct saving the intermediate variables of different decomposition methods
* HBT_DecData.L2: saving the HBT data of layer 2
  * HBT_DecData.L2.ReMap: saving the mapping list of layer 2 with data
  * HBT_DecData.L2.Seglist: saving the decomposition results of layer 2
  * HBT_DecData.L2.MedData: a struct saving the intermediate variable of layer 2
* HBT_DecData.L3: saving the HBT data of layer 3
  * HBT_DecData.L3.ReMap: saving the mapping list of layer 3 with data
  * HBT_DecData.L3.Seglist: saving the decomposition results of layer 3
  * HBT_DecData.L3.MedData: a struct saving the intermediate variable of layer 3
* HBT_DecData.DP_X: DxS matrix, saving the results of postural decomposition, D dimensions after dimensionality reduction, S number of time series after removing the temporal redunancy 
* HBT_DecData.DP_sR:

## HBT_MapParam
This struct contains the parameters of HierBehaveTome mapping.
**Defined struct fields:**
* HBT_MapParam.Method: string varible, saving the method for behavior mapping.
  * 'umap': UMAP method for behavior mapping.
  * 'tsne': t-SNE method for behavior mapping.
* HBT_MapParam.L1: saving the HBT mapping parameters of layer 1
  * HBT_MapParam.L1.Nc:  integral variable indicating n dimensions for visualization.
  * HBT_MapParam.L1.MinD: double variable indicating the minimum distance between two data points.
  * HBT_MapParam.L1.Nn: integral varible indicating n neighborhoods of a data point.
* HBT_MapParam.L2: saving the HBT mapping parameters of layer 2
  * HBT_MapParam.L2.Nc:  integral variable indicating n dimensions for visualization.
  * HBT_MapParam.L2.MinD: double variable indicating the minimum distance between two data points.
  * HBT_MapParam.L2.Nn: integral varible indicating n neighborhoods of a data point.
* HBT_MapParam.L3: saving the HBT mapping parameters of layer 3
  * HBT_MapParam.L3.Nc:  integral variable indicating n dimensions for visualization.
  * HBT_MapParam.L3.MinD: double variable indicating the minimum distance between two data points.
  * HBT_MapParam.L3.Nn: integral varible indicating n neighborhoods of a data point.

## HBT_MapData
This struct contains the data of HierBehaveTome mapping.
**Defined struct fields:**
* HBT_MapData.L1: saving the HBT mapping data of layer 1
* HBT_MapData.L2: saving the HBT mapping data of layer 2
* HBT_MapData.L3: saving the HBT mapping data of layer 3

## Beh_Label
This struct contains the label of behavior in every layer.
**Defined struct fields:**
* Beh_Label.L1: Nx1 string vector saving the label of every segment in layer 1
* Beh_Label.L2: Nx1 string vector saving the label of every segment in layer 2
* Beh_Label.L2: Nx1 string vector saving the label of every segment in layer 3

## Ana_TraParam
This struct contains the parameters of tranditional behavior analysis.
**Defined struct fields:**
* Ana_TraParam.Innate: saving the parameters of innate behavior analysis
  * Ana_TraParam.Innate.Freezing: saving the parameters of freezing behavior
    * Ana_TraParam.Innate.Freezing.VT: double variable, setting the threshold of velocity
    * Ana_TraParam.Innate.Freezing.AT: integral variable, setting the threshold of action
    * Ana_TraParam.Innate.Freezing.TT: double variable, setting the threshold of time
  * Ana_TraParam.Innate.Flight: saving the parameters of flight behavior
     * Ana_TraParam.Innate.Flight..VT: double variable, setting the threshold of velocity
    * Ana_TraParam.Innate.Flight.TT: double variable, setting the threshold of time
* Ana_TraParam.HeatMap: saving the parameters of heatmap
  * Ana_TraParam.HeatMap.Mu: double varible saving the mean value
  * Ana_TraParam.HeatMap.Sigma: double varible saving the variance
  * Ana_TraParam.HeatMap.TW: saving the parameters of time window
    * Ana_TraParam.HeatMap.TW.Pre: integral varible saving the start position of time window
    * Ana_TraParam.HeatMap.TW.Post: integral varible saving the end position of time window
* Ana_TraParam.VMAP: saving the parameters of velocity map
  * Ana_TraParam.VMAP.Mu: double varible saving the mean value
  * Ana_TraParam.VMAP.Sigma: double varible saving the variance
  * Ana_TraParam.VMAP.TW: saving the parameters of time window
    *  Ana_TraParam.VMAP.TW.Pre: integral varible saving the start position of time window
    *  Ana_TraParam.VMAP.TW.Post: integral varible saving the end position of time window
* Ana_TraParam.Ethogram: saving the parameters of ethogram
  * Ana_TraParam.Ethogram.TW: saving the parameters of time window
    *  Ana_TraParam.Ethogram.TW.Pre: integral varible saving the start position of time window
    *  Ana_TraParam.Ethogram.TW.Post: integral varible saving the end position of time window

## Ana_TraData
This struct contains the data of tranditional behavior analysis.
**Defined struct fields:**
* Ana_TraData.HeatMap: NxN matrix saving the data of heatmap
* Ana_TraData.VMAP: NxN sparse matrix saving the data of velocity map
* Ana_TraData.Freezing: []
* Ana_TraData.Flight: []
* Ana_TraData.Pos: NxN matrix saving the data of position 

## Ana_HBTParam
This struct contains the parameters of HBT analysis.
**Defined struct fields:**
* Ana_HBTParam.Group:Nx1 cell saving the grouped data
* Ana_HBTParam.TW: saving the time window of choosing data
  * Ana_HBTParam.TW.Pre: integral varible saving the start position of time window
  * Ana_HBTParam.TW.Post: integral varible saving the end position of time window
* Ana_HBTParam.L: integral varible saving the layer for statistic
* Ana_HBTParam.States: saving the statistic parameters of states
  * Ana_HBTParam.States.Smethod: string varible saving the statistic method of states
* Ana_HBTParam.Trans: saving the statistic parameters of state transitions
  * Ana_HBTParam.Trans.Smethod: string varible saving the statistic method of transitions

## Ana_HBTData
This struct contains the data of HBT analysis. 
**Defined struct fields:**
* Ana_HBTData.States: saving the statistic data of states
  * Ana_HBTData.States.GroupData: saving the states data of every group
  * Ana_HBTData.States.Normtest: Nx1 vectors saving the P-values of normal test
  * Ana_HBTData.States.Vartest: Nx1 vectors saving the P-values of homogeneity test for variance
  * Ana_HBTData.States.Comp: Nx2 matrix saving the comparison matrix
  * Ana_HBTData.States.P: Nx1 vector saving the P-value of every comparison
  * Ana_HBTData.States.X: 需要运行代码查看具体作用
  * Ana_HBTData.States.Group: 需要运行代码查看具体作用
  * Ana_HBTData.States.Means: Nx2 matrix saving the mean values of every comparison
  * Ana_HBTData.States.Vars: Nx2 matrix saving the variance of every omparison
  * Ana_HBTData.States.N: Nx2 matrix saving the data number of every comparison
  * Ana_HBTData.States.Pstars: Nx1 matrix saving the significant differences of every comparison
* Ana_HBTData.Trans: saving the statistic data of state transitions
  * Ana_HBTData.Trans.GroupData: saving the state transitions data of every group
  * Ana_HBTData.Trans.Normtest: Nx1 vectors saving the P-values of normal test
  * Ana_HBTData.Trans.Vartest: Nx1 vectors saving the P-values of homogeneity test for variance
  * Ana_HBTData.Trans.Comp: Nx2 matrix saving the comparison matrix
  * Ana_HBTData.Trans.P: Nx1 vector saving the P-value of every comparison
  * Ana_HBTData.Trans.X: 需要运行代码查看具体作用
  * Ana_HBTData.Trans.Group: 需要运行代码查看具体作用
  * Ana_HBTData.Trans.Means: Nx2 cell saving the mean values matrixes of every comparison
  * Ana_HBTData.Trans.Vars: Nx2 cell saving the variance matrixes of every omparison
  * Ana_HBTData.Trans.N: Nx2 cell saving the data number matrixes of every comparison
  * Ana_HBTData.Trans.Pstars: Nx1 matrix saving the significant differences matrixes of every comparison

## GUI
* GUI.Menu:
* GUI.Main_Window:
* GUI.Mes_Box: ui uicontrol, save properties of GUI.Mes_Box
* GUI.Mes_BoxMe s: string variable, saving the message displayed in Message box
* `待补充`
## Exp_Info
This struct contains all the informations of experiment treatments
**Defined struct fields:**
* Exp_Info.Bas: string variable saving all the basic information of experiment treatments
* Exp_Info.Event: saving the event information
  * Exp_Info.Event.ID: integral varible indicating the rank of event
  * Exp_Info.Event.Name: string varible saving the event name
  * Exp_Info.Event.Start: integral varible saving the start frame of event
  * Exp_Info.Event.Stop: integral carible saving the stop frame of event


