%{
    实验乱序脚本
%}
mouse_id_list = 1:10;
mouse_KO = nchoosek(1:5,2);
mouse_WT = nchoosek(6:10,2);
mouse_KOWT = [...
    1,10
    3,10
    2,9
    4,9
    5,8
    1,8
    2,7
    4,7
    3,6
    5,6];
mouse_all = [mouse_KO;mouse_WT;mouse_KOWT];
for k = 2000:10000
    rand('seed',k)
    mouse_rand_all = mouse_all(randperm(30),:);
    diff_ma = abs(diff(mouse_rand_all));
    if min(unique(diff_ma))~=0
        disp(k)
        disp(mouse_rand_all)
        break
    end
end