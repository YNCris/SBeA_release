 function Seglist = SegBarTransWhite(seg,TD_sR)
%{
    将seg转换为[起始帧，结束帧，离散分割类别]
%}
% seg = HACA_struct.seg(1);
s = seg.s;
G = seg.G;
MapFL = TD_sR;
% MapFL = HACA_struct.TD_sR;
TFLH = MapFL(s);
TFLH(end) = TFLH(end)-1;%分段起始位置
All_G = zeros(size(G,1),TFLH(1,end));
for k = 1:(size(TFLH,2)-1)
    All_G(:,TFLH(1,k):TFLH(1,k+1)) = G(:,k)*ones(size(TFLH(1,k):TFLH(1,k+1)));
end
Seglist = [];
TFLH(end) = TFLH(end)+1;%分段起始位置
for k = 1:(size(TFLH,2)-1)
    startcursor = TFLH(1,k);
    endcursor = TFLH(1,k+1)-1;
    labelcursor = find(sum(All_G(:,startcursor:endcursor)==ones(size(All_G,1),...
        endcursor-startcursor+1),2)==(endcursor-startcursor+1));
    Seglist = [Seglist;[startcursor,endcursor,labelcursor]];
end

