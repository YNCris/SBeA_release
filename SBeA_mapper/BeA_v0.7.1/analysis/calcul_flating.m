function dataset = calcul_flating(dataset, if_plot)
% update ifFreezing
flat_speed_thr = 0.3;
flat_time_thr = 0.1;
fs = dataset.rawdata.top.fs;

time = dataset.rawdata.top.time;

% if calculating freezing before, no need smoothing
sspeed = dataset.data.speed;

flat_flg = (sspeed > flat_speed_thr);
% dataset.rawdata.top.data(:, 1) = flat_flg;

flatIndex = extract_freezing(flat_flg, fs, flat_time_thr);
if ~isempty(flatIndex)
    flat_start = flatIndex(:, 2); flat_end = flatIndex(:, 1);
    
    flat_dur = (flat_end - flat_start)/fs;
    
    if if_plot
        % plot speed
        fig = figure; set(fig, 'position', [200, 200, 1400, 400]);
        
        max_value = max(max(sspeed));
        min_value = min(min(sspeed));
        hold on
        
        plot(flatIndex'/fs, [max_value, max_value], 'r', 'LineWidth', 8);
        
        evtTime = dataset.rawdata.top.evtPos_cor;
        n_evt = size(evtTime, 1);
        for ie=1:n_evt
            patch('vertices', [evtTime(ie,1),min_value; evtTime(ie,1),max_value;...
                evtTime(ie,2),max_value; evtTime(ie,2),min_value], ...
                'faces', [1, 2, 3, 4], 'EdgeColor', 'none', ...
                'FaceColor', [0 0 0], 'FaceAlpha', 0.2);
        end
        
        xlim([time(1), time(end)]);
        plot(time, sspeed, 'LineWidth', 1);
        xlabel('Time [s]'); ylabel('Speed [m/s]')
        ylim([min_value*1.2 max_value*1.2])
        title('Flating Index')
        set(gca, 'FontSize', 20, 'LineWidth', 2, 'TickDir', 'out', 'Box', 'off')
        %     legend([plt1, plt2], {'anticlockwise', 'clockwise'}, 'location', 'best', 'Box', 'off', 'Orientation', 'vertical', 'FontSize', 20);
        print(gcf, '-dtiff', '-r300',[dataset.data_path, '_flating_speed', '.tiff']);
    end
    
    dataset.data.flating.time = [flatIndex(:, 2), flatIndex(:, 1)]/fs;
    dataset.data.flating.duration = flat_dur;
else
    dataset.data.flating.time = [];
    dataset.data.flating.duration = [];
    disp('No flating detected!')
end





