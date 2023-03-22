function X = rotX(X0, ang)
% Rotate the sample matrix around the first sample.

% rotation matrix
rot = [cos(ang), -sin(ang); ...
       sin(ang),  cos(ang)];
      
% put the circle at the first sample
n = size(X0, 2);
xc = X0(:, 1);
X = X0 - repmat(xc, 1, n);

% rotate
X = rot * X;

% adjust the circle
X = X + repmat(xc, 1, n);