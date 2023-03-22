%{
    segment social videos
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% set path
videopath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\unmerge_data'];
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\recluster_data'];
filename = {'dialog_box_cell.mat','overlap_dialog_box_cell.mat','Group_GC.mat','l3tol2_cell.mat','GC_cell.mat'};
savepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\recluster_data'];
savename = 'social_L3_20220428';
%% set L2 label list
label_list_L2 = {...
    'Walking','Walking','Immobility','Immobility',...
    'Avoidence running','Approach running','Risng','Upstretching',...
    'Avoidence walking','Right turning','Right turning','Right running',...
    'Approach sniffing','Approach sniffing','Upstretching' ,'no idea',...
    'Approach sniffing','Approach sniffing','Noise','Running',...
    'Immobility','Immobility','Right turning','Right rising/hunchinggrooming',...
    'Right grooming','Rearing','Rearing','Rearing',...
    'Sniffing','Sniffing','Siffing','Left grooming/rising',...
    'Left running','Right sniffing','Left turning','no idea',...
    'Left turning','Trotting','Sniffing','Rising/hunching',...
    'noise'...
};
%% load data
for k = 1:length(filename)
    load([filepath,'\',filename{k}])
end
%% create save video path
mkdir([savepath,'\',savename])
% for m = 1:size(overlap_dialog_box_cell,1)
%     for n = 1:size(overlap_dialog_box_cell,2)
%         %%
%         tempcell = overlap_dialog_box_cell{m,n};
%         for k = 1:size(tempcell,1)
%             temptempcell = tempcell{k,1};
%             for p = 1:size(temptempcell,1)
%                 mkdir([savepath,'\',savename,'\', ...
%                     num2str(temptempcell{p,1}(1,3)),'_',num2str(temptempcell{p,2}(1,3))])
%             end
%         end
%     end
% end
%% seg videos
count = 1;
for m = 1:size(overlap_dialog_box_cell,1)
    %%
    tempname = split(group_GC{m,1},'_');
    %% load L2
    templ2_1 = cellfun(@transpose,l3tol2_cell{m,1}(:,2),'UniformOutput',false);
    templ2_2 = cellfun(@transpose,l3tol2_cell{m,2}(:,2),'UniformOutput',false);
    L2_1 = cell2mat(templ2_1)';
    L2_2 = cell2mat(templ2_2)';
    %%
    for n = 1:size(overlap_dialog_box_cell,2)
        %% 
        if n == 1
            refname = group_GC{m,2};
            matchname = group_GC{m,3};
            refL2 = L2_1;
            matchL2 = L2_2;
        else
            refname = group_GC{m,3};
            matchname = group_GC{m,2};
            refL2 = L2_2;
            matchL2 = L2_1;
        end
        %% load videoobj
        vidobj = VideoReader([videopath,'\',refname,'-',tempname{1,1},'.mp4']);
        %% load dialog box  
        tempcell = overlap_dialog_box_cell{m,n};
        for k = 1:size(tempcell,1)
            temptempcell = tempcell{k,1};
            gc = tempcell{k,2};
            for p = 1:size(temptempcell,1)
                %%
                savedir = [savepath,'\',savename];
                savevideoname = [num2str(count),'_',num2str(p),'_',...
                    tempname{1,1},'_',refname,'_',matchname,'_',...
                    num2str(temptempcell{p,1}(1,1)),'-',...
                    num2str(temptempcell{p,1}(1,2)),'-',...
                    num2str(temptempcell{p,1}(1,3)),'_',...
                    num2str(temptempcell{p,2}(1,1)),'-',...
                    num2str(temptempcell{p,2}(1,2)),'-',...
                    num2str(temptempcell{p,2}(1,3)),'.avi'];
                count = count+1;
                %% 
                framerange = [min([temptempcell{p,1}(1,1:2),temptempcell{p,2}(1,1:2)]),...
                    max([temptempcell{p,1}(1,1:2),temptempcell{p,2}(1,1:2)])];
                %%
                writeobj = VideoWriter([savedir,'\',savevideoname]);
                open(writeobj)
                %% show movevments in frames
                for q = framerange(1):framerange(2)
                    %%
                    showtext1 = sprintf('%s',['frame: ',num2str(q),', GC: ',num2str(gc)]);
                    showtext2 = sprintf('%s',[refname,' - L2: ',...
                        label_list_L2{refL2(1,q)},'(',num2str(refL2(1,q)),')']);
                    showtext3 = sprintf('%s',[matchname,' - L2: ',...
                        label_list_L2{matchL2(1,q)},'(',num2str(matchL2(1,q)),')']);
                    %
                    textcolor1 = 'yellow';
                    if q>=temptempcell{p,1}(1,1)&&q<=temptempcell{p,1}(1,2)
                        textcolor2 = 'red';
                    else
                        textcolor2 = 'yellow';
                    end
                    if q>=temptempcell{p,2}(1,1)&&q<=temptempcell{p,2}(1,2)
                        textcolor3 = 'green';
                    else
                        textcolor3 = 'yellow';
                    end
                    %
                    textlocation1 = [0,0];
                    textlocation2 = [0,50];
                    textlocation3 = [0,100];
                    textsize = 20;
                    textstr = {showtext1,showtext2,showtext3};
                    textpos = [textlocation1;textlocation2;textlocation3];
                    box_color = {textcolor1,textcolor2,textcolor3};
                    text_color = 'white';
                    %% insert text
                    frame = read(vidobj,q);
                    %%
                    RGB = insertText(frame,textpos,textstr,'FontSize',textsize,'BoxColor',...
                        box_color,'BoxOpacity',0.4,'TextColor',text_color);
                    writeVideo(writeobj,RGB);
%                     imshow(RGB)
%                     title(q)
%                     pause(0.00000001)
                end
                close(writeobj)
%                 pause
            end
        end
    end
    disp(m)
end



























