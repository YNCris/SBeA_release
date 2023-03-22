function [A,B,C,D] = triangulate_line_matrix(E, R, T, point)
RT = [R', T'];

EFRT = E'* RT;

A = point .* EFRT(3, 1) - ones(size(point,1),1)*EFRT(1:2, 1)';
B = point .* EFRT(3, 2) - ones(size(point,1),1)*EFRT(1:2, 2)';
C = point .* EFRT(3, 3) - ones(size(point,1),1)*EFRT(1:2, 3)';
D = point .* EFRT(3, 4) - ones(size(point,1),1)*EFRT(1:2, 4)';

