function plot_align_skl(XYZ,plotstr,linestr)
%{
    绘制一帧对齐的骨架点
%}
%% 画点
X = XYZ(1:3:(end-2));
Y = XYZ(2:3:(end-1));
Z = XYZ(3:3:end);
for k = 1:size(X,1)
    plot3(X(k,1),Y(k,1),Z(k,1),'*','Color',plotstr)
    hold on
end
hold off
%% 划线
%0 : skeleton will not be drawn, Eg : [ 1 2; 2 3;], draws lines between features 1 and 2, 2 and 3
drawline = [ 1 2; 1 3;2 3; 4 5;4 6;5 7;6 8;7 14;8 14;...
    5 9;7 11;6 10; 8 12;14 15; 15 16];
temp = [X,Y,Z]';
for l = 1:size(drawline,1)
    pts = [temp(:,drawline(l,1))'; temp(:,drawline(l,2))']; %line btw elbow and shoulder
    line(pts(:,1), pts(:,2), pts(:,3),'color',linestr,'linewidth',1.5)
end
