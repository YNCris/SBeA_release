function [social_names,temp_unique_names] = load_social_group_traj(BeA_path)
%{
    Transfer single BeA_struct name to social name
    social_names: [your group,animal instance 1, animal instance 2.....]
%}
fileFolder = fullfile(BeA_path);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}';
temp_unique_names = fileNames;
sepfileNames = cell(size(temp_unique_names,1),2);
for k = 1:size(temp_unique_names,1)
    tempname = temp_unique_names{k,1};
    for m = 1:length(tempname)
        if strcmp(tempname(m),'-')
            cutfield = m-1;
        end
    end
    sepfileNames{k,1} = tempname(1:cutfield);
    sepfileNames{k,2} = tempname((cutfield+2):end);
end
social_names = cell(size(unique(sepfileNames(:,2)),1), ...
    (size(sepfileNames,1)/size(unique(sepfileNames(:,2)),1))+1);
social_names(:,1) = unique(sepfileNames(:,2));
for k = 1:size(sepfileNames,1)
    for m = 1:size(social_names,1)
        if strcmp(sepfileNames{k,2},social_names{m,1})
            for n = 2:3
                if isempty(social_names{m,n})
                    social_names{m,n} = sepfileNames{k,1};
                    break
                end
            end
            break
        end
    end
end