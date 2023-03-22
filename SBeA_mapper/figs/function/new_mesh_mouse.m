function new_mesh_mouse(coords3d, alpha, clrstr)

% head
i = 1;
X = coords3d(i,1:3:12);
X = [X,coords3d(i,10)];
X = [X,coords3d(i,4)];
X = [X,coords3d(i,7)];
Y = coords3d(i,2:3:12);
Y = [Y,coords3d(i,11)];
Y = [Y,coords3d(i,5)];
Y = [Y,coords3d(i,8)];
Z = coords3d(i,3:3:12);
Z = [Z,(coords3d(i,3)+coords3d(i,27))/2];
Z = [Z,(coords3d(i,27)+coords3d(i,12))/2];
Z = [Z,(coords3d(i,27)+coords3d(i,12))/2];

DT = delaunayTriangulation(X',Y',Z');
tetramesh(DT,'FaceColor',clrstr,'FaceAlpha',alpha,'EdgeColor','none');
% grid on;
% xlim([-300 300])
% ylim([-300 300])
% zlim([-20 200])
hold on


% left front paw 4 5 6 9 13
X = coords3d(i,37);
X = [X,coords3d(i,25)];
X = [X,coords3d(i,16)];
X = [X,coords3d(i,13)];
X = [X,coords3d(i,10)];
Y = coords3d(i,38);
Y = [Y,coords3d(i,26)];
Y = [Y,coords3d(i,17)];
Y = [Y,coords3d(i,14)];
Y = [Y,coords3d(i,11)];
Z = coords3d(i,39);
Z = [Z,coords3d(i,27)];
Z = [Z,coords3d(i,18)];
Z = [Z,coords3d(i,15)];
Z = [Z,coords3d(i,12)];



DT = delaunayTriangulation(X',Y',Z');
tetramesh(DT,'FaceColor',clrstr,'FaceAlpha',alpha,'EdgeColor','none');
hold on;

% right front paw 4 5 6 10 13
X = coords3d(i,16);
X = [X,coords3d(i,13)];
X = [X,coords3d(i,28)];
X = [X,coords3d(i,37)];
X = [X,coords3d(i,10)];
Y = coords3d(i,17);
Y = [Y,coords3d(i,14)];
Y = [Y,coords3d(i,29)];
Y = [Y,coords3d(i,38)];
Y = [Y,coords3d(i,11)];
Z = coords3d(i,18);
Z = [Z,coords3d(i,15)];
Z = [Z,coords3d(i,30)];
Z = [Z,coords3d(i,39)];
Z = [Z,coords3d(i,12)];

DT = delaunayTriangulation(X',Y',Z');
tetramesh(DT,'FaceColor',clrstr,'FaceAlpha',alpha,'EdgeColor','none');
hold on;

% left hind paw 5 7 11 13 8
X = coords3d(i,37);
X = [X,coords3d(i,31)];
X = [X,coords3d(i,19)];
X = [X,coords3d(i,13)];
X = [X,coords3d(i,22)];
Y = coords3d(i,38);
Y = [Y,coords3d(i,32)];
Y = [Y,coords3d(i,20)];
Y = [Y,coords3d(i,14)];
Y = [Y,coords3d(i,23)];
Z = coords3d(i,39);
Z = [Z,coords3d(i,33)];
Z = [Z,coords3d(i,21)];
Z = [Z,coords3d(i,15)];
Z = [Z,coords3d(i,24)];

DT = delaunayTriangulation(X',Y',Z');
tetramesh(DT,'FaceColor',clrstr,'FaceAlpha',alpha,'EdgeColor','none');
hold on;


% right hind paw 6 8 12 13 7
X = coords3d(i,37);
X = [X,coords3d(i,34)];
X = [X,coords3d(i,22)];
X = [X,coords3d(i,16)];
X = [X,coords3d(i,19)];
Y = coords3d(i,38);
Y = [Y,coords3d(i,35)];
Y = [Y,coords3d(i,23)];
Y = [Y,coords3d(i,17)];
Y = [Y,coords3d(i,20)];
Z = coords3d(i,39);
Z = [Z,coords3d(i,36)];
Z = [Z,coords3d(i,24)];
Z = [Z,coords3d(i,18)];
Z = [Z,coords3d(i,21)];

DT = delaunayTriangulation(X',Y',Z');
tetramesh(DT,'FaceColor',clrstr,'FaceAlpha',alpha,'EdgeColor','none');
hold on;


% body
X = coords3d(i,10:3:24);
X = [X,coords3d(i,40)];
X = [X,(coords3d(i,13:3:24)+coords3d(i,25:3:36))/2];
Y = coords3d(i,11:3:24);
Y = [Y,coords3d(i,41)];
Y = [Y,(coords3d(i,14:3:24)+coords3d(i,26:3:36))/2];
Z = coords3d(i,12:3:24);
Z = [Z,coords3d(i,42)];
Z = [Z,(coords3d(i,15:3:24)+coords3d(i,27:3:36))/2];
DT = delaunayTriangulation(X',Y',Z');
tetramesh(DT,'FaceColor',clrstr,'FaceAlpha',alpha,'EdgeColor','none');