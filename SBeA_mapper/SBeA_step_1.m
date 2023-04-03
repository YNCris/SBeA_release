%{
    1. multi-3d to single 3d
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% Set path
id_3d_path = ['Your path of *id3d.mat'];
savepath = [id_3d_path,'\BeA_path'];
mkdir(savepath)
%% process
%% load 3d names
fileFolder = fullfile(id_3d_path);
dirOutput = dir(fullfile(fileFolder,'*-id3d.mat'));
file3dNames = {dirOutput.name}';
%% seperate data
for k = 1:size(file3dNames,1)
    %%
    tempdata = load([id_3d_path,'\',file3dNames{k,1}]);
    %% load video name
    videoname = [file3dNames{k,1}(1,1:(end-9)),'-camera-0.avi'];
    %% 
    dataname = cellstr(tempdata.name3d);
    data3d = tempdata.coords3d;
    datalen = size(data3d,2)/length(dataname);
    %% output 3d data
    for m = 1:length(dataname)
        tempdataname = dataname{m};
        coords3d = data3d(:,((m-1)*datalen+1):(m*datalen));
        outdataname = [tempdataname,'-',file3dNames{k,1}(1,1:(end-9)),'.mat'];
        outvideoname = [tempdataname,'-',videoname(1,(1:(end-13))),'.avi'];
        copyfile([id_3d_path,'\',videoname],[savepath,'\',outvideoname])
        save([savepath,'\',outdataname],'coords3d')
        disp(outdataname)
        disp(outvideoname)      
    end
    disp(k)
end
























