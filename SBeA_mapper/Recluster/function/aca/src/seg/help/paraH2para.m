function para = paraH2para(paraH)
% Convert multi-level segmentation parameter to single level.
%
% Input
%   paraH   -  HACA parameter
%
% Output
%   para    -  ACA parameter
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

nH = length(paraH);
para = paraH(1);
para.k = paraH(nH).k;

nMi = 1; nMa = 1;
for iH = 1 : nH
    nMi = nMi * paraH(iH).nMi;
    nMa = nMa * paraH(iH).nMa;
end
para.nMi = nMi;
para.nMa = nMa;
