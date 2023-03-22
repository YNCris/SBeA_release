function seg_video(savepath)

% segment the video into pices according to the decomposition
%
% Input
%   savepath       -  the path to save the video segments
%   layer          -  which layer to segment
%
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

global HBT

labels = G2L_Slow(HBT.HBT_DecData.L2.reClusData.G);
n_clus = size(HBT.HBT_DecData.L2.reClusData.G, 1);
embedd2 = HBT.HBT_MapData.L2.embedding;
vel_nm = HBT.HBT_DecData.L2.velnm;

embedd3 = [embedd2, vel_nm];

%% calculating dist_mat
D = pdist(embedd3, 'seuclidean');
D = squareform(D);
% D = 1-conKnl(D, 'knl','g','nei', 0.1);

CQI = calClus_qulity(D, labels);

% set the file path
mkdir([savepath, '/Video_seg']);

Seg = HBT.HBT_DecData.L2.reClusData;
try
    fs = HBT.DataInfo.VideoInfo.FrameRate;
catch
    prompt = 'Please input the FrameRate: ';
    fs = input(prompt);
end

try
    cut_offset = HBT.PreproInfo.CutData.Start * fs;
catch
    cut_offset = 0;
end

data_len = size(HBT.HBT_DecData.XY, 2);

%% creat subfolders

Cutfilepath = [savepath, '/Video_seg', '/'];
Cutfiledocname = HBT.DataInfo.VideoName(1:end-4);
mkdir([Cutfilepath, Cutfiledocname]);
vidobj = HBT.DataInfo.VideoInfo;

n_clust = size(Seg.G, 1);
for m = 1:n_clust
    mkdir([Cutfilepath,Cutfiledocname,'/',num2str(m)])
end
nummat = (1:n_clust)';
% xlswrite([Cutfilepath Cutfiledocname '/' Cutfiledocname '_behavior_label.xlsx'],...
%     {'video number','label'});
% xlswrite([Cutfilepath Cutfiledocname '/' Cutfiledocname '_behavior_label.xlsx'],nummat,1,'2');
%% 

TD_sR = 1:data_len+1;
segTrans = SegBarTransWhite(Seg, TD_sR);
savelist = zeros(size(segTrans, 1),3);
savelist(:, 1) = segTrans(:, 3);
savelist(:, 2:3) = segTrans(:, 1:2);

h = waitbar(0,'Sgementing video...');
%% 
for m = 1:size(savelist,1)
    Cutfilename = [num2str(savelist(m,1)), num2str(CQI(m), '/%4.2f-'), ...
        'Start：',num2str(savelist(m,2)),...
        '_End：',num2str(savelist(m,3))];
    
    progress = savelist(m,3)/data_len;
    waitbar(progress)
    writerObj = VideoWriter([Cutfilepath, Cutfiledocname,'/',Cutfilename,'.avi']);
    writerObj.FrameRate = fs;
    open(writerObj);
    for n = (cut_offset + savelist(m,2)):(cut_offset + savelist(m,3))% 
        frame = read(vidobj, n);
        writeVideo(writerObj,frame);
    end
    close(writerObj);
    disp([Cutfilename, 'Successfully Saved!'])
end
close(h)
disp('save segment list。�?��??')
save([Cutfilepath,Cutfiledocname,'/savelist.mat'], 'savelist')
disp('save complete�?')

