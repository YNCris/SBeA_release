function tempangle = vec_angle(A,B)
tempangle = acos(dot(A,B,2)./(vecnorm(A,2,2).*vecnorm(B,2,2)))*180/pi;