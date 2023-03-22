%{
    transform pair-r24m-dataset to sbea coords3d format
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% set path
rootpath = ['Z:\hanyaning\multi_mice_test\Social_analysis\' ...
    'data\sbea_validation'];
savepath = rootpath;
pairname = 'PAIR-R24M-Dataset';
savename = 'sbea_20221114';
savelabelname = 'social_labels';
savesublabelname = 'sub_social_labels';
mkdir([savepath,'\',savename])
mkdir([savepath,'\',savename,'\',savelabelname])
mkdir([savepath,'\',savename,'\',savesublabelname])
%% load data
fileFolder = fullfile([rootpath,'\',pairname]);
dirOutput = dir(fullfile(fileFolder,'2021*'));
foldernames = {dirOutput.name}';
%% transform
for k = 1:size(foldernames,1)
    %% load csv
    csvname = [rootpath,'\',pairname,'\',foldernames{k,1},...
        '\markerDataset.csv'];
    tempdata = readtable(csvname);
    %% load abs position
    varnames = tempdata.Properties.VariableNames;
    selidx = zeros(size(varnames));
    for m = 1:size(varnames,2)
        if strcmp(varnames{m}(1:8),'absolute')
            selidx(m) = 1;
        end
    end
    selpos = tempdata(:,selidx==1);
    all_coords3d = fillmissing(selpos.Variables,'linear');
    %% load social labels
    social_labels = tempdata.interactionCat;
    social_labels(isnan(social_labels)) = 0;
    %% load sub-social labels
%     sub_social_labels = (1+social_labels)*10000+...
%         tempdata.behaviorCoarse_an1*100+...
%         tempdata.behaviorCoarse_an2;
    sub_social_labels = ...
        tempdata.behaviorCoarse_an1*100+...
        tempdata.behaviorCoarse_an2;
    %% seperate names
    splnames = split(foldernames{k,1},'_');
    name1 = [splnames{3},'-rec',num2str(k),'-',splnames{3},...
        splnames{4},'-',splnames{1}];
    name2 = [splnames{4},'-rec',num2str(k),'-',splnames{3},...
        splnames{4},'-',splnames{1}];
%     %% save coords3d
%     coords3d = all_coords3d(:,1:36);
%     save([savepath,'\',savename,...
%         '\',name1,'.mat'],'coords3d')
%     coords3d = all_coords3d(:,37:72);
%     save([savepath,'\',savename,...
%         '\',name2,'.mat'],'coords3d')
%     %% save labels
%     save([savepath,'\',savename,'\',savelabelname,'\',...
%         'rec',num2str(k),'-',splnames{3},...
%         splnames{4},'-',splnames{1},'.mat'],'social_labels')
    %% save sub labels
    save([savepath,'\',savename,'\',savesublabelname,'\',...
        'rec',num2str(k),'-',splnames{3},...
        splnames{4},'-',splnames{1},'.mat'],'sub_social_labels')
    disp(k)
end
%% write videos
% parfor k = 1:size(foldernames,1)
%     %% load csv
%     csvname = [rootpath,'\',pairname,'\',foldernames{k,1},...
%         '\markerDataset.csv'];
%     tempdata = readtable(csvname);
%     %% load abs position
%     varnames = tempdata.Properties.VariableNames;
%     selidx = zeros(size(varnames));
%     for m = 1:size(varnames,2)
%         if strcmp(varnames{m}(1:8),'absolute')
%             selidx(m) = 1;
%         end
%     end
%     selpos = tempdata(:,selidx==1);
%     all_coords3d = selpos.Variables;
%     %% load social labels
%     social_labels = tempdata.interactionCat;
%     %% seperate names
%     splnames = split(foldernames{k,1},'_');
%     name1 = [splnames{3},'-rec',num2str(k),'-',splnames{3},...
%         splnames{4},'-',splnames{1}];
%     name2 = [splnames{4},'-rec',num2str(k),'-',splnames{3},...
%         splnames{4},'-',splnames{1}];
%     %%
%     writeobj1 = VideoWriter([savepath,'\',savename,...
%         '\',name1,'.avi']);
%     writeobj2 = VideoWriter([savepath,'\',savename,...
%         '\',name2,'.avi']);
%     %% temp show
%     data1 = all_coords3d(:,1:36);
%     data2 = all_coords3d(:,37:72);
%     X1 = data1(:,1:3:end)';
%     Y1 = data1(:,2:3:end)';
%     Z1 = data1(:,3:3:end)';
%     X2 = data2(:,1:3:end)';
%     Y2 = data2(:,2:3:end)';
%     Z2 = data2(:,3:3:end)';
%     % 绘制原始骨架
%     plotstr1 = 'r';
%     linestr1 = 'r';
%     plotstr2 = 'b';
%     linestr2 = 'b';
%     open(writeobj1)
%     open(writeobj2)
%     h1 = figure(k);
%     set(h1,'Position',[100,100,320,180])
%     for m = 1:1:size(data1,1)
%         subplot(121)
%         plot_skl_pair24(X1(:,m),Y1(:,m),Z1(:,m),plotstr1,linestr1)
%         hold on
%         plot_skl_pair24(X2(:,m),Y2(:,m),Z2(:,m),plotstr2,linestr2)
%         hold off
%         axis([-1000,1000,-1000,1000,0,200])
%     %     axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
%         view(2)
%         title(m)
% %         axis equal
%         subplot(122)
%         plot_skl_pair24(X1(:,m),Y1(:,m),Z1(:,m),plotstr1,linestr1)
%         hold on
%         plot_skl_pair24(X2(:,m),Y2(:,m),Z2(:,m),plotstr2,linestr2)
%         hold off
%     %     title(err3d(k,1))
%     %     axis([-1000,1000,-1000,1000,0,400])
%         grid on
%         axis([min(X1(:)),max(X1(:)),min(Y1(:)),max(Y1(:)),min(Z1(:)),max(Z1(:))])
%         view(-44,10)
% %         axis equal
%         showframe = getframe(h1);
%         writeVideo(writeobj1,showframe.cdata)
%         writeVideo(writeobj2,showframe.cdata)
% %         pause
%         pause(0.000000000001)
%     end
%     close(writeobj1)
%     close(writeobj2)
%     disp(k)
% end