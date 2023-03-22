%{
    transfer sbmvis data to sleap data
%}
clear all
close all
%% set path and parameters
slppath = 'F:\multi_mice_test\Social_analysis\methods_compare\envs\sleap_20220505\labels.v000.slp';
vispath = 'F:\multi_mice_test\Social_analysis\methods_compare\data\raw_videos\train';
dlcimgpath = 'F:\multi_mice_test\Social_analysis\methods_compare\envs\SBeA_cmp-HYN-2022-05-05\labeled-data';
datalength = 200;
%% load namelist
fileFolder = fullfile(dlcimgpath);
dirOutput = dir(fullfile(fileFolder,'train*'));
dlcnames = {dirOutput.name}';
%% 
% h5disp(slppath)
%% load old h5 data
fileattrib(slppath,'+w');
plist = 'H5P_DEFAULT';
fid = H5F.open(slppath,'H5F_ACC_RDWR',plist);
disp(fid)
dset_id_points = H5D.open(fid,'/points');
dset_id_instances = H5D.open(fid,'/instances');
dset_id_frames = H5D.open(fid,'/frames');

temp_points = h5read(slppath,'/points');
temp_suggestions_json = h5read(slppath,'/suggestions_json');
temp_instances = h5read(slppath,'/instances');
temp_frames = h5read(slppath,'/frames');
%% create new h5 data
new_frames = temp_frames;
new_frames.frame_id = [0:(4*datalength-1)]';
new_frames.video = [ones(datalength,1)*0;ones(datalength,1)*1;ones(datalength,1)*2;ones(datalength,1)*3];
new_frames.frame_idx = [0:(datalength-1),0:(datalength-1),0:(datalength-1),0:(datalength-1)]';
new_frames.instance_id_start = new_frames.frame_id*2;
new_frames.instance_id_end = new_frames.instance_id_start+2;

new_instances = temp_instances;
new_instances.instance_id = [0:(8*datalength-1)]';
new_instances.instance_type = 0*new_instances.instance_id;
new_instances.frame_id = new_instances.instance_id;
new_instances.frame_id(1:2:end) = new_frames.frame_id;
new_instances.frame_id(2:2:end) = new_frames.frame_id;
new_instances.skeleton = new_instances.instance_type;
new_instances.track = new_instances.instance_type-1;
new_instances.from_predicted = new_instances.track;
new_instances.score = NaN(length(new_instances.from_predicted),1);
new_instances.point_id_start = new_instances.instance_id*16;
new_instances.point_id_end = new_instances.point_id_start+16;
new_instances.tracking_score = new_instances.score;

new_points = temp_points;
new_points.x = [];
new_points.y = [];
for k = 1:size(dlcnames,1)
    %% load single csv
    tempname = dlcnames{k,1};
    single_1_csvdata = importdata([vispath,'\single_1_',tempname,'.csv']);
    single_2_csvdata = importdata([vispath,'\single_2_',tempname,'.csv']);
    %% cas single 1 2
    casdata1 = single_1_csvdata.data;
    casdata2 = single_2_csvdata.data;
    casdata1(:,1:3:end) = [];
    casdata2(:,1:3:end) = [];
    casdata = [casdata1,casdata2];
    casdata_x = casdata(1:datalength,1:2:end);
    casdata_y = casdata(1:datalength,2:2:end);
    rescasdata_x = reshape(casdata_x',[],1);
    rescasdata_y = reshape(casdata_y',[],1);
    new_points.x = [new_points.x;rescasdata_x];
    new_points.y = [new_points.y;rescasdata_y];
end
new_points.visible = int8(0*new_points.x+1);
new_points.complete = int8(new_points.visible);
%% save new h5 data
H5D.set_extent(dset_id_points,length(new_points.visible))
H5D.set_extent(dset_id_instances,length(new_instances.score))
H5D.set_extent(dset_id_frames,length(new_frames.frame_id))
H5D.write(dset_id_points,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',plist,new_points)
H5D.write(dset_id_instances,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',plist,new_instances)
H5D.write(dset_id_frames,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',plist,new_frames)
H5D.close(dset_id_points);
H5D.close(dset_id_instances);
H5D.close(dset_id_frames);
H5F.close(fid);
% h5write(slppath,'/points',new_points);
% h5write(slppath,'/instances',new_instances);
% h5write(slppath,'/frames',new_frames);
disp('finished!')

















