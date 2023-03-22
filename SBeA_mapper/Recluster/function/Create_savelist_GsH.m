function temp_savelist = Create_savelist_GsH(temp_sH,temp_G)
temp_savelist = zeros(size(temp_G,2),3);
for k = 1:size(temp_savelist,1)
    temp_savelist(k,1) = temp_sH(1,k);
    temp_savelist(k,2) = temp_sH(1,k+1)-1;
    temp_savelist(k,3) = find(temp_G(:,k)==1);
end