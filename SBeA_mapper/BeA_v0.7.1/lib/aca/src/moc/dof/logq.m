function Q = logq(Q0)
% Calculate the exponential map of quaternion.
% Input
%   Q0  -   quaternion matrix, (k x 4) x n matrix
% Output
%   Q   -   exponential map, (k x 3) x n matrix

[k, n] = size(Q0);
k = round(k / 4);

Q = zeros(3 * k, n);

for i = 1 : n
    for c = 1 : k
        q0 = Q0((c - 1) * 4 + 1 : c * 4, i);
        alpha = acos(q0(4));
        
        % sin(x) / x
        if abs(alpha) < eps
            tmp = 1;
        else
            tmp = sin(alpha) / alpha;
        end
        
        q = q0(1 : 3) / tmp;
        
        Q((c - 1) * 3 + 1 : c * 3, i) = 0 + q;
    end
end