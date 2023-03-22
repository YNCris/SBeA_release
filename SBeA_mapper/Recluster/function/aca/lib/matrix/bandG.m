function sigma = bandG(D, nei, new_nei)
% Compute the bandwidth of the Gauss kernel.
%
% Input
%   D       -  distance matrix, n1 x n2
%   nei     -  #nearest neighbour
%              0: binary kernel
%              NaN: set bandwidth to 1
%
% Output
%   sigma   -  kernel bandwidth
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-20-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009
%   modify  -  Kang Huang (kang.huang@siat.ac.cn), 04-08-2020

if nargin < 3
    new_nei = 0.1;
end

if isnan(nei)
    sigma = 1;
    saveConKnlPara(nei, sigma)
    return;
end

if nei == 0
    sigma = 0;
    saveConKnlPara(nei, sigma)
    return;
end

if strcmp(nei, 'fix')
    if nargin > 2
        n = size(D, 1);
        m = min(max(1, floor(n * new_nei)), n);
        
        Dsorted = sort(D);
        D2 = Dsorted(1 : m, :);
        sigma = round(sum(sum(D2, 1)) / (n * m));
    else
        try
            [last_nei, last_sigma] = getConKnlPara();
            if strcmp(last_nei, 'fix')
                sigma = last_sigma;
            else
                n = size(D, 1);
                m = min(max(1, floor(n * new_nei)), n);
                
                Dsorted = sort(D);
                D2 = Dsorted(1 : m, :);
                sigma = round(sum(sum(D2, 1)) / (n * m));
            end
        catch
            n = size(D, 1);
            m = min(max(1, floor(n * new_nei)), n);
            
            Dsorted = sort(D);
            D2 = Dsorted(1 : m, :);
            sigma = sum(sum(D2, 1)) / (n * m);
        end
    end
    saveConKnlPara(nei, sigma)
    return
end

n = size(D, 1);
m = min(max(1, floor(n * nei)), n);

Dsorted = sort(D);
D2 = Dsorted(1 : m, :);
sigma = sum(sum(D2, 1)) / (n * m);
saveConKnlPara(nei, sigma)
