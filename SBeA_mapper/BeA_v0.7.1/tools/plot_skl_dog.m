function plot_skl_dog(X,Y,Z,plotstr,linestr)
%{
    ����һ֡����ĹǼܵ�
%}
%% ����
% X = zscore(XYZ(:,1:16)');
% Y = zscore(XYZ(:,17:32)');
% Z = zscore(XYZ(:,33:48)');
% X = XYZ(1:3:(end-2));
% Y = XYZ(2:3:(end-1));
% Z = XYZ(3:3:end);
for k = 1:size(X,1)
    plot3(X(k,1),Y(k,1),Z(k,1),'.','Color',plotstr,'MarkerSize',20)
    hold on
end
hold off
%% ����
%0 : skeleton will not be drawn, Eg : [ 1 2; 2 3;], draws lines between features 1 and 2, 2 and 3
drawline = [...
    1,2
    1,3
    1,4
    2,3
    2,4
    3,4
    4,13
    4,7
    4,5
    5,6
    7,8
    9,10
    11,12
    5,7
    7,13
    13,5
    11,9
    11,15
    15,9
    7,11
    5,9
    13,14
    14,15
    7,14
    5,14
    14,11
    14,9
    11,16
    9,16
    15,16
    16,17];
temp = [X,Y,Z]';
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color',linestr,'linewidth',1.5)
end
