 function Seglist = SegBarTransWhite(seg,TD_sR)
%{
    ��segת��Ϊ[��ʼ֡������֡����ɢ�ָ����]
%}
% seg = HACA_struct.seg(1);
s = seg.s;
G = seg.G;
MapFL = TD_sR;
% MapFL = HACA_struct.TD_sR;
TFLH = MapFL(s);
TFLH(end) = TFLH(end)-1;%�ֶ���ʼλ��
All_G = zeros(size(G,1),TFLH(1,end));
for k = 1:(size(TFLH,2)-1)
    All_G(:,TFLH(1,k):TFLH(1,k+1)) = G(:,k)*ones(size(TFLH(1,k):TFLH(1,k+1)));
end
Seglist = [];
TFLH(end) = TFLH(end)+1;%�ֶ���ʼλ��
for k = 1:(size(TFLH,2)-1)
    startcursor = TFLH(1,k);
    endcursor = TFLH(1,k+1)-1;
    labelcursor = find(sum(All_G(:,startcursor:endcursor)==ones(size(All_G,1),...
        endcursor-startcursor+1),2)==(endcursor-startcursor+1));
    Seglist = [Seglist;[startcursor,endcursor,labelcursor]];
end

