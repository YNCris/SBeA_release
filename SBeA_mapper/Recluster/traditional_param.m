%{
    传统参数计算代码
%}
clear all
close all
%% 设置路径
filepath = 'Z:\hanyaning\HBT_3DF5\final_HBTStruct_20200616\HBT_Struct_30';
%% 读取数据(当前路径下所有的mat文件)
fileFolder = fullfile(filepath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}';
%% 加载数据
tempHBT = cell(size(fileNames));
for k = 1:size(fileNames,1)
    tempHBT{k,1} = load([filepath,'\',fileNames{k,1}]);
end
%% 构建传统参数cell
title_cell = {'文件名','轨迹','轨迹热图曲线','速度曲线','速度热图曲线原图',...
    '速度热图曲线','平均速度','活动量','平均运动能量','焦虑指数'};
%{文件名，轨迹，轨迹热图曲线，速度曲线，速度热图曲线，平均速度，活动量，平均运动能量，焦虑指数}
tradparam_cell = cell(size(fileNames,1),9);
%% 计算参数
Cent_num = 13;
for m = 1:size(fileNames,1)
    %%
    if true
%         %% 加载数据
%         tempHBT = load([filepath,'\',fileNames{m,1}]);
        %% 数据赋值
        tempX = tempHBT{m,1}.HBT.RawData.X;
        tempY = tempHBT{m,1}.HBT.RawData.Y;
        tempZ = tempHBT{m,1}.HBT.RawData.Z;
        %% 提取中心位置数据
        cent_X = tempX(:,Cent_num);
        cent_Y = tempY(:,Cent_num);
        %% 数据还原
        raw_cent_X = round(cent_X-min(cent_X)+1);
        raw_cent_Y = round(cent_Y-min(cent_Y)+1);
        %% 创建背景
        pos_x = raw_cent_X;
        pos_y = raw_cent_Y;
        speed = sqrt(([0;diff(pos_x)].^2)+([0;diff(pos_y)].^2))*30;
        size_bg = [max(pos_y),max(pos_x)];
        background = zeros(size_bg(1,1),size_bg(1,2));
        speed_background = zeros(size_bg(1,1),size_bg(1,2));
        for k = 2:size(pos_x,1)
            if abs(pos_x(k-1,1)-pos_x(k,1))>0|...
                    abs(pos_y(k-1,1)-pos_y(k,1))>0
                speed_background = DrawLineImageN(speed_background,pos_x(k-1,1),pos_y(k-1,1),pos_x(k,1),pos_y(k,1),speed(k,1));
                background = DrawLineImageN(background,pos_x(k-1,1),pos_y(k-1,1),pos_x(k,1),pos_y(k,1),1);
            end
           % disp(k) 
        end
        %% 抠出轨迹
        [x,y] = find(background>0);
        crop_background = background(min(x):max(x),min(y):max(y));
        %% 伪彩色处理
        % plot(part_result(:,1),part_result(:,4))
        deep_index = 0.7;
        temprgbim = fake_color(conv2(deep_index*crop_background,ones(3,3)));
        rgbim = temprgbim;
        for i = 1:size(temprgbim,1)
            for j = 1:size(temprgbim,2)
                    if((temprgbim(i,j,1) == 0)&(temprgbim(i,j,2) == 0)&(temprgbim(i,j,3) == 1))
                        rgbim(i,j,:) = 1;
                    end
            end
        end
        imshow(rgbim)
        %% 抠出轨迹，速度
        [x,y] = find(speed_background>0);
        crop_speed_background = speed_background(min(x):max(x),min(y):max(y))./...
            (background(min(x):max(x),min(y):max(y))+eps);
        %% 伪彩色处理
        % plot(part_result(:,1),part_result(:,4))
        deep_index = 1;%0.7
        temprgbim = fake_color(conv2(deep_index*crop_speed_background,ones(3,3)));
        speed_rgbim = temprgbim;
        for i = 1:size(temprgbim,1)
            for j = 1:size(temprgbim,2)
                    if((temprgbim(i,j,1) == 0)&(temprgbim(i,j,2) == 0)&(temprgbim(i,j,3) == 1))
                        speed_rgbim(i,j,:) = 1;
                    end
            end
        end
        imshow(speed_rgbim)
        %% 绘制热图
        k_size = 21;%12
        conv_k = conv2(ones(k_size,k_size),ones(k_size,k_size),'same');
        conv_background = conv2(crop_background,conv_k,'same');
        imagesc(conv_background)
        %% 绘制热图,速度
        k_size = 21;
        conv_k = conv2(ones(k_size,k_size),ones(k_size,k_size),'same');
        conv_speed_background = conv2(crop_speed_background,conv_k,'same');
        imagesc(conv_speed_background)
        %% 计算平均速度
        mean_V = mean(speed);
        %% 计算总活动量
        active_quan = sum(speed*30);
        %% 计算运动能量
        vec_Vx = [zeros(1,size(tempX,2));diff(tempX)];
        vec_Vy = [zeros(1,size(tempY,2));diff(tempY)];
        vec_Vz = [zeros(1,size(tempZ,2));diff(tempZ)];
        eng_x = vec_Vx.^2;
        eng_y = vec_Vy.^2;
        eng_z = vec_Vz.^2;
        mean_eng = mean(mean(eng_x+eng_y+eng_z));
        %% 计算焦虑指数
        close all
        imshow(~background)
        title('请点击中心位置')
        mouse_cent_y = size(background,1)/2;
        mouse_cent_x = size(background,2)/2;
%         [mouse_cent_x,mouse_cent_y] = ginput(1);
        show_background = insertMarker(double(~background),[mouse_cent_x,mouse_cent_y],'+','Size',10);
        imshow(show_background)
        title('请点击半径位置')
        mouse_r_y = mouse_cent_y;
        mouse_r_x = mouse_cent_x/2;
%         [mouse_r_x,mouse_r_y] = ginput(1);
        r = sqrt((mouse_r_x-mouse_cent_x).^2+(mouse_r_y-mouse_cent_y).^2);
        se = strel('disk',round(r),0);
        cut_bg = zeros(size(background));
        cut_bg(round(mouse_cent_y),round(mouse_cent_x)) = 1;
        conv_bg = conv2(cut_bg,double(se.Neighborhood),'same');
        imshow(conv_bg+background)
        and_bg = conv_bg&background;
        anxi_index = sum(and_bg(:))/sum(background(:));
        title('满意则空格键继续')
%         pause
        %% 赋值
        tradparam_cell{m,1} = fileNames{m,1};
        tradparam_cell{m,2} = background;
        tradparam_cell{m,3} = rgbim;
        tradparam_cell{m,4} = speed;
        tradparam_cell{m,5} = speed_background;
        tradparam_cell{m,6} = speed_rgbim;
        tradparam_cell{m,7} = mean_V;
        tradparam_cell{m,8} = active_quan;
        tradparam_cell{m,9} = mean_eng;
        tradparam_cell{m,10} = anxi_index;
        %% 进度控制
        disp(m)
    end
end
%% 保存变量
whole_trad_cell = [title_cell;tradparam_cell];
save('.\data\whole_trad_cell.mat','whole_trad_cell');
%% 可视化轨迹
for k = 2:size(whole_trad_cell,1)
    subplot(2,6,k-1)
    imshow(whole_trad_cell{k,3})
    title(whole_trad_cell{k,1})
end
%% 可视化速度热图
for k = 2:size(whole_trad_cell,1)
    subplot(2,6,k-1)
    imshow(whole_trad_cell{k,5})
    title(whole_trad_cell{k,1})
end
%% 伪彩色处理
% plot(part_result(:,1),part_result(:,4))
crop_speed_background = whole_trad_cell{2,5};
deep_index = 0.1;%0.7
temprgbim = fake_color(conv2(deep_index*crop_speed_background,ones(3,3)));
speed_rgbim = temprgbim;
for i = 1:size(temprgbim,1)
    for j = 1:size(temprgbim,2)
            if((temprgbim(i,j,1) == 0)&(temprgbim(i,j,2) == 0)&(temprgbim(i,j,3) == 1))
                speed_rgbim(i,j,:) = 1;
            end
    end
end
imshow(speed_rgbim)