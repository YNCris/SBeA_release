function Seglist = SegBarTrans(seg)
%{
    转换分割存储的形式
%}
s = seg.s;
G = seg.G;
Seglist = zeros(1,(seg.s(1,end)-1));
for m = 1:(size(s,2)-1)
    posnum = find(G(:,m)==1);
    for n = s(1,m):(s(1,m+1)-1)
        Seglist(1,n) = posnum;
    end
end