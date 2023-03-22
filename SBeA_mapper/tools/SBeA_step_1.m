%{
    1. L3 create and GC mat calculation
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% set path
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\recluster_data'];
filename = 'data_sample_cell.mat';
savepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\recluster_data'];
%% load data_sample_cell
load([filepath,'\',filename]);
%% separate social groups
temp_unique_name = unique(data_sample_cell(:,3));
sepfileNames = cell(size(temp_unique_name,1),2);
for k = 1:size(temp_unique_name,1)
    tempname = temp_unique_name{k,1};
    for m = 1:length(tempname)
        if strcmp(tempname(m),'-')
            cutfield = m-1;
        end
    end
    sepfileNames{k,1} = tempname(1:cutfield);
    sepfileNames{k,2} = tempname((cutfield+2):end);
end
social_name = cell(size(unique(sepfileNames(:,2)),1), ...
    (size(sepfileNames,1)/size(unique(sepfileNames(:,2)),1))+1);
social_name(:,1) = unique(sepfileNames(:,2));
for k = 1:size(sepfileNames,1)
    for m = 1:size(social_name,1)
        if strcmp(sepfileNames{k,2},social_name{m,1})
            for n = 2:3
                if isempty(social_name{m,n})
                    social_name{m,n} = sepfileNames{k,1};
                    break
                end
            end
            break
        end
    end
end
%% 1. repeat sequence detection by HACA seprately
%% set parameters
fs = 30;
redL = 5;
para.k = 20;
para.kF = 'f';
nMi = 100;%ms
nMa = 10000;%ms
para.nMi = round((fs*nMi/1000) / redL);
para.nMa = round((fs*nMa/1000) / redL);
para.ini = 'p';
para.nIni = 1;
para.kerType = 'g';
para.kerBand = 'nei';
para.sigma = 1;
%% calculate feature matrix then segment them
feat_cell = cell(size(social_name,1),2);
for m = 1:size(feat_cell,1)
    for n = 1:size(feat_cell,2)
        %% get embed
        dataname = [social_name{m,n+1},'-',social_name{m,1}];
        tempdata = data_sample_cell(strcmp(dataname,data_sample_cell(:,3)),:);
        embedtimelist = zeros(tempdata{end,2}(1,2),3);
        for k = 1:size(tempdata,1)
            embedtimelist(tempdata{k,2}(1,1):tempdata{k,2}(1,2),:) = ...
            ones((tempdata{k,2}(1,2)-tempdata{k,2}(1,1)+1),1)*tempdata{k,6};
        end
        resembed = embedtimelist(1:redL:end,:);
        %% calculate feature matrix
        featmat = squareform(pdist(resembed));
        K = conKnl_DTAK(featmat, para.kerType, para.kerBand, para.sigma);
%         figure
%         imagesc(K)
        %% segmentation
        seg0s = segIni(K, para(1));
        segDM = segAlg('haca', [], K, para, seg0s, []);
        %% save segmentations
        feat_cell{m,n} = segDM;
    end
    disp(m)
end
%% data transform
savelist_cell = cell(size(feat_cell));
for m = 1:size(savelist_cell,1)
    for n = 1:size(savelist_cell,2)
        tempsavelist = Gs2savelist(feat_cell{m,n});
        allsavelist = zeros(size(tempsavelist));
        allsavelist(:,1) = tempsavelist(:,1)*5-4;
        allsavelist(:,2) = tempsavelist(:,2)*5;
        allsavelist(:,3) = tempsavelist(:,3);
        savelist_cell{m,n} = allsavelist;
    end
end
l3tol2_cell = cell(size(savelist_cell));
for m = 1:size(l3tol2_cell,1)
    for n = 1:size(l3tol2_cell,2)
        %%
        tempsavelist = cell(size(savelist_cell{m,n},1),3);
        dataname = [social_name{m,n+1},'-',social_name{m,1}];
        tempdata = data_sample_cell(strcmp(dataname,data_sample_cell(:,3)),:);
        tempseglist = zeros(tempdata{1,2}(1,1),tempdata{end,2}(1,2));
        tempembed = zeros(tempdata{end,2}(1,2),3);
        for k = 1:size(tempdata,1)
            tempseglist(1,tempdata{k,2}(1,1):tempdata{k,2}(1,2)) = tempdata{k,2}(1,4);
            tempembed(tempdata{k,2}(1,1):tempdata{k,2}(1,2),:) = ...
                ones(tempdata{k,2}(1,2)-tempdata{k,2}(1,1)+1,1)*tempdata{k,6};
        end
        %%
        for k = 1:size(tempsavelist,1)
            tempsavelist{k,1} = savelist_cell{m,n}(k,:);
            tempsavelist{k,2} = tempseglist(1, ...
                tempsavelist{k,1}(1,1):tempsavelist{k,1}(1,2));
            tempsavelist{k,3} = tempembed(tempsavelist{k,1}(1,1):tempsavelist{k,1}(1,2),:);
        end
        l3tol2_cell{m,n} = tempsavelist;
    end
end
%% 2. GC calculation between two L2 list
%% select savelist_l2_cell
savelist_l2_cell = cell(size(feat_cell));
for m = 1:size(savelist_l2_cell,1)
    for n = 1:size(savelist_l2_cell,2)
        %%
        dataname = [social_name{m,n+1},'-',social_name{m,1}];
        tempdata = data_sample_cell(strcmp(dataname,data_sample_cell(:,3)),:);
        templist = cell2mat(tempdata(:,2));
        savelist_l2_cell{m,n} = templist(:,[1,2,4]);
    end
end
%% compress savelist
compress_savelist_cell = cell(size(savelist_l2_cell));
compress_size = 20;
for m = 1:size(compress_savelist_cell,1)
    for n = 1:size(compress_savelist_cell,2)
        %%
        tempsavelist = savelist_l2_cell{m,n};
        complist = floor([(tempsavelist(:,1)-1)/compress_size+1,...
                    tempsavelist(:,2)/compress_size,tempsavelist(:,3)]);
        compress_savelist_cell{m,n} = complist;
    end
end
%% 2. GC
% savelist to data_tensor[behavior,time,trials]
tempdata = cell2mat(data_sample_cell(:,2));
class_num = max(tempdata(:,4));
datamat_cell = cell(size(compress_savelist_cell));
for m = 1:size(compress_savelist_cell,1)
    for n = 1:size(compress_savelist_cell,2)
        tempsavelist = compress_savelist_cell{m,n};
        datamat_cell{m,n} = savelist2datamat(tempsavelist,class_num);
    end
end
%% cat data according to groups
group_GC = cell(size(datamat_cell,1),4);
group_GC(:,1:3) = social_name;
group_GC(:,4) = {3,3,3,4,4,1,1,1,2,2,2,4};
unique_group = unique(cell2mat(group_GC(:,4)));
data_tensor_cell = cell(size(unique_group,1),1);
for k = 1:size(data_tensor_cell,1)
    sel_data_cell = datamat_cell(cell2mat(group_GC(:,4))==unique_group(k),:);
    data_tensor = [];
    for m = 1:size(sel_data_cell,1)
        data_tensor = cat(3,data_tensor,[sel_data_cell{m,1};sel_data_cell{m,2}]);
    end
    data_tensor_cell{k,1} = data_tensor;
end
% %% cat data
% data_tensor = [];
% for k = 1:size(datamat_cell,1)
%     data_tensor = cat(3,data_tensor,[datamat_cell{k,1};datamat_cell{k,2}]);
% end
%% point process granger causality
GC_cell = cell(size(data_tensor_cell,1),2);
tic
for k = 1:size(GC_cell,1)
    data_tensor = data_tensor_cell{k,1};
    [results_gcause_mat, results_gcause_fdr] = calculate_granger_causality(data_tensor);
    GC_cell(k,:) = {results_gcause_mat, results_gcause_fdr};
    toc
end
%% save data
save([savepath,'\GC_cell.mat'],'GC_cell');
save([savepath,'\feat_cell.mat'],"feat_cell");
save([savepath,'\l3tol2_cell.mat'],'l3tol2_cell');
save([savepath,'\group_GC.mat'],'group_GC')
disp('save successfully!')
% %% temp show
% for m = 1:40
%     show_num = m;
%     show_cell = l3tol2_cell{1,1};
%     tempsavelist = cell2mat(show_cell(:,1));
%     tempidx = find(show_num == tempsavelist(:,3));
%     for k = 1:size(tempidx,1)
%         plot(show_cell{tempidx(k,1),2})
%         hold on
%     end
%     hold off
%     title(m)
%     pause
% end
% %% #############
% X = tsne(distmat_cell{1,1});
% Y = tsne(distmat_cell{1,1}');
% subplot(221)
% plot(X(:,1),X(:,2),'o')
% subplot(222)
% plot(Y(:,1),Y(:,2),'o')
% subplot(212)
% plot(X(:,1)-50,X(:,2),'bo')
% hold on
% plot(Y(:,1)+50,Y(:,2),'ro')
% hold on
% for k = 1:5:size(Y,1)
%     plot([X(k,1)-50,Y(k,1)+50],[X(k,2),Y(k,2)],'k-')
%     hold on
% end
% hold off
% %% temp show
% subplot(221)
% imagesc(GC_cell{1,2})
% title('SK-BL6')
% axis square
% subplot(222)
% imagesc(GC_cell{2,2})
% title('SK-129')
% axis square
% subplot(223)
% imagesc(GC_cell{3,2})
% title('SK-AJ')
% axis square
% subplot(224)
% imagesc(GC_cell{4,2})
% title('SK-W')
% axis square























