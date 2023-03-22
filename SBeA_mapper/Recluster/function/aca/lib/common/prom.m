function prom(level, form, varargin)
% Prompt the information specified in the parameters.
%
% Input
%   level     -  level of prompt, 't' | 'm' | 'b'
%   form      -  format
%   varargin  -  object list
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 01-29-2009
%   modify    -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

% setting by function "setPromL.m"
global promL; 

if isempty(promL)
    promL = 'm';
end

if level ~= 't' && level ~= 'm' && level ~= 'b'
    error('unknown level.');
end

if level >= promL
    fprintf(form, varargin{:});
end
