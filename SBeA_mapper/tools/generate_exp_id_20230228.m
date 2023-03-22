%{
    生成20230228实验随机数据
%}
clear all
close all
%% set parameters
KO_mice = [4,58,59,5,56,43];
WT_mice = [83,17,2,98,40,...
           60,55,3,42,16];
all_mice = [KO_mice,WT_mice];
%% generate groups
group_repeat = 10;
all_KO_group = cell(group_repeat,2);
all_WT_group = cell(group_repeat,2);
KO_1_group = cell(group_repeat,2);
KO_2_group = cell(group_repeat,2);
group_num = 5;
rand('seed',1234)
for k = 1:group_repeat
    %%
    rand_KO = randperm(length(KO_mice));
    sel_rand_KO = rand_KO(1:group_num);
    all_KO_group{k,1} = KO_mice(sel_rand_KO);
    %%
    rand_WT = randperm(length(WT_mice));
    sel_rand_WT = rand_WT(1:group_num);
    all_WT_group{k,2} = WT_mice(sel_rand_WT);
    %%
    rand_KO = randperm(length(KO_mice));
    rand_WT = randperm(length(WT_mice));
    sel_rand_KO = rand_KO(1);
    sel_rand_WT = rand_WT(1:4);
    KO_1_group{k,1} = KO_mice(sel_rand_KO);
    KO_1_group{k,2} = WT_mice(sel_rand_WT);
    %%
    rand_KO = randperm(length(KO_mice));
    rand_WT = randperm(length(WT_mice));
    sel_rand_KO = rand_KO(1:2);
    sel_rand_WT = rand_WT(1:3);
    KO_2_group{k,1} = KO_mice(sel_rand_KO);
    KO_2_group{k,2} = WT_mice(sel_rand_WT);
end
%% calculate time
group_each_time = 15;%min
id_each_time = 15;%min
id_all_time = id_each_time*(length(KO_mice)+length(WT_mice));
group_all_time = group_each_time*group_repeat*4;
all_time = group_all_time+id_all_time;
%% random
rand('seed',1234)
all_group = [all_KO_group;all_WT_group;...
             KO_1_group;KO_2_group];
rand_idx = randperm(size(all_group,1));
all_rand_group = all_group(rand_idx,:);
%% output end experiments idx
rand('seed',1234)
day1_id = all_mice(randperm(16))';
day2_id = all_mice(randperm(16))';
day1_social = all_rand_group(1:20,:);
day2_social = all_rand_group(21:40,:);




















