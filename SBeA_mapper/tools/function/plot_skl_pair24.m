function plot_skl_pair24(X,Y,Z,plotstr,linestr)
%{
    绘制一帧对齐的骨架点
%}
%% 画点
% X = zscore(XYZ(:,1:16)');
% Y = zscore(XYZ(:,17:32)');
% Z = zscore(XYZ(:,33:48)');
% X = XYZ(1:3:(end-2));
% Y = XYZ(2:3:(end-1));
% Z = XYZ(3:3:end);
for k = 1:size(X,1)
    plot3(X(k,1),Y(k,1),Z(k,1),'.','Color',plotstr)
    hold on
end
hold off
%% 划线
%0 : skeleton will not be drawn, Eg : [ 1 2; 2 3;], draws lines between features 1 and 2, 2 and 3
drawline = [1,2;
    1,3;
    2,3;
    2,4;
    3,4;
    4,11;
    4,12;
    4,5;
    4,7;
    7,5;
    7,8;
    8,5;
    5,6;
    8,6;
    6,9;
    6,10];
temp = [X,Y,Z]';
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color',linestr,'linewidth',1.5)
end
