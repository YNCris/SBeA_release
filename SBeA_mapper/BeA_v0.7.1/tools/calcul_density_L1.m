function PDF = calcul_density_L1(embedding, Border, Sigma, stepNum)

% mapping multi-layer bahvior into low-D space
%
% Input
%   - embedding   -  low-D embeddings of decomposed segments
%   - Border      -  add border around the density map
%   - Sigma       -  
%   - stepSize    -  
%
% Output
%   Estimated probability density 
%
% History
%   create  -  Kang Huang  (kang.huang@siat.ac.cn), 03-02-2020

tem_embed = embedding{1, 1};

% n_clus = max(tem_seg);

X = tem_embed(:,1);
Y = tem_embed(:,2);
D = [X, Y];
N = length(X);

Xrange = [min(X)-Border max(X)+Border];
Yrange = [min(Y)-Border max(Y)+Border];

stepSize = max([Xrange(2)-Xrange(1), Yrange(2)-Yrange(1)])/stepNum;

%Setup coordinate grid
[XX, YY] = meshgrid(Xrange(1):stepSize:Xrange(2), Yrange(1):stepSize:Yrange(2));
YY = flipud(YY);

%Parzen parameters and function handle
pf1 = @(C1,C2) (1/N)*(1/((2*pi)*Sigma^2)).*...
    exp(-( (C1(1)-C2(1))^2+ (C1(2)-C2(2))^2)/(2*Sigma^2));

PPDF = zeros(size(XX));

%Populate coordinate surface
[R, C] = size(PPDF);

XXX = [];
YYY = [];
for c = 1:C
    for r = 1:R
        for d = 1:N
            PPDF(r,c) = PPDF(r,c) + ...
                pf1([XX(1,c) YY(r,1)],[D(d,1) D(d,2)]);
        end
        XXX = [XXX, XX(1,c)];
        YYY = [YYY, YY(r,1)];
    end
end

%Normalize data
m1 = max(PPDF(:));
PPDF = PPDF / m1;

PDF.PPDF = PPDF;
PDF.X = XXX;
PDF.Y = YYY;



