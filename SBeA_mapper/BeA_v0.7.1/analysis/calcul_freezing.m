function dataset = calcul_freezing(dataset, if_plot)
% update ifFreezing
freez_speed_thr = 0.03;
activaty_thr = 10;
freez_time_thr = 0.3;
fs = dataset.rawdata.top.fs;

speed = dataset.data.speed;
activity = dataset.rawdata.top.data(:, 2);

time = dataset.rawdata.top.time;

% smoothing them
sspeed = smooth_data(speed, fs, 2)';
dataset.data.speed = sspeed;
sactivity = smooth_data(activity, fs, 2)';
dataset.data.activity = sactivity;

freez_flg = (sspeed < freez_speed_thr & sactivity < activaty_thr);
dataset.rawdata.top.data(:, 1) = freez_flg;

frzIndex = extract_freezing(freez_flg, fs, freez_time_thr);
if ~isempty(frzIndex)
    frz_start = frzIndex(:, 2); freez_end = frzIndex(:, 1);
    
    freez_dur = (freez_end - frz_start)/fs;
    
    zs_speed = zscore(sspeed);
    zs_activity = zscore(sactivity);
    
    if if_plot
        % plot speed
        fig = figure; set(fig, 'position', [200, 200, 1400, 400]);
        
        max_value = max([max(zs_speed), max(zs_activity)]);
        min_value = max([min(zs_speed), min(zs_activity)]);
        hold on
        
        plot(frzIndex'/fs, [max_value, max_value], 'r', 'LineWidth', 8);
        
        evtTime = dataset.rawdata.top.evtPos_cor;
        n_evt = size(evtTime, 1);
        for ie=1:n_evt
            patch('vertices', [evtTime(ie,1),min_value; evtTime(ie,1),max_value;...
                evtTime(ie,2),max_value; evtTime(ie,2),min_value], ...
                'faces', [1, 2, 3, 4], 'EdgeColor', 'none', ...
                'FaceColor', [0 0 0], 'FaceAlpha', 0.2);
        end
        
        xlim([time(1), time(end)]);
        yyaxis left
        plot(time, zs_speed, 'LineWidth', 1);
        xlabel('Time [s]'); ylabel('Speed [m/s]')
        ylim([min_value*1.2 max_value*1.2])
        yyaxis right
        plot(time, zs_activity, 'LineWidth', 1);
        xlabel('Time [s]'); ylabel('Area Activity [a.u.]')
        ylim([min_value*1.2 max_value*1.2])
        title('Freezing Index')
        set(gca, 'FontSize', 20, 'LineWidth', 2, 'TickDir', 'out', 'Box', 'off')
        %     legend([plt1, plt2], {'anticlockwise', 'clockwise'}, 'location', 'best', 'Box', 'off', 'Orientation', 'vertical', 'FontSize', 20);
        print(gcf, '-dtiff', '-r300',[dataset.data_path, '_freezing_speed', '.tiff']);
    end
    
    dataset.data.freezing.time = [frzIndex(:, 2), frzIndex(:, 1)]/fs;
    dataset.data.freezing.duration = freez_dur;
else
    dataset.data.freezing.time = [];
    dataset.data.freezing.duration = [];
    disp('No freezing detected!')
end





