%{
    重新聚类结果可视化与量化代码
%}
%% 读取数据
rootpath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\zengyuting_diff_color\' ...
    'aggressive_data_20230317\recluster_data'];
load([rootpath,'\data_sample_cell_20230320.mat']);
load([rootpath,'\dist_mat_all_20230320.mat']);
load([rootpath,'\embedding_20230320.mat']);
% load('CQI.mat');
%% 视频切割分组
%% 创建路径
savepath = [rootpath,'\cut_beh_20230320'];
mkdir(savepath);
%% 创建单层路径
Tlist = cell2mat(data_sample_cell(:,2));
unique_T = unique(Tlist(:,4));
for k = 1:size(unique_T,1)
    temp1 = num2str(unique_T(k,1));
    mkdir([savepath,'\',temp1])
end
%% 切割视频，单层路径
CQI = calClus_qulity_fast(dist_mat_all, best_label_embedding(:,4));
%%
videopath = ['Z:\hanyaning\multi_mice_test\' ...
    'Social_analysis\data\zengyuting_diff_color\' ...
    'aggressive_data_20230317\unmerge_data'];
fileFolder = fullfile(videopath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
videonames = {dirOutput.name}';
for n = 1:size(videonames,1)
    vidobj = VideoReader([videopath,'\',videonames{n,1}]);
    for k = 1:size(data_sample_cell,1)
        if strcmp([videonames{n,1}(1,1:(end-4)),'_struct'], ...
                data_sample_cell{k,3}(1,1:(end-4)))
            tempstartframe = data_sample_cell{k,2}(1,1);
            tempendframe = data_sample_cell{k,2}(1,2);
            temp1 = num2str(data_sample_cell{k,2}(1,4));
            temp2 = data_sample_cell{k,3}(1,1:(end-4));
            temp3 = num2str(data_sample_cell{k,2}(1,3));
            temp4 = num2str(CQI(1,k),'%4.2f');
            writeobj = VideoWriter([savepath,'\',temp1,'\',temp4,'_',temp2,'_',temp3,'_',...
                num2str(tempstartframe),'_',num2str(tempendframe),'.avi']);
            writeobj.FrameRate = vidobj.FrameRate;
            open(writeobj);
            for m = tempstartframe:tempendframe
                frame = read(vidobj,m);
                writeVideo(writeobj,frame);
            end
            close(writeobj);
        end
    end
    disp(n);
end