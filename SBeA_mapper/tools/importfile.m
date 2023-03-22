function CollectedDataHYN = importfile(filename, dataLines)
%IMPORTFILE 从文本文件中导入数据
%  COLLECTEDDATAHYN = IMPORTFILE(FILENAME)读取文本文件 FILENAME 中默认选定范围的数据。
%  以表形式返回数据。
%
%  COLLECTEDDATAHYN = IMPORTFILE(FILE, DATALINES)按指定行间隔读取文本文件 FILENAME
%  中的数据。对于不连续的行间隔，请将 DATALINES 指定为正整数标量或 N×2 正整数标量数组。
%
%  示例:
%  CollectedDataHYN = importfile("F:\multi_mice_test\Social_analysis\methods_compare\envs\SBeA_cmp-HYN-2022-05-05\labeled-data\train_seg-1-mouse-day1-camera-1\CollectedData_HYN.csv", [5, Inf]);
%
%  另请参阅 READTABLE。
%
% 由 MATLAB 于 2022-05-05 22:35:03 自动生成

%% 输入处理

% 如果不指定 dataLines，请定义默认范围
if nargin < 2
    dataLines = [5, Inf];
end

%% 设置导入选项并导入数据
opts = delimitedTextImportOptions("NumVariables", 67);

% 指定范围和分隔符
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 指定列名称和类型
opts.VariableNames = ["scorer", "VarName2", "VarName3", "HYN", "HYN1", "HYN2", "HYN3", "HYN4", "HYN5", "HYN6", "HYN7", "HYN8", "HYN9", "HYN10", "HYN11", "HYN12", "HYN13", "HYN14", "HYN15", "HYN16", "HYN17", "HYN18", "HYN19", "HYN20", "HYN21", "HYN22", "HYN23", "HYN24", "HYN25", "HYN26", "HYN27", "HYN28", "HYN29", "HYN30", "HYN31", "HYN32", "HYN33", "HYN34", "HYN35", "HYN36", "HYN37", "HYN38", "HYN39", "HYN40", "HYN41", "HYN42", "HYN43", "HYN44", "HYN45", "HYN46", "HYN47", "HYN48", "HYN49", "HYN50", "HYN51", "HYN52", "HYN53", "HYN54", "HYN55", "HYN56", "HYN57", "HYN58", "HYN59", "HYN60", "HYN61", "HYN62", "HYN63"];
opts.VariableTypes = ["categorical", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 指定变量属性
opts = setvaropts(opts, ["scorer", "VarName2"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "VarName3", "TrimNonNumeric", true);
opts = setvaropts(opts, "VarName3", "ThousandsSeparator", ",");

% 导入数据
CollectedDataHYN = readtable(filename, opts);

end