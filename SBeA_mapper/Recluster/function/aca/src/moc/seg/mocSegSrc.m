function wsSrc = mocSegSrc(tag)
% Obtain the particular source according to the sepcified tag.
%
% Input
%   tag      -  type. 1-14 -> motion capture from subject 86
%
% Output
%   wsSrc
%     src    -  mocap source
%     paraF  -  feature parameter
%     paraP  -  feature parameter
%     para   -  segmentation parameter (ACA)
%     paraH  -  segmentation parameter (HACA)
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify   -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

prom('t', 'new moc seg src: tag %d\n', tag);

if tag >= 1 && tag <= 14
    % 86
    trl = sprintf('%.2d', tag);
    src = mocSrc('moc', '86', trl);
    [paraF, paraP, para, paraH] = mocPara(src);

else
    error('unknown tag');
end

% working space
wsSrc.src = src;
wsSrc.paraF = paraF;
wsSrc.paraP = paraP;
wsSrc.para = para;
wsSrc.paraH = paraH;
