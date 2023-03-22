function colormap = get_gradient_colors(color_str, color_scale)

if nargin > 0
    if ~exist('color_scale', 'var')
        color_scale = 100;
    end
    
    sampe_rate = 1/(color_scale-1);
    color_scale_list = 1:-sampe_rate:0;
    color_scale_list = color_scale_list';
    colormap = ones(color_scale, 3);
        
    if strcmp(color_str, 'grey') || strcmp(color_str, 'black')
        colormap(:,1) = color_scale_list;
        colormap(:,2) = color_scale_list;
        colormap(:,3) = color_scale_list;
    elseif strcmp(color_str, 'blue')
        colormap(:,1) = color_scale_list;
        colormap(:,2) = color_scale_list;
    elseif strcmp(color_str, 'red')
        colormap(:,2) = color_scale_list;
        colormap(:,3) = color_scale_list;
    elseif strcmp(color_str, 'green')
        colormap(:,1) = color_scale_list;
        colormap(:,3) = color_scale_list;
    elseif strcmp(color_str, 'granger')
        colormap = [ ...
            [0 0 1]; ... % blue 1
            [0 1 0]; ... % green 2
            [1 0 0]; ... % red 3
            [1 0 1]; ... % pink 4
            [0.4 0.4 0.4]; ... % grey 5
            [0.4 0.4 0.4]; ... % grey 6
            [0.4 0.4 0.4]; ... % grey 7
            [0.4 0.4 0.4]; ... % grey 8
            [0.4 0.4 0.4]; ... % grey 9
            [0.4 0.4 0.4]; ... % grey 10
            [0 0 1]*0.5; ... % blue 11
            [0 1 0]*0.5; ... % green 12
            [1 0 0]*0.5; ... % red 13
            [1 0 1]*0.5; ... % pink 14
            ([0 0 1] + [1 1 0]*0.7); ... % light blue 21
            ([0 1 0] + [1 0 1]*0.7); ... % light green 22
            ([1 0 0] + [0 1 1]*0.7); ... % light red 23
            ];
    end
else
    colormap = [
             0         0    1.0000 %1 blue
             0    1.0000         0 %2 % green
        1.0000         0         0 %3 red
        1.0000         0        1.0000 % 4 pink
         1.0000    0.8276         0  %5 yellow
        0.6207    0.4138    0.7241 % 5 bluepurple
        0.5172    0.5172    1.0000 % 6 light blue
        0.6207    0.3103    0.2759 % 8 % brown
             0    1.0000    0.7586 % 9 light green
        0.9655    0.0690    0.3793 % 10 
        0.5862    0.8276    0.3103 % 11
        0.9655    0.6207    0.8621% 12
        0.5276    0.0690    1.0000% 13
        0.4828    0.1034    0.4138% 14
             0    0.5172    0.5862% 15
        1.0000    0.7586    0.5172% 16
             0    0.5862    0.9655% 17
        0.5517    0.6552    0.4828 % 18
        0.9655    0.5172    0.0345 % 19
        0.5172    0.4483         0 % 20
        0.4483    0.9655    1.0000 % 21
        0.6207    0.7586    1.0000 % 22
        0.4483    0.3793    0.4828 % 23
        0.6207         0         0 % 24
             0    0.7103    1.0000 % 25
        0.8276    1.0000         0 % 26
             0    0.2759    0.5862 % 27
        1.0000    0.4828    0.3793 % 28
        0.2759    1.0000    0.4828 % 29
        0.0690    0.6552    0.3793
        0.8276    0.6552    0.6552
        0.8276    0.3103    0.5172
        0.4138         0    0.7586
        0.1724    0.3793    0.2759
        0.7241    0.3103    0.8276 % 35
        0.0345    0.2414    0.3103
        0.6552    0.3448    0.0345
        0.4483    0.3793    0.2414
        0.0345    0.5862         0
        1.0000    1.0000    0.4483
        0.6552    0.9655    0.7931
        0.5862    0.6897    0.7241
        0.6897    0.6897    0.0345
        ];
end
