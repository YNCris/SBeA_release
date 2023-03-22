function AC = ac_method2_amf(WinWD)
% data artifact correction
%
% Input
%   WinWD    - time window width of adaptive median filtering, 1 x 1 (double)
%
% Output
%   AC       - artifact correction patameters, 1 x 1 (struct)
%       - AC.LH                 -  parameters for likelihood noise detection
%           - Flag              -  flag of active method
%           - Seq               -  sequence of method
%           - Param.Thres       -  threshold of this method
%       - AC.MP                 - parameters for morphological method
%           - Flag              -  flag of active method
%           - Seq               -  sequence of method
%           - Param.MinThres    -  minimum threshold of this method
%           - Param.MaxThres    -  maximum threshold of this method
%       - AC.MF                 - parameters for median filtering
%           - Flag              -  flag of active method
%           - Seq               -  sequence of method
%           - Param.WinWD       -  window width of this method
%       - AC.NMF                - parameters for local median filtering
%           - Flag              -  flag of active method
%           - Seq               -  sequence of method
%           - Param.WinWD       -  window width of this method
%       - AC.AMF                - parameters for adaptive median filtering
%           - Flag              -  flag of active method
%           - Seq               -  sequence of method
%           - Param.WinWD       -  window width of this method
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-05-2020

%% set parameters
AC.LH.Flag = 1;
AC.LH.Seq = 1;
AC.LH.Param.Thres = 0.95;
AC.MP.Flag = 1;
AC.MP.Seq = 2;
AC.MP.Param.MinThres = 0.1;
AC.MP.Param.MaxThres = 2;
AC.MF.Flag = 0;
AC.MF.Seq = 0;
AC.MF.Param.WinWD = 1000;%ms
AC.NMF.Flag = 0;
AC.NMF.Seq = 0;
AC.NMF.Param.WinWD = 1000;%ms
AC.AMF.Flag = 1;
AC.AMF.Seq = 3;
AC.AMF.Param.WinWD = WinWD;%ms

