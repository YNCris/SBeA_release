function social_behavior_decomposing_big_data_no_dist(SBeA)
%{
    social behavior decomposing
%}
%%
global SBeA
para = SBeA.Param.segpar;
seglist = SBeA.RawData.selseg;
speedlist = cell2mat(SBeA.RawData.speed);
distlist = SBeA.RawData.dist_body;
%% create data batch
batch_len = SBeA.Param.batch.batch_length;
batch_num = size(seglist,2)/batch_len;
batch_seglist = cell(batch_num,1);
batch_speedlist = cell(batch_num,1);
batch_distlist = cell(batch_num,1);
for k = 1:batch_num
    batch_seglist{k,1} = seglist(:,...
        ((k-1)*batch_len+1):(k*batch_len));
    batch_speedlist{k,1} = speedlist(:,...
        ((k-1)*batch_len+1):(k*batch_len));
    batch_distlist{k,1} = distlist(:,...
        ((k-1)*batch_len+1):(k*batch_len));
end
%% body seg
batch_BeA_DecData = cell(size(batch_seglist));
for k = 1:batch_num
    batch_BeA_DecData{k,1} = ...
        behavior_decomposing_general(para,batch_seglist{k,1});
end
%% append BeA_DecData
BeA_DecData = merge_BeA_DecData(batch_BeA_DecData,batch_num,batch_len);
SBeA.SBeA_DecData = BeA_DecData;
%% speed seg
batch_BeA_DecData = cell(size(batch_speedlist));
for k = 1:batch_num
    batch_BeA_DecData{k,1} = ...
        behavior_decomposing_general(para,batch_speedlist{k,1});
end
%% append BeA_DecData
BeA_DecData = merge_BeA_DecData(batch_BeA_DecData,batch_num,batch_len);
SBeA.SBeA_DecData_speed = BeA_DecData;
% %% distance seg
% batch_BeA_DecData = cell(size(batch_distlist));
% for k = 1:batch_num
%     batch_BeA_DecData{k,1} = ...
%         behavior_decomposing_general(para,batch_distlist{k,1});
% end
% %% append BeA_DecData
% BeA_DecData = merge_BeA_DecData(batch_BeA_DecData,batch_num,batch_len);
% SBeA.SBeA_DecData_dist = BeA_DecData;






























