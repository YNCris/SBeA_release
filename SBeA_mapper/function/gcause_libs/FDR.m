function [GCMAP] = FDR(D,p,ht)

[CHN,CHN] = size(D);

% Number of multiple hypothesis tests
m = CHN*CHN;

% P-values
for n = 1:CHN
     P(n,:) = 1 - chi2cdf(D(n,:),ht(n));
end
[Ps,idx] = sort(P(:));

for k = 1:m
    if Ps(k) > k/m*p;
        break;
    end
end
k = k-1;

GCMAP = zeros(size(D));

for ii = 1:k
    if fix(idx(ii)/n) == idx(ii)/n
        GCMAP(n,idx(ii)/n) = 1;
    else
        GCMAP(idx(ii)-fix(idx(ii)/n)*n,fix(idx(ii)/n)+1) = 1;
    end
end