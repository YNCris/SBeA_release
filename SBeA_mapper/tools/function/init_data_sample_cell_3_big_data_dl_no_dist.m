function [data_sample_cell,net,info] = ...
    init_data_sample_cell_3_big_data_dl_no_dist(savelist_cell,...
    data_move_cell,data_speed_cell,fileNames)
%% create data_sample_cell
data_sample_cell = [];
w_dist = 1;
for k = 1:size(savelist_cell,1)
    temp_savelist = savelist_cell{k,1};
    %%
    for m = 1:size(temp_savelist,1)
        tempmove = data_move_cell{k,1}(:,temp_savelist(m,1):temp_savelist(m,2));
        tempspeed = data_speed_cell{k,1}(:,temp_savelist(m,1):temp_savelist(m,2));
        tempdist = data_dist_cell{k,1}(:,temp_savelist(m,1):temp_savelist(m,2));

        tempsavelist = temp_savelist(m,:);
        tempsavelist(1,5) = m;
        tempfilename = fileNames{k,1};
        data_sample_cell = [data_sample_cell;...
            {tempsavelist,tempfilename,[],tempmove,tempspeed,tempdist,...
            [tempmove;tempspeed]}];
    end
end
%% seperate data
sel_len = 100000;
dist_all = cell2mat(data_sample_cell(:,end)')';
rng(1234)
randdata = randperm(size(dist_all,1));
sel_num = randdata(1:sel_len); 
sel_idx = zeros(size(dist_all,1),1);
sel_idx(sel_num) = 1;
sel_dist_all = dist_all(sel_idx==1,:);
left_dist_all = dist_all((~sel_idx)==1,:);
% DR distance
[~, umap, ~] = run_umap(sel_dist_all,'n_neighbors',199,'sgd_tasks',1,...
'min_dist',0.051,'metric','euclidean','n_components', 2, 'verbose', 'text');
embedding = umap.embedding;
selzsdatadist = zscore(embedding',[],2);
%% create dataset
valid_list = (1:5:size(selzsdatadist,2))';
XTrain = mat2gray(sel_dist_all);
YTrain = selzsdatadist';
% normalize
min_Y_1 = min(YTrain(:,1));
max_Y_1 = max(YTrain(:,1));
min_Y_2 = min(YTrain(:,2));
max_Y_2 = max(YTrain(:,2));
YTrain(:,1) = (YTrain(:,1)-min_Y_1)/(max_Y_1-min_Y_1);
YTrain(:,2) = (YTrain(:,2)-min_Y_2)/(max_Y_2-min_Y_2);
XValidation = XTrain(valid_list,:);
YValidation = YTrain(valid_list,:);
newXTrain = XTrain;
newYTrain = YTrain;
newXTrain(valid_list,:) = [];
newYTrain(valid_list,:) = [];
tempXTrain = cell(size(newXTrain,1),1);
tempYTrain = cell(size(newYTrain,1),1);
tempXValidation = cell(size(XValidation,1),1);
tempYValidation = cell(size(YValidation,1),1);
for k = 1:size(tempXTrain,1)
    tempXTrain{k,1} = newXTrain(k,:);
end
for k = 1:size(tempYTrain,1)
    tempYTrain{k,1} = newYTrain(k,:);
end
for k = 1:size(XValidation,1)
    tempXValidation{k,1} = XValidation(k,:);
end
for k = 1:size(YValidation,1)
    tempYValidation{k,1} = YValidation(k,:);
end
newXTrain = tempXTrain;
% newYTrain = tempYTrain;
XValidation = tempXValidation;
% YValidation = tempYValidation;
% create neural networks
res_head = [
    sequenceInputLayer(1,MinLength=16)
    convolution1dLayer(11,96)
    reluLayer
    globalMaxPooling1dLayer
%     bilstmLayer(128, OutputMode="last")
%     featureInputLayer(size(XTrain,2),'Name','input')
%     fullyConnectedLayer(128,'Name','fc1')
    batchNormalizationLayer('Name','bn1')
    reluLayer('Name','relu1')];

res_tail = [
    fullyConnectedLayer(2,'Name','fc2')
    sigmoidLayer('Name','sigmoid')
    regressionLayer
%     fullyConnectedLayer(2,'Name','fc3')
%     BinaryCrossEntropyLossLayer('output')
    ];

residualLayers = res_head;
res_block_num = 2;
neuron_num = 64;
for k = 1:res_block_num
    residualLayers = [
    residualLayers
    fullyConnectedLayer(neuron_num,'Name',['resblock',num2str(k),'-fc1'])
    batchNormalizationLayer('Name',['resblock',num2str(k),'-bn1'])
    reluLayer('Name',['resblock',num2str(k),'-relu1'])

    fullyConnectedLayer(neuron_num,'Name',['resblock',num2str(k),'-fc2'])
    additionLayer(2,'Name',['resblock',num2str(k),'-add'])
    batchNormalizationLayer('Name',['resblock',num2str(k),'-bn2'])
    reluLayer('Name',['resblock',num2str(k),'-relu2'])
    ];
end

residualLayers = [
    residualLayers
    res_tail];

residualLayers = layerGraph(residualLayers);
for k = 1:res_block_num
    residualLayers = addLayers(residualLayers,fullyConnectedLayer(neuron_num,...
        'Name',['resblock',num2str(k),'-fc-shortcut']));
end

residualLayers = connectLayers(residualLayers,'relu1','resblock1-fc-shortcut');

residualLayers = connectLayers(residualLayers,'resblock1-fc-shortcut','resblock1-add/in2');

for k = 2:res_block_num
    residualLayers = connectLayers(residualLayers,...
        ['resblock',num2str(k-1),'-relu2'],...
        ['resblock',num2str(k),'-fc-shortcut']);
    residualLayers = connectLayers(residualLayers,...
        ['resblock',num2str(k),'-fc-shortcut'],...
        ['resblock',num2str(k),'-add/in2']);
end

deepNetworkDesigner(residualLayers)


% numHiddenUnits = 1000;
% residualLayers = [
%     sequenceInputLayer(1,MinLength=16)
%     lstmLayer(numHiddenUnits, OutputMode="last")
%     lstmLayer(numHiddenUnits, OutputMode="last")
%     fullyConnectedLayer(2)
%     regressionLayer];
% deepNetworkDesigner(residualLayers)
%%
% Train Network settings
miniBatchSize = sel_len/100;
validationFrequency = 500;
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',100, ...
    'InitialLearnRate',1e-3, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XValidation,YValidation}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',true,...
    'Shuffle','every-epoch',...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',100,...
    'LearnRateDropFactor',0.9);
% trainNetwork
[net, info] = trainNetwork(newXTrain,newYTrain,residualLayers,options);
%% predict validation and all data
% tic
YValidationPredicted = predict(net,XValidation);
% toc
tempdistall = mat2gray(dist_all);
dist_all_cell = cell(size(tempdistall,1),1);
for k = 1:size(dist_all_cell,1)
    dist_all_cell{k,1} = tempdistall(k,:);
end
YallPredicted = predict(net,dist_all_cell);
%% show validation
ds_num = 10;
figure
plot(YValidationPredicted(1:ds_num:end,1),...
    YValidationPredicted(1:ds_num:end,2),'bo')
hold on
plot(YValidation(1:ds_num:end,1),...
    YValidation(1:ds_num:end,2),'ro')
hold on
line([YValidationPredicted(1:ds_num:end,1),YValidation(1:ds_num:end,1)]',...
    [YValidationPredicted(1:ds_num:end,2),YValidation(1:ds_num:end,2)]',...
    'Color','k')
title('red: raw, blue: predict, black line: pairs dots')
hold off
figure
plot(YallPredicted(1:1:end,1),...
    YallPredicted(1:1:end,2),'bo')
title('all data embedding')
%% show dist hist
figure
dist_hist = sqrt(sum((YValidationPredicted-YValidation).^2,2));
hist(dist_hist,128)
title('rmse distribution')
%% append data
zsdatadist = double(YallPredicted');
%% re-resize data
zsdatadist(1,:) = zsdatadist(1,:)*(max_Y_1-min_Y_1)+min_Y_1;
zsdatadist(2,:) = zsdatadist(2,:)*(max_Y_2-min_Y_2)+min_Y_2;
%% 
seglistall = cumsum(cellfun(@(x) size(x,2),data_sample_cell(:,4)));
startlistall = [1;seglistall(1:(end-1),1)+1];
endlistall = seglistall;
savelistall = [startlistall,endlistall];
%% append data
zs_cell = cell(size(data_sample_cell,1),1);
for k = 1:size(zs_cell,1)
    start_pos = savelistall(k,1);
    end_pos = savelistall(k,2);
    zs_cell{k,1} = [...
        zsdatadist(:,start_pos:end_pos)];
end
data_sample_cell = [zs_cell,data_sample_cell];

































