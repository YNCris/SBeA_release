%% 读取数据
tic
tempHBT = cell(10,1);
for k = 1:size(tempHBT,1)
    tempHBT{k,1} = load([filepath,'\',fileNames{k,1}]);
    toc
end
toc
%% 筛数据[75,600,75,50,75,115,70]
for k = 1:27000
    XYZ1 = tempHBT2.HBT.HBT_DecData.XY(:,k);
    plot_align_skl(XYZ1,'*r','r')
    axis([-100,150,-150,150])
    title(k)
    view(2)
    pause(0.00000001)
end
%%
subplot(121)
%% 显示
HBT_num1 = 75;
HBT_num2 = 600;
XYZ1 = tempHBT1.HBT.HBT_DecData.XY(:,HBT_num1);
plot_align_skl(XYZ1,'*r','r')
view(2)
hold on
XYZ2 = tempHBT2.HBT.HBT_DecData.XY(:,HBT_num2);
plot_align_skl(XYZ2,'ob','b')
 axis([-100,150,-100,100])
view(2)
hold off
%%
subplot(122)
%% 校正显示
HBT_num1 = 75;
HBT_num2 = 600;
corr_param = 1.15;
XYZ1 = tempHBT1.HBT.HBT_DecData.XY(:,HBT_num1);
plot_align_skl(XYZ1,'*r','r')
view(2)
hold on
XYZ2 = corr_param*tempHBT2.HBT.HBT_DecData.XY(:,HBT_num2);
plot_align_skl(XYZ2,'ob','b')
axis([-100,150,-100,100])
view(2)
hold off
%% 自动确定老鼠大小的分布
median_index_list = zeros(size(tempHBT,1),1);
for k = 1:size(tempHBT,1)
    temp_XYZ = tempHBT{k,1}.HBT.HBT_DecData.XY;
    body_size = (temp_XYZ(40,:).^2+temp_XYZ(41,:).^2+temp_XYZ(42,:).^2).^0.5;
    median_index_list(k,1) = median(body_size);
    %% 显示
    figure
    hist(body_size,256)
    hold on
    plot([median_index_list(k,1),median_index_list(k,1)],[0,400],'r')
    hold off
    title(fileNames{k,1})
end
%% 计算校正系数
stand_length = 25;%校正标准长度
corr_prop = stand_length./median_index_list;
%% 校正显示
HBT_num = [1,1,1,1,1,1,1,1,1,1];
plotstr = mat2gray(rand([10,3]));
linestr = plotstr;
subplot(121)
for k = 1:size(HBT_num,2)
    XYZ = corr_prop(k,1)*tempHBT{k,1}.HBT.HBT_DecData.XY(:,HBT_num(1,k));
    plot_align_skl(XYZ,plotstr(k,:),linestr(k,:))
    hold on
end
axis([-100,150,-100,100])
view(2)
hold off
%% 未校正显示
HBT_num = [1,1,1,1,1,1,1,1,1,1];
plotstr = mat2gray(rand([10,3]));
linestr = plotstr;
subplot(122)
for k = 1:size(HBT_num,2)
    XYZ = tempHBT{k,1}.HBT.HBT_DecData.XY(:,HBT_num(1,k));
    plot_align_skl(XYZ,plotstr(k,:),linestr(k,:))
    hold on
end
axis([-100,150,-100,100])
view(2)
hold off
%% 校正统计
median_index_list = zeros(size(tempHBT,1),1);
for k = 1:size(tempHBT,1)
    %% 显示
    subplot(2,10,k)
    temp_XYZ = corr_prop(k,1)*tempHBT{k,1}.HBT.HBT_DecData.XY;
    body_size = (temp_XYZ(40,:).^2+temp_XYZ(41,:).^2+temp_XYZ(42,:).^2).^0.5;
    median_index_list(k,1) = median(body_size);
    hist(body_size,256)
    hold on
    plot([median_index_list(k,1),median_index_list(k,1)],[0,400],'r')
    axis([0,50,0,600])
    hold off
    subplot(2,10,10+k)
    temp_XYZ = tempHBT{k,1}.HBT.HBT_DecData.XY;
    body_size = (temp_XYZ(40,:).^2+temp_XYZ(41,:).^2+temp_XYZ(42,:).^2).^0.5;
    median_index_list(k,1) = median(body_size);
    hist(body_size,256)
    hold on
    plot([median_index_list(k,1),median_index_list(k,1)],[0,400],'r')
    axis([0,50,0,600])
    hold off
    title(fileNames{k,1})
end














