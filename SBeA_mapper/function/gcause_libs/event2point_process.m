function cstream = event2point_process(events, times, point_select)
% Convert events to cstream with only its onsets or offsets given a range of time
% cstream = event2cstream(events, times)

total = length(times);

if isempty(events)
    cstream = zeros(total,2);
    cstream(:,1) = times;
    return;
end

if strcmp(point_select, 'onset')
    events(:, 2) = events(:, 1) + eps;
elseif strcmp(point_select, 'offset')
    events(:, 1) = events(:, 2);
    events(:, 2) = events(:, 2) + eps;
else
    error('The value of POINT_SELECT can only be ''onset'' or ''offset''.');
end

if size(events, 2) == 2
    events(:, 3) = 1;
end

event_count = 1;
start = events(1,1);

cstream = zeros(total,2);
cstream(:,1) = times;
total_event = size(events, 1);

% For each time
for i = 1:total
    time = times(i);
    
%     % if this time is past the stop of the events, search for a new events.
%     while(time > stop && event_count < total_event)
%         event_count = event_count + 1;
%         start = events(event_count ,1);
%     end

    % Check if before events
    if(time < start)
        cstream(i,2) = 0;
    else
        cstream(i,2) = 1;
        event_count = event_count + 1;
        
        if event_count > total_event
            break;
        end
        
        start = events(event_count ,1);
    end
end
end
