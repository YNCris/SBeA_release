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
dlcpath = 'F:\multi_mice_test\Social_analysis\methods_compare\data\pred_dlc';
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
    %% load dlc data
    dlc_csv = importdata([dlcpath,'\',tempname,'DLC_dlcrnetms5_SBeA_cmpMay5shuffle1_1030000_el.csv']);
    %% sep data
    temp_dlc_csv_data = dlc_csv.data;
    temp_dlc_csv_data(:,1) = [];
    temp_dlc_csv_data(:,3:3:end) = [];
    dlc_csv_data = fillmissing(temp_dlc_csv_data,'nearest');
    dlc_1_data = dlc_csv_data(:,1:32);
    dlc_2_data = dlc_csv_data(:,33:end);
    %% calculate error without id
    dlc_1_x = dlc_1_data(:,1:2:end);
    dlc_1_y = dlc_1_data(:,2:2:end);
    dlc_2_x = dlc_2_data(:,1:2:end);
    dlc_2_y = dlc_2_data(:,2:2:end);
    single_1_x = single_1_data(:,1:2:end);
    single_1_y = single_1_data(:,2:2:end);
    single_2_x = single_2_data(:,1:2:end);
    single_2_y = single_2_data(:,2:2:end);
    errlist_nid = zeros(size(single_1_data,1),size(dlc_csv_data,2)/2);
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
save([savepath,'\dlc_err_id_cell.mat'],'err_id_cell');
save([savepath,'\dlc_err_nid_cell.mat'],'err_nid_cell');
disp('save finished!')































