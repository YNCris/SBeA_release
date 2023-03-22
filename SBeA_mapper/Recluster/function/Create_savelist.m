function temp_savelist = Create_savelist(temp_ReMap,temp_Seglist)
temp_savelist = zeros(size(temp_ReMap,2)-1,3);
for m = 1:size(temp_savelist,1)
    temp_savelist(m,1) = temp_ReMap(1,m);
    temp_savelist(m,2) = temp_ReMap(1,m+1)-1;
    temp_savelist(m,3) = temp_Seglist(1,temp_savelist(m,1));
end