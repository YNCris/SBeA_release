function result = no_underline(var_name)
    if ~iscell(var_name)
        var_name = {var_name};
    end
        
    for i = 1:length(var_name)
        var_name_one = var_name{i};
        result_one = '';
        for j = 1:size(var_name_one,2)
            c = var_name_one(j);
            if c == '_'
                c = '-';
            end
            result_one = [result_one c];
        end
        result{i} = result_one;
    end
    
    if length(result) == 1
        result = cell2mat(result);
    end
end