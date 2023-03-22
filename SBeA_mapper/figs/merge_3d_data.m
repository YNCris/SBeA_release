%{
    merge 3D social data in different color
    field 1: color
    field 2: same name
%}
clear all
close all
%% set path
filepath = ['Z:\hanyaning\multi_mice_test\Social_analysis\data\' ...
    'zengyuting_diff_color\data_for_analysis\unmerge_data'];
fileFolder = fullfile(filepath);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}';
%% seg fields
sepfileNames = cell(size(fileNames,1),2);
for k = 1:size(fileNames,1)
    tempname = fileNames{k,1};
    for m = 1:length(tempname)
        if strcmp(tempname(m),'-')
            cutfield = m-1;
        end
    end
    sepfileNames{k,1} = tempname(1:cutfield);
    sepfileNames{k,2} = tempname((cutfield+2):end);
end
%% merge data
unique_name = unique();