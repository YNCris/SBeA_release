%CBREWER2_PLOT_SAMPLES
%   Plots sample swabs for each ColorBrewer palette included in CBREWER2.
%
%   See also CBREWER2.

function cbrewer2_plot_samples()

% Parameters --------------------------------------------------------------
% File to take palettes from
RESOURCE_FNAME = 'colorbrewer.mat';
% Settings for cmap interpolation
INCLUDE_INTERP = true;
NCOL_INTERP = 256;
% Spacing is measured in pixels
SWAB_WIDTH = 20;
SWAB_HEIGHT = SWAB_WIDTH;
TYPE_SPACING = 50;
PALETTE_SPACING = 30 + ~INCLUDE_INTERP * 20;
SUB_PALETTE_SPACING = 10;
BORDER_LEFT = 140;
BORDER_RIGHT = 40;
BORDER_TOP = 50;
BORDER_BOTTOM = 40;
% Order in which to plot the colour scheme types
TYPE_ORDER = {'seq', 'div', 'qual'};

% Main --------------------------------------------------------------------
Cb2 = load(RESOURCE_FNAME);
cb = Cb2.colorbrewer;

types = TYPE_ORDER;  % fieldnames(cb);

% npal_per_type = structfun(@(x) numel(fieldnames(x)), cb);
npal_per_type = nan(size(types));
for iType = 1:numel(types)
    npal_per_type(iType) = numel(fieldnames(cb.(types{iType})));
end
max_npal = max(npal_per_type);

% max_ncol_per_type = structfun(@(x) max(structfun(@numel, x)), cb);
max_ncol_per_type = nan(size(types));
for iType = 1:numel(types)
%     max_ncol_per_type(iType) = max(structfun(@numel, cb.(types{iType})));
    max_ncol_per_type(iType) = max(structfun(@(x) size(x{end}, 1), cb.(types{iType})));
end

fig_width = max_npal * SWAB_WIDTH * (1 + INCLUDE_INTERP) ...
    + (max_npal - 1) * PALETTE_SPACING ...
    + (max_npal - 1) * SUB_PALETTE_SPACING * INCLUDE_INTERP ...
    + BORDER_LEFT ...
    + BORDER_RIGHT;

fig_height = sum(max_ncol_per_type) * SWAB_HEIGHT ...
    + (numel(types) - 1) * TYPE_SPACING ...
    + BORDER_TOP ...
    + BORDER_BOTTOM;

% Get the screensize so we can centre the figure
screensize = get(0, 'Screensize');
figpos = [
    (screensize(3) - fig_width) / 2
    (screensize(4) - fig_height) / 2
    fig_width
    fig_height
    ];
hf = figure(...
    'Position', figpos, ...
    'Color', [.48 .48 .48]);

for iType = 1:numel(types)
    palettes = fieldnames(cb.(types{iType}));
    for iPalette = 1:numel(palettes)
        cmap = cb.(types{iType}).(palettes{iPalette}){end} ./ 255;
        axpos = [
            BORDER_LEFT + (iPalette - 1) * ...
                (SWAB_WIDTH + PALETTE_SPACING + ...
                 INCLUDE_INTERP * (SWAB_WIDTH + SUB_PALETTE_SPACING));
            fig_height - (...
                BORDER_TOP + ...
                (iType - 1) * TYPE_SPACING + ...
                SWAB_HEIGHT * sum(max_ncol_per_type(1:iType))...
                );
            SWAB_WIDTH;
            SWAB_HEIGHT * size(cmap, 1)
            ];
        axpos(2) = axpos(2) + SWAB_HEIGHT * (max_ncol_per_type(iType) - size(cmap, 1));
        ax = axes(...
            'Units', 'pixels', ...
            'Position', axpos);
        image(permute(cmap, [1 3 2]));
        axis off;
        ht = title(ax, palettes{iPalette}, 'FontWeight', 'normal');
        if INCLUDE_INTERP && ~strncmpi(types{iType}, 'qual', 4)
            tpos_offset = diff(get(ax, 'XLim')) ./ SWAB_WIDTH * ...
                (SWAB_WIDTH + SUB_PALETTE_SPACING) / 2;
            set(ht, 'Position', get(ht, 'Position') + [tpos_offset 0 0]);
            axpos2 = axpos + [SUB_PALETTE_SPACING + SWAB_WIDTH; 0; 0; 0];
            ax2 = axes(...
                'Units', 'pixels', ...
                'Position', axpos2);
            cmap_interp = cbrewer2(palettes{iPalette}, NCOL_INTERP);
            image(permute(cmap_interp, [1 3 2]));
            axis off;
        else
            ax2 = [];
        end
        % set([ax ax2], 
        if iPalette == 1
            y_str = type2fulltype(types{iType});
            if isempty(y_str)
                y_str = type;
            else
                y_str = {y_str; ['(' types{iType} ')']};
            end
            hy = ylabel(ax, y_str);
            set(hy, ...
                'Visible', 'on', ...
                'rotation', 0, ...
                'HorizontalAlignment', 'right', ...
                'FontWeight', 'bold');
        end
    end
end

set(hf, ...
    'Name', 'cbrewer2: Colour maps', ...
    'MenuBar', 'none')

export_fig(hf, 'cbrewer2_samples', '-eps', '-png', '-painters', '-nocrop');

end


function type = type2fulltype(type)
    if strncmpi(type, 'seq', 3)
        type = 'Sequential';
    elseif strncmpi(type, 'div', 3)
        type = 'Divergent';
    elseif strncmpi(type, 'qual', 4)
        type = 'Qualitative';
    else
        type = '';
    end
end