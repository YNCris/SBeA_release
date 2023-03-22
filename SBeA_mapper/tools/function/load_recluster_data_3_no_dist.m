function  [ReMap_move_cell,Seglist_move_cell,...
    ReMap_speed_cell,Seglist_speed_cell,...
    fs,...
    data_move_cell,data_speed_cell] = ...
    load_recluster_data_3_no_dist(SBeA_struct_path,fileNames,save_path,load_flag)
tic
if load_flag
    ReMap_move_cell = cell(size(fileNames,1),1);
    Seglist_move_cell = cell(size(fileNames,1),1);
    ReMap_speed_cell = cell(size(fileNames,1),1);
    Seglist_speed_cell = cell(size(fileNames,1),1);
    data_move_cell = cell(size(fileNames,1),1);
    data_speed_cell = cell(size(fileNames,1),1);
    for k = 1:size(fileNames,1)
        %% load data
        tempdata = load([SBeA_struct_path,'\',fileNames{k,1}]);
        %%
        fs = tempdata.SBeA.DataInfo.fs;
        ReMap_move_cell{k,1} = tempdata.SBeA.SBeA_DecData.L2.ReMap;
        Seglist_move_cell{k,1} = tempdata.SBeA.SBeA_DecData.L2.Seglist;
        ReMap_speed_cell{k,1} = tempdata.SBeA.SBeA_DecData_speed.L2.ReMap;
        Seglist_speed_cell{k,1} = tempdata.SBeA.SBeA_DecData_speed.L2.Seglist;
        data_move_cell{k,1} = tempdata.SBeA.RawData.selseg;
        data_speed_cell{k,1} = cell2mat(tempdata.SBeA.RawData.speed);
        disp(k)
        toc
    end
save([save_path,'\recluster_data_test20220607.mat'],...
    'ReMap_move_cell','Seglist_move_cell',...
    'ReMap_speed_cell','Seglist_speed_cell',...
    'fs',...
    'data_move_cell','data_speed_cell');
else
    load([save_path,'\recluster_data_test20220607.mat']);
end
toc