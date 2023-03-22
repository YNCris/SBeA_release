%CBREWER2 Interpolated versions of Cynthia Brewer's ColorBrewer colormaps
%   CBREWER2(CNAME, NCOL) returns the colour scheme CNAME with the number
%   of colours equal to NCOL. If there is a ColorBrewer scheme with exactly
%   this number of colours, the color scheme is returned as-is. If NCOL
%   larger (or smaller) than the designed colormaps for this scheme, the
%   largest (smallest) one is interpolated to provide enough colours,
%   unless the requested colour scheme CNAME is a qualitative palette. For
%   a qualitative scheme, the colours are repeated, cycling from the
%   beginning again, to output the requested NCOL colours.
%
%   CBREWER2(CNAME) without an NCOL input will use the same number of
%   colours as the current colormap.
%
%   CBREWER2(CNAME, NCOL, INTERP_METHOD) allows you to change the method
%   used for the interpolation. The default is 'cubic'.
%
%   CBREWER2(CNAME, NCOL, INTERP_METHOD, INTERP_SPACE) allows you to
%   change the colorspace used for the interpolation. By default, this is
%   in the CIELAB colorspace, which is approximately perceptually uniform.
%   Options for INTERP_SPACE are
%     'rgb' : interpolation in sRGB (as used in original CBREWER)
%     'lab' : interpolation in CIELAB (default)
%     'lch' : interpolation in CIELCH_ab (not recommended due to the
%               discontinuities at C=0 and H=0)
%     Anything else supported by COLORSPACE will also function.
%
%   The input format CBREWER2(TYPE, ...) can also be used, where TYPE is
%   one of 'seq', 'div', 'qual'. This input is redandant and will be
%   ignored. This input format is provided for backwards compatibility with
%   the original CBREWER.
%
%   Example 1 (sequential heatmap):
%       C = [0 2 4 6; 8 10 12 14; 16 18 20 22];
%       imagesc(C);
%       colorbar;
%       colormap(cbrewer('YlOrRd', 256);
%
%   Example 2 (line plot):
%       x = 0:0.01:2;
%       sc = [0.5; 1; 2];
%       t0 = [0; 0.2; 0.4];
%       t = bsxfun(@rdivide, bsxfun(@plus, x, t0), sc);
%       y = sin(t * 2 * pi);
%       cmap = cbrewer2('Set1', numel(sc));
%       axes('ColorOrder', cmap, 'NextPlot', 'ReplaceChildren');
%       plot(x, y);
%
%   Example 3 (divergent heatmap):
%       [X,Y,Z] = peaks(30);
%       surfc(X,Y,Z);
%       colormap(cbrewer2('RdBu'));
%
%   This product includes color specifications and designs developed by
%   Cynthia Brewer (http://colorbrewer.org/). For more information on
%   ColorBrewer, please visit http://colorbrewer.org/.
%
%   CBREWER2 uses a cached copy of the Cynthia Brewer color schemes which
%   was converted to .mat format by Charles Robert for use with CBREWER.
%   CBREWER is available from the MATLAB FileExchange under the MIT license.
%
%   See also CBREWER, BREWERMAP, COLORSPACE, INTERP1.


%   Copyright (c) 2016 Scott Lowe
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.


function colormap = cbrewer2(...
    cname, ncol, interp_method, interp_space, varargin)

% Definitions -------------------------------------------------------------

% List of all of Cynthia Brewer's colormaps and their types
%  seq: sequential
%  div: divergent
%  qual: qualitative
cbdict = {...
    'Blues',    'seq'; ...
    'BuGn',     'seq'; ...
    'BuPu',     'seq'; ...
    'GnBu',     'seq'; ...
    'Greens',   'seq'; ...
    'Greys',    'seq'; ...
    'Oranges',  'seq'; ...
    'OrRd',     'seq'; ...
    'PuBu',     'seq'; ...
    'PuBuGn',   'seq'; ...
    'PuRd',     'seq'; ...
    'Purples',  'seq'; ...
    'RdPu',     'seq'; ...
    'Reds',     'seq'; ...
    'YlGn',     'seq'; ...
    'YlGnBu',   'seq'; ...
    'YlOrBr',   'seq'; ...
    'YlOrRd',   'seq'; ...
    'BrBG',     'div'; ...
    'PiYG',     'div'; ...
    'PRGn',     'div'; ...
    'PuOr',     'div'; ...
    'RdBu',     'div'; ...
    'RdGy',     'div'; ...
    'RdYlBu',   'div'; ...
    'RdYlGn', 	'div'; ...
    'Spectral', 'div'; ...
    'Accent',   'qual'; ...
    'Dark2',    'qual'; ...
    'Paired',   'qual'; ...
    'Pastel1',  'qual'; ...
    'Pastel2',  'qual'; ...
    'Set1',     'qual'; ...
    'Set2',     'qual'; ...
    'Set3',     'qual'; ...
    };


% Input handling ----------------------------------------------------------

narginchk(1, 5);

% Initialise variables if not supplied
if nargin<2
    ncol = [];
end
if nargin<3
    interp_method = [];
end
if nargin<4
    interp_space = [];
end
if nargin<5
    varargin = {[]};
end

% Check if the colormap type was unnecessarily input
types = unique(cbdict(:, 2));
if nargin > 1 && ischar(cname) && ischar(ncol)
    LI = ismember({cname ncol}, types);
    if ~any(LI); error('Number of colors cannot be a string'); end;
    if all(LI); error('Incorrect colormap name'); end;
    if LI(1)
        vgn = {cname; ncol; interp_method; interp_space};
        cname           = vgn{2};
        ncol            = vgn{3};
        interp_method   = vgn{4};
        interp_space    = varargin{1};
        ctype_input     = vgn{1};
    elseif LI(2)
        vgn = {cname; ncol; interp_method; interp_space};
        cname           = vgn{1};
        ncol            = vgn{3};
        interp_method   = vgn{4};
        interp_space    = varargin{1};
        ctype_input     = vgn{2};
    end
else
    ctype_input = '';
end

% Default values
if isempty(ncol)
    % Number of colours in the colormap
    ncol = size(get(gcf,'colormap'), 1);
end
if isempty(interp_method)
    interp_method = 'pchip';
end
if isempty(interp_space)
    interp_space = 'lab';
end


% Load colorbrewer data ---------------------------------------------------
Tmp = load('colorbrewer.mat');
colorbrewer = Tmp.colorbrewer;

[TF, idict] = ismember(lower(cname), lower(cbdict(:, 1)));

if ~TF
    error('%s is not a recognised Brewer colormap',cname);
end

cname = cbdict{idict, 1};
ctype = cbdict{idict, 2};

if (~isfield(colorbrewer.(ctype), cname))
    error('Colormap %s is not present in loaded data',cname);
end


% Main script -------------------------------------------------------------

if ncol > length(colorbrewer.(ctype).(cname))
    % If we specified too many colours, we take the maximum and interpolate
    colormap = colorbrewer.(ctype).(cname){length(colorbrewer.(ctype).(cname))};
    colormap = colormap ./ 255;
elseif isempty(colorbrewer.(ctype).(cname){ncol})
    % If we specified too few colours, we take the minimum and interpolate
    nmin = find(~cellfun(@isempty, colorbrewer.(ctype).(cname)), 1);
    colormap = colorbrewer.(ctype).(cname){nmin};
    colormap = colormap./255;
else
    % If we specified a number of colours in the pre-designed range, no
    % need to interpolate
    colormap = (colorbrewer.(ctype).(cname){ncol}) ./ 255;
    return;
end

% Don't interpolate if qualitative type
if strcmp(ctype,'qual')
    if size(colormap, 1) >= ncol
        colormap = colormap(1:ncol, :);
        return;
    end
    warning('CBREWER2:QualTooManyColors', ...
        ['Too many colors requested: cannot interpolate a qualitative' ...
        ' colorscheme']);
    % Cycle the colours from the beginning again, so we have enough to
    % return
    colormap = repmat(colormap, ceil(ncol / size(colormap, 1)), 1);
    colormap = colormap(1:ncol, :);
    return;
end

% Make sure we have colorspace downloaded from the FEX
if ~strcmpi(interp_space, 'rgb') && ~exist('colorspace.m', 'file')
    P = requireFEXpackage(28790);
    if isempty(P);
        error(...
            ['You need to download COLORSPACE from the MATLAB FEX and' ...
            ' add it to the MATLAB path.']);
    end;
end

% Move to perceptually uniform space
if ~strcmpi(interp_space,'rgb')
    colormap = colorspace(['rgb->' interp_space], colormap);
end

% Linearly interpolate
X  = linspace(0, 1, size(colormap, 1));
XI = linspace(0, 1, ncol);
colormap = interp1(X, colormap, XI, interp_method);

% Move from perceptually uniform space back to sRGB
if ~strcmpi(interp_space,'rgb')
    colormap = colorspace(['rgb<-' interp_space], colormap);
end

end