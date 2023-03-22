function [dir_vec,p0]=ertp2kd(E,R,T,point)
[A, B, C, D] = triangulate_line_matrix(E,R,T,point);
[dir_vec, p0] = line2kd(A,B,C,D);