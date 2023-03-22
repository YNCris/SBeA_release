%{
    show GT on pairr24m dataset behavior atlas
%}
clear all
close all
%% set path
rootpath = 'Z:\hanyaning\multi_mice_test\Social_analysis\data\sbea_validation\sbea_20221114';
rec_path = [rootpath,'\recluster_data'];
label_path = [rootpath,'\social_labels'];
sub_label_path = [rootpath,'\sub_social_labels'];
%% load data
load([rec_path,'\SBeA_data_sample_cell_20221202.mat']);
fileFolder = fullfile(label_path);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
socialnames = {dirOutput.name}';
label_cell = cell(size(socialnames,1),3);
for k = 1:size(label_cell,1)
    tempdata = load([label_path,'\',socialnames{k,1}]);
    tempsubdata = load([sub_label_path,'\',socialnames{k,1}]);
    label_cell{k,1} = socialnames{k,1}(1,1:(end-4));
    label_cell{k,2} = tempdata.social_labels(1:4:end,:);
    label_cell{k,3} = tempsubdata.sub_social_labels(1:4:end,:);
end
%% create label_sample_cell
label_sample_list = zeros(size(data_sample_cell,1),1);
for k = 1:size(data_sample_cell,1)
    %% load name
    tempname = data_sample_cell{k,3};
    splname = split(tempname,'_');
    dataname = splname{3};
    %% sel data
    selidx = find(strcmp(dataname,label_cell(:,1)));
    sellabel = label_cell{selidx,2};
    sellabel(isnan(sellabel)) = 0;
    %% sel seg label
    start_idx = data_sample_cell{k,2}(1,1);
    end_idx = data_sample_cell{k,2}(1,2);
    templabel = mode(sellabel(start_idx:end_idx));
    label_sample_list(k,1) = templabel;
end
%% create sub_label_sample_cell
sub_label_sample_list = zeros(size(data_sample_cell,1),1);
for k = 1:size(data_sample_cell,1)
    %% load name
    tempname = data_sample_cell{k,3};
    splname = split(tempname,'_');
    dataname = splname{3};
    %% sel data
    selidx = find(strcmp(dataname,label_cell(:,1)));
    sellabel = label_cell{selidx,3};
    sellabel(isnan(sellabel)) = 0;
    %% sel seg label
    start_idx = data_sample_cell{k,2}(1,1);
    end_idx = data_sample_cell{k,2}(1,2);
    templabel = mode(sellabel(start_idx:end_idx));
    sub_label_sample_list(k,1) = templabel;
end
%% show social label
cmap = [0.7,0.7,0.7;
        1,0,0;
        0,1,0;
        0,0,1;
        1,1,0];
cmaplist = zeros(size(label_sample_list,1),3);
for k = 1:size(cmaplist,1)
    cmaplist(k,:) = cmap(label_sample_list(k)+1,:);
end
% create embedding
embedding = cell2mat(data_sample_cell(:,9));
% show scatter
figure
subsize = 10;
scatter(embedding(1:subsize:end,1),embedding(1:subsize:end,2),...
    3*ones(size(embedding(1:subsize:end,:),1),1),...
    cmaplist(1:subsize:end,:),'filled');
%% show sublabel
unique_label = unique(sub_label_sample_list);
cmap = jet(size(unique_label,1));
cmaplist = zeros(size(sub_label_sample_list,1),3);
for k = 1:size(cmaplist,1)
%     if round(sub_label_sample_list(k)/100) == ...
%             (sub_label_sample_list(k)-round(sub_label_sample_list(k)/100)*100)
    cmaplist(k,:) = cmap(sub_label_sample_list(k)==unique_label,:);
%     else
%         cmaplist(k,:) = [0.7,0.7,0.7];
%     end
end
% create embedding
embedding = cell2mat(data_sample_cell(:,9));
% show scatter
figure
subsize = 1;
scatter(embedding(1:subsize:end,1),embedding(1:subsize:end,2),...
    3*ones(size(embedding(1:subsize:end,:),1),1),...
    cmaplist(1:subsize:end,:),'filled');
%% show sublabel one by one
unique_label = unique(sub_label_sample_list);
cmap = jet(size(unique_label,1));
cmaplist = zeros(size(sub_label_sample_list,1),3);
for k = 1:size(cmaplist,1)
    cmaplist(k,:) = cmap(sub_label_sample_list(k)==unique_label,:);
end
% create embedding
embedding = cell2mat(data_sample_cell(:,9));
% show scatter
for k = 1:size(unique_label,1)
    new_cmaplist = cmaplist;
    new_cmaplist(sub_label_sample_list~=unique_label(k),1) = 0.7;
    new_cmaplist(sub_label_sample_list~=unique_label(k),2) = 0.7;
    new_cmaplist(sub_label_sample_list~=unique_label(k),3) = 0.7;
    subsize = 1;
    scatter(embedding(1:subsize:end,1),embedding(1:subsize:end,2),...
        3*ones(size(embedding(1:subsize:end,:),1),1),...
        new_cmaplist(1:subsize:end,:),'filled');
    title([num2str(k),': ',num2str(unique_label(k))])
    pause
end
%% show idx scatter
unique_name = unique(data_sample_cell(:,3));
cmap = jet(length(unique_name));
cmaplist = zeros(size(data_sample_cell,1),3);
for k = 1:size(unique_name,1)
    selidx = strcmp(data_sample_cell(:,3),unique_name{k});
    cmaplist(selidx,:) = ones(sum(selidx),1)*cmap(k,:);
end
%% show scatter
scatter(embedding(:,1),embedding(:,2),...
    3*ones(size(embedding,1),1),cmaplist,'filled');
%% show peridx scatter
unique_name = unique(data_sample_cell(:,3));
cmap = jet(length(unique_name));
for k = 1:size(unique_name,1)
    cmaplist = 0.7*ones(size(data_sample_cell,1),3);
    selidx = strcmp(data_sample_cell(:,3),unique_name{k});
    cmaplist(selidx,:) = ones(sum(selidx),1)*cmap(k,:);
    %% show scatter
    scatter(embedding(:,1),embedding(:,2),...
        3*ones(size(embedding,1),1),cmaplist,'filled');
    title(k)
%     pause
end
%% calculate speed map
figure
zscore_embed = cell2mat(data_sample_cell(:,4));
speedlist = medfilt1(cellfun(@(x) mean(sqrt(x(1,:).^2+x(2,:).^2)),data_sample_cell(:,6)),30);
normspeedlist = round(mat2gray(speedlist)*255+1);
cmap = jet(256);
cmaplist = cmap(normspeedlist,:);
scatter(zscore_embed(:,1),zscore_embed(:,2),10*ones(size(zscore_embed,1),1),cmaplist,'filled');
axis square
title('speed map')
%% calculate dist map
figure
distlist = medfilt1(cellfun(@(x) min(x(:)),data_sample_cell(:,7)),3);
normdistlist = round(mat2gray(distlist)*255+1);
cmap = turbo(256);
cmaplist = cmap(normdistlist,:);
scatter(zscore_embed(:,1),zscore_embed(:,2),10*ones(size(zscore_embed,1),1),cmaplist,'filled');
axis square
title('dist map')
%% calculate length map
lengthlist = cellfun(@(x) size(x,2),data_sample_cell(:,1));
unique_length = unique(lengthlist);
cmap = jet(length(unique_length));
cmaplist = zeros(size(data_sample_cell,1),3);
for k = 1:size(unique_length,1)
    selidx = unique_length(k)==lengthlist;
    cmaplist(selidx,:) = ones(sum(selidx),1)*cmap(k,:);
end
scatter(embedding(:,1),embedding(:,2),...
    3*ones(size(embedding,1),1),cmaplist,'filled');



























