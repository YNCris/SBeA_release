function [sort_frac_little,new_id_list] = sort_mat(fractions_little)
sort_frac_little = zeros(size(fractions_little));
sort_frac_little(:,1) = fractions_little(:,1);
raw_id_list = 1:size(fractions_little,2);
new_id_list = zeros(size(raw_id_list));
new_id_list(1) = raw_id_list(1);
for k = 1:(length(new_id_list)-1)
    tempidlist = raw_id_list;
    non_zero_new_id_list = new_id_list;
    non_zero_new_id_list(new_id_list==0) = [];
    for m = 1:length(non_zero_new_id_list)
        tempidlist(tempidlist==non_zero_new_id_list(m)) = [];
    end
    tempfrac = sort_frac_little(:,k);
    mind = sqrt(sum((tempfrac*ones(1,length(tempidlist))...
        -fractions_little(:,tempidlist)).^2,1));
    new_id_list(k+1) = tempidlist(min(mind)==mind);
    sort_frac_little(:,k+1) = fractions_little(:,new_id_list(k+1));
end