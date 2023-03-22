%{
    compare the precision of deeplabcut
    indexes:
    1. error of pixels without id of different body parts
    2. error of pixels with id of different body parts
%}
clear all
close all
%% set path
gtpath = 'F:\multi_mice_test\Social_analysis\methods_compare\data\gt_data';
slppath = 'F:\multi_mice_test\Social_analysis\methods_compare\data\pred_sleap';
savepath = 'F:\multi_mice_test\Social_analysis\methods_compare\data\save_data';
%% load gt
fileFolder = fullfile(gtpath);
dirOutput = dir(fullfile(fileFolder,'*.avi'));
gtvideonames = {dirOutput.name}';
%% compare data
err_id_cell = cell(size(gtvideonames,1),2);
err_nid_cell = cell(size(gtvideonames,1),2);
for k = 1:size(gtvideonames,1)
    %%
    tempname = gtvideonames{k,1}(1,1:(end-4));
    err_nid_cell{k,1} = tempname;
    err_id_cell{k,1} = tempname;
    %% load gt data
    single_1_csv = importdata([gtpath,'\single_1_',tempname,'.csv']);
    single_2_csv = importdata([gtpath,'\single_2_',tempname,'.csv']);
    single_1_data = single_1_csv.data;
    single_1_data(:,1) = [];
    single_1_data(:,3:3:end) = [];
    single_2_data = single_2_csv.data;
    single_2_data(:,1) = [];
    single_2_data(:,3:3:end) = [];
    %% load slp data
    temp_points = h5read([slppath,'\',tempname,'.slp'],'/pred_points');
    temp_instances = h5read([slppath,'\',tempname,'.slp'],'/instances');
    temp_frames = h5read([slppath,'\',tempname,'.slp'],'/frames');
    %% transform data form
    temp_cell = cell(size(temp_instances.frame_id,1),2);
    for m = 1:size(temp_cell,1)
        %%
        temp_cell{m,1} = temp_instances.frame_id(m,1);
        %%
        start_cursor = (m-1)*16+1;
        end_cursor = m*16;
        tempx = temp_points.x(start_cursor:end_cursor,1)';
        tempy = temp_points.y(start_cursor:end_cursor,1)';
        tempxy = zeros(1,size(tempx,2)*2);
        tempxy(1,1:2:end) = tempx;
        tempxy(1,2:2:end) = tempy;
        temp_cell{m,2} = tempxy;
    end
    score_mat = zeros(size(single_1_data,1),10);
    new_cell = cell(size(single_1_data,1),10);
    new_cell = cellfun(@(x) [x,NaN(1,32)],new_cell,'UniformOutput',false);
    new_cell(:,1) = num2cell(0:(size(single_1_data,1)-1));
    tempcur = 1;
    for m = 1:size(new_cell,1)
        %%
        for n = 1:(size(new_cell,2)-1)
            if new_cell{m,1} == temp_cell{tempcur,1}
                new_cell{m,n+1} = temp_cell{tempcur,2};
                score_mat(m,n) = temp_instances.score(tempcur,1);
                tempcur = tempcur+1;
            else
                new_cell{m,n+1} = NaN(size(temp_cell{tempcur,2}));
            end
            if tempcur>size(temp_cell,1)
                break;
            end
        end
        if tempcur>size(temp_cell,1)
            break;
        end
    end
    new_data = zeros(size(new_cell,1),64);
    for m = 1:size(new_data,1)
        %%
        [~,sortscoreidx] = sort(score_mat(m,:),'descend');
        %%
        new_data(m,:) = [new_cell{m,sortscoreidx(1)+1},new_cell{m,sortscoreidx(2)+1}];
    end
    %%
    slpdata = fillmissing(new_data,'nearest');
    dlc_1_data = slpdata(:,1:32);
    dlc_2_data = slpdata(:,33:end);
    %% calculate error without id
    dlc_1_x = dlc_1_data(:,1:2:end);
    dlc_1_y = dlc_1_data(:,2:2:end);
    dlc_2_x = dlc_2_data(:,1:2:end);
    dlc_2_y = dlc_2_data(:,2:2:end);
    single_1_x = single_1_data(:,1:2:end);
    single_1_y = single_1_data(:,2:2:end);
    single_2_x = single_2_data(:,1:2:end);
    single_2_y = single_2_data(:,2:2:end);
    errlist_nid = zeros(size(single_1_data,1),size(dlc_1_data,2));
    for m = 1:size(single_1_data,1)
        %%
        err_1 = sqrt(sum((dlc_1_data(m,:)-single_1_data(m,:)).^2))+...
            sqrt(sum((dlc_2_data(m,:)-single_2_data(m,:)).^2));
        err_2 = sqrt(sum((dlc_2_data(m,:)-single_1_data(m,:)).^2))+...
            sqrt(sum((dlc_1_data(m,:)-single_2_data(m,:)).^2));
        if err_2<err_1
            errlist_nid(m,:) = ...
                [sqrt((dlc_2_x(m,:)-single_1_x(m,:)).^2+(dlc_2_y(m,:)-single_1_y(m,:)).^2),...
                sqrt((dlc_1_x(m,:)-single_2_x(m,:)).^2+(dlc_1_y(m,:)-single_2_y(m,:)).^2)];
        else
            errlist_nid(m,:) = ...
                [sqrt((dlc_1_x(m,:)-single_1_x(m,:)).^2+(dlc_1_y(m,:)-single_1_y(m,:)).^2),...
                sqrt((dlc_2_x(m,:)-single_2_x(m,:)).^2+(dlc_2_y(m,:)-single_2_y(m,:)).^2)];
        end
    end
    %% calculate error with id
    err_1 = sum(sqrt(sum((dlc_1_data-single_1_data).^2,2)))+...
        sum(sqrt(sum((dlc_2_data-single_2_data).^2,2)));
    err_2 = sum(sqrt(sum((dlc_2_data-single_1_data).^2,2)))+...
        sum(sqrt(sum((dlc_1_data-single_2_data).^2,2)));
    if err_1<err_2
        errlist_id = ...
            [sqrt((dlc_1_x-single_1_x).^2+(dlc_1_y-single_1_y).^2),...
                sqrt((dlc_2_x-single_2_x).^2+(dlc_2_y-single_2_y).^2)];
    else
        errlist_id = ...
            [sqrt((dlc_2_x-single_1_x).^2+(dlc_2_y-single_1_y).^2),...
                sqrt((dlc_1_x-single_2_x).^2+(dlc_1_y-single_2_y).^2)];
    end
    %% save data
    err_id_cell{k,2} = errlist_id;
    err_nid_cell{k,2} = errlist_nid;
end
%% save
save([savepath,'\slp_err_id_cell.mat'],'err_id_cell');
save([savepath,'\slp_err_nid_cell.mat'],'err_nid_cell');
disp('save finished!')
































