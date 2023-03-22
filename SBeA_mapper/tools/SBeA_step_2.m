%{
    2. extraction of social dialog boxes
%}
clear all
close all
genPath = genpath('./');
addpath(genPath)
%% set path
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\recluster_data'];
filename = {'feat_cell.mat','GC_cell.mat','l3tol2_cell.mat','Group_GC.mat'};
savepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\recluster_data'];
%% load data
for k = 1:length(filename)
    load([filepath,'\',filename{k}])
end
%% social dialog boxes extracting of each video
dialog_box_cell = cell(size(group_GC,1),2);
all_corr_cell = cell(size(group_GC,1),2);
for k = 1:size(dialog_box_cell,1)
    %% load GC
    tempGC = GC_cell{group_GC{k,4},2};
    mov_num = size(tempGC,1)/2;
    gcmat1 = tempGC(1:mov_num,(mov_num+1):end);
    gcmat2 = tempGC((mov_num+1):end,1:mov_num);
    gcmat_cell = {gcmat1,gcmat2};
    %% load L2
    templ2_1 = cellfun(@transpose,l3tol2_cell{k,1}(:,2),'UniformOutput',false);
    templ2_2 = cellfun(@transpose,l3tol2_cell{k,2}(:,2),'UniformOutput',false);
    L2_1 = cell2mat(templ2_1)';
    L2_2 = cell2mat(templ2_2)';
    %% load L3
    L3_1 = l3tol2_cell{k,1}(:,1:2);
    L3_2 = l3tol2_cell{k,2}(:,1:2);
    %% extract L2 GC pos
    corr_cell = cell(1,size(dialog_box_cell,2));
    for m = 1:size(dialog_box_cell,2)
        %% GC to corr list
        gcmat = gcmat_cell{m};
        [pos_r,pos_w] = find(gcmat~=0);
        corr_list = [pos_r,pos_w];
        tempgc = zeros(size(corr_list,1),1);
        for n = 1:size(corr_list,1)
            tempgc(n,1) = gcmat(corr_list(n,1),corr_list(n,2));
        end
        corr_gc_list = [corr_list,tempgc];
        corr_cell{1,m} = corr_gc_list;
%         %% temp show
%         if m == 1
%             for n = 1:size(corr_gc_list,1)
%                 %%
%                 show_L2_1 = L2_1 == corr_gc_list(n,1);
%                 show_L2_2 = L2_2 == corr_gc_list(n,2);
%                 figure
%                 subplot(211)
%                 stem(show_L2_1)
%                 title(corr_gc_list(n,1))
%                 subplot(212)
%                 stem(show_L2_2)
%                 title(corr_gc_list(n,2:3))
%             end
%         end
%         if m == 2
%             for n = 1:size(corr_gc_list,1)
%                 %%
%                 show_L2_2 = L2_2 == corr_gc_list(n,1);
%                 show_L2_1 = L2_1 == corr_gc_list(n,2);
%                 figure
%                 subplot(211)
%                 stem(show_L2_2)
%                 title(corr_gc_list(n,1))
%                 subplot(212)
%                 stem(show_L2_1)
%                 title(corr_gc_list(n,2:3))
%             end
%         end
    end
    all_corr_cell(k,:) = corr_cell;
    %% extract dialog boxes
    temp_dialog_box = cell(1,size(corr_cell,2));
    for m = 1:size(corr_cell,2)
        %%
        temp_corr = corr_cell{1,m};
        %% L3 detection
        if m == 1 
            L3_det = cell(size(temp_corr));
            L3_det(:,3) = num2cell(temp_corr(:,3));
            for n = 1:size(temp_corr,1)
                equal_L3_1 = cellfun(@(x)x==temp_corr(n,1),L3_1(:,2),'UniformOutput',false);
                sum_L3_1 = cellfun(@(x)sum(x),equal_L3_1,'UniformOutput',false);
                idx_L3_1 = cell2mat(sum_L3_1)>0;
                sel_L3_1 = L3_1(idx_L3_1==1,1);
                new_L3_1 = cellfun(@(x,y)[x,y],sel_L3_1,sum_L3_1(idx_L3_1==1,1),'UniformOutput',false);
                L3_det{n,1} = new_L3_1;

                equal_L3_2 = cellfun(@(x)x==temp_corr(n,2),L3_2(:,2),'UniformOutput',false);
                sum_L3_2 = cellfun(@(x)sum(x),equal_L3_2,'UniformOutput',false);
                idx_L3_2 = cell2mat(sum_L3_2)>0;
                sel_L3_2 = L3_2(idx_L3_2==1,1);
                new_L3_2 = cellfun(@(x,y)[x,y],sel_L3_2,sum_L3_2(idx_L3_2==1,1),'UniformOutput',false);
                L3_det{n,2} = new_L3_2;
            end
        end
        if m == 2 
            L3_det = cell(size(temp_corr));
            L3_det(:,3) = num2cell(temp_corr(:,3));
            for n = 1:size(temp_corr,1)
                equal_L3_1 = cellfun(@(x)x==temp_corr(n,1),L3_2(:,2),'UniformOutput',false);
                sum_L3_1 = cellfun(@(x)sum(x),equal_L3_1,'UniformOutput',false);
                idx_L3_1 = cell2mat(sum_L3_1)>0;
                sel_L3_1 = L3_2(idx_L3_1==1,1);
                new_L3_1 = cellfun(@(x,y)[x,y],sel_L3_1,sum_L3_1(idx_L3_1==1,1),'UniformOutput',false);
                L3_det{n,1} = new_L3_1;

                equal_L3_2 = cellfun(@(x)x==temp_corr(n,2),L3_1(:,2),'UniformOutput',false);
                sum_L3_2 = cellfun(@(x)sum(x),equal_L3_2,'UniformOutput',false);
                idx_L3_2 = cell2mat(sum_L3_2)>0;
                sel_L3_2 = L3_1(idx_L3_2==1,1);
                new_L3_2 = cellfun(@(x,y)[x,y],sel_L3_2,sum_L3_2(idx_L3_2==1,1),'UniformOutput',false);
                L3_det{n,2} = new_L3_2;
            end
        end
        temp_dialog_box{1,m} = L3_det;
    end
    dialog_box_cell(k,:) = temp_dialog_box;
end
%% create overlap_dialog_box
overlap_dialog_box_cell = cell(size(dialog_box_cell));
for m = 1:size(overlap_dialog_box_cell,1)
    for n = 1:size(overlap_dialog_box_cell,2)
        %%
        tempcell = dialog_box_cell{m,n};
        tempnewcell = cell(size(tempcell,1),2);
        tempnewcell(:,2) = tempcell(:,3);
        %%
        for k = 1:size(tempcell,1)
            %%
            temptempcell = {};
            for p = 1:size(tempcell{k,1},1)
                for q = 1:size(tempcell{k,2},1)
                    %%
                    L3_1 = tempcell{k,1}{p,1};
                    L3_2 = tempcell{k,2}{q,1};
                    %% 
                    if (L3_1(1,1)<L3_2(1,1))&&(L3_1(1,2)>L3_2(1,2)) || ...
                       (L3_2(1,1)<L3_1(1,1))&&(L3_2(1,2)>L3_1(1,2)) || ...
                       (L3_1(1,1)<L3_2(1,1))&&(L3_1(1,2)>L3_2(1,1)) || ...
                       (L3_2(1,1)<L3_1(1,1))&&(L3_2(1,2)>L3_1(1,1))
                        temptempcell = [temptempcell;{L3_1,L3_2}];
%                         disp('L3_1')
%                         disp(L3_1)
%                         disp('L3_2')
%                         disp(L3_2)
%                         disp('-------------------------')
                    end
                end
            end
            tempnewcell{k,1} = temptempcell;
        end
        overlap_dialog_box_cell{m,n} = tempnewcell;
    end
end
%% save data
save([savepath,'\dialog_box_cell.mat'],'dialog_box_cell');
save([savepath,'\overlap_dialog_box_cell.mat'],'overlap_dialog_box_cell');
disp('save successfully!')





























