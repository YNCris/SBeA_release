function [iMid, accs, accHs, accSs, tis, tiH1s, tiH2s] = pickMid(wsSeg)

segs = wsSeg.segs; segHs = wsSeg.segHs; segSs = wsSeg.segSs;
nRepeat = length(segs);

% fetch accuracy & times
[accs, accHs, accSs, tis, tiH1s, tiH2s] = zeross(nRepeat, 1);
for i = 1 : nRepeat
    accs(i) = segs{i}.acc;
    accHs(i) = segHs{i}(end).acc;
    accSs(i) = segSs{i}.acc;
    
    tis(i) = segs{i}.ti;
    tiH1s(i) = segHs{i}(1).ti;
    tiH2s(i) = segHs{i}(2).ti;
end

% average
Acc = [accs, accHs, accSs];
v = sum(Acc, 2);

% choose mid
[tmp, ind] = sort(v);
p = ceil(nRepeat / 2);
iMid = ind(p);