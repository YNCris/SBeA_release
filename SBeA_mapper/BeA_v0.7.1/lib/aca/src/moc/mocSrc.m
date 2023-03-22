function src = mocSrc(dbe, pno, trl)
% Obtain mocap source.
%
% Input
%   dbe       -  database name, 'moc' | 'kit'
%   pno       -  person index (string)
%   trl       -  trial index (string)
%
% Output
%   src
%     dbe     -  same to the parameter
%     pno     -  same to the parameter
%     trl     -  same to the parameter
%     name    -  dbe_pno_trl
%     seg     -  segmentation (ground truth)
%     cnames  -  class names for segment
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify    -  Feng Zhou (zhfe99@gmail.com), 09-13-2009

if ~ischar(trl)
    trl = sprintf('%.2d', trl);
end
name = sprintf('%s_%s_%s', dbe, pno, trl);

% human label
MOC = mocHuman;
if isfield(MOC, name)
    src.seg = MOC.(name).seg;
    src.cnames = MOC.(name).cnames;
end

src.dbe = dbe;
src.pno = pno;
src.trl = trl;
src.name = name;
