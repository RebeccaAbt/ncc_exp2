function data_browser(data, time)
    % Initializes the figure and plot with support for multiple datasets
    figure;
    num_datasets = size(data, 1);  % Number of rows (datasets)
    total_points = size(data, 2);  % Number of columns (data points)
    segment_length = 100;  % Initial number of data points per segment
    start_point = 1;
    end_point = min(segment_length, total_points);

    % Initialize plot lines array for multiple datasets
    hPlots = gobjects(num_datasets, 1); % Array to hold plot objects
    hold on;
    for i = 1:num_datasets
        hPlots(i) = plot(time(start_point:end_point), data(i, start_point:end_point));
    end
    hold off;
    ax = gca; % Current axes
    xlim([time(start_point), time(end_point)]);
    if sum(data(:, start_point:end_point)) == 0
        ylim([0 1])
    else
    ylim([min(min(data(:, start_point:end_point))), max(max(data(:, start_point:end_point)))]);
    end
    title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));

    % Add UI controls
    add_ui_controls();

    % Add listener for x-axis limit changes
    addlistener(ax, 'XLim', 'PostSet', @adjust_data_visibility);

    function add_ui_controls()
        uicontrol('Style', 'pushbutton', 'String', '<<', 'Position', [50 0 50 20], 'Callback', {@shift_data, -segment_length});
        uicontrol('Style', 'pushbutton', 'String', '>>', 'Position', [100 0 50 20], 'Callback', {@shift_data, segment_length});
        uicontrol('Style', 'pushbutton', 'String', 'horiz +', 'Position', [170 0 50 20], 'Callback', {@change_segment_length, -50});
        uicontrol('Style', 'pushbutton', 'String', 'horiz -', 'Position', [220 0 50 20], 'Callback', {@change_segment_length, 50});
        uicontrol('Style', 'pushbutton', 'String', 'Y-scale +', 'Position', [290 0 50 20], 'Callback', {@scale_y_axis, 0.7});  % Scale down by 30%
        uicontrol('Style', 'pushbutton', 'String', 'Y-scale -', 'Position', [340 0 50 20], 'Callback', {@scale_y_axis, 1.3});  % Scale up by 30%
    end

    function shift_data(~, ~, step)
        % Adjust start and end points based on the current axis limits
        current_xlims = xlim(ax);
        current_segment_length = end_point - start_point + 1;
        if step > 0
            start_point = find(time >= current_xlims(2), 1);
        else
            start_point = find(time <= current_xlims(1), 1) - current_segment_length + 1;
        end
        start_point = max(1, min(total_points - segment_length, start_point));
        end_point = start_point + current_segment_length - 1;
        update_plot();
    end

    function change_segment_length(~, ~, change)
        current_xlims = xlim(ax);
        current_segment_length = max(10, segment_length + change);
        segment_length = current_segment_length;
        start_point = find(time >= current_xlims(1), 1);
        end_point = start_point + current_segment_length - 1;
        update_plot();
    end

    function scale_y_axis(~, ~, factor)
        current_limits = ylim(ax);
        new_range = (current_limits(2) - current_limits(1)) * factor;
        new_center = mean(current_limits);
        new_limits = [new_center - new_range / 2, new_center + new_range / 2];
        ylim(ax, new_limits);
        title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
    end

    function adjust_data_visibility(~, ~)
        new_lims = xlim(ax);
        [~, start_idx] = min(abs(time - new_lims(1)));
        [~, end_idx] = min(abs(time - new_lims(2)));
        start_point = max(1, start_idx);
        end_point = min(end_idx, total_points);
        update_plot();
    end

    function update_plot()
        for i = 1:num_datasets
            set(hPlots(i), 'XData', time(start_point:end_point), 'YData', data(i, start_point:end_point));
        end
        xlim(ax, [time(start_point), time(end_point)]);
        ylim(ax, [min(min(data(:, start_point:end_point))), max(max(data(:, start_point:end_point)))]);
        title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
    end
end

%%


% function data_browser(data, time)
%     % Initializes the figure and plot with support for multiple datasets
%     figure;
%     num_datasets = size(data, 1);  % Number of rows (datasets)
%     total_points = size(data, 2);  % Number of columns (data points)
%     segment_length = 100;  % Initial number of data points per segment
%     start_point = 1;
%     end_point = min(segment_length, total_points);
% 
%     % Initial plot setup for multiple lines
%     hPlots = gobjects(num_datasets, 1); % Array to hold plot objects
%     hold on;
%     for i = 1:num_datasets
%         hPlots(i) = plot(time(start_point:end_point), data(i, start_point:end_point));
%     end
%     hold off;
%     ax = gca; % Current axes
%     xlim([time(start_point), time(end_point)]);
%     ylim([min(min(data(:, start_point:end_point))), max(max(data(:, start_point:end_point)))]);
%     title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
% 
%     % Add UI controls
%     add_ui_controls();
% 
%     % Add listener for x-axis limit changes
%     addlistener(ax, 'XLim', 'PostSet', @adjust_data_visibility);
% 
%     function add_ui_controls()
%         uicontrol('Style', 'pushbutton', 'String', '<<', 'Position', [50 0 50 20], 'Callback', {@shift_data, -segment_length});
%         uicontrol('Style', 'pushbutton', 'String', '>>', 'Position', [100 0 50 20], 'Callback', {@shift_data, segment_length});
%         uicontrol('Style', 'pushbutton', 'String', 'horiz +', 'Position', [170 0 50 20], 'Callback', {@change_segment_length, -50});
%         uicontrol('Style', 'pushbutton', 'String', 'horiz -', 'Position', [220 0 50 20], 'Callback', {@change_segment_length, 50});
%         uicontrol('Style', 'pushbutton', 'String', 'Y-scale +', 'Position', [290 0 50 20], 'Callback', {@scale_y_axis, 0.7});  % Scale down by 30%
%         uicontrol('Style', 'pushbutton', 'String', 'Y-scale -', 'Position', [340 0 50 20], 'Callback', {@scale_y_axis, 1.3});  % Scale up by 30%
%     end
% 
%     function adjust_data_visibility(~, ~)
%         new_lims = xlim(ax);
%         [~, start_idx] = min(abs(time - new_lims(1)));
%         [~, end_idx] = min(abs(time - new_lims(2)));
%         start_point = max(1, start_idx);
%         end_point = min(end_idx, total_points);
%         update_plot();
%     end
% 
%     function shift_data(~, ~, step)
%         start_point = max(1, min(total_points - segment_length, start_point + step));
%         end_point = start_point + segment_length - 1;
%         update_plot();
%     end
% 
%     function change_segment_length(~, ~, change)
%         segment_length = max(10, segment_length + change);
%         if start_point + segment_length - 1 > total_points
%             segment_length = total_points - start_point + 1;
%         end
%         end_point = start_point + segment_length - 1;
%         update_plot();
%     end
% 
%     function scale_y_axis(~, ~, factor)
%         current_limits = ylim;
%         new_range = (current_limits(2) - current_limits(1)) * factor;
%         new_center = mean(current_limits);
%         new_limits = [new_center - new_range / 2, new_center + new_range / 2];
%         ylim(new_limits);
%         title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
%     end
% 
%     function update_plot()
%         for i = 1:num_datasets
%             set(hPlots(i), 'XData', time(start_point:end_point), 'YData', data(i, start_point:end_point));
%         end
%         xlim([time(start_point), time(end_point)]);
%         ylim([min(min(data(:, start_point:end_point))), max(max(data(:, start_point:end_point)))]);
%         title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
%     end
% end


% function data_browser(data, time)
%     % Initializes the figure and plot
%     figure;
%     segment_length = 100;  % Initial number of data points per segment
%     total_points = length(data);  % Use length since data is a 1D column vector
%     start_point = 1;
%     end_point = min(segment_length, total_points);
% 
%     % Initial plot
%     hPlot = plot(time(start_point:end_point), data(start_point:end_point));
%     xlim([time(start_point), time(end_point)]);
%     ylim([min(data(start_point:end_point)), max(data(start_point:end_point))]);
%     title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
%     ax = gca; % Get the current axes
% 
%     % Add buttons for navigation and scaling
%     add_ui_controls();
% 
%     % Add a listener for x-axis limit changes
%     addlistener(ax, 'XLim', 'PostSet', @adjust_data_visibility);
% 
%     function add_ui_controls()
%         uicontrol('Style', 'pushbutton', 'String', '<<',...
%             'Position', [50 0 50 20],...
%             'Callback', {@shift_data, -segment_length});
% 
%         uicontrol('Style', 'pushbutton', 'String', '>>',...
%             'Position', [100 0 50 20],...
%             'Callback', {@shift_data, segment_length});
% 
%         uicontrol('Style', 'pushbutton', 'String', 'horiz +',...
%             'Position', [170 0 50 20],...
%             'Callback', {@change_segment_length, -50});
% 
%         uicontrol('Style', 'pushbutton', 'String', 'horiz -',...
%             'Position', [220 0 50 20],...
%             'Callback', {@change_segment_length, 50});
% 
%         uicontrol('Style', 'pushbutton', 'String', 'Y-scale +',...
%             'Position', [290 0 50 20],...
%             'Callback', {@scale_y_axis, 0.7});  % Scale down by 30%
% 
%         uicontrol('Style', 'pushbutton', 'String', 'Y-scale -',...
%             'Position', [340 0 50 20],...
%             'Callback', {@scale_y_axis, 1.3});  % Scale up by 30%
%     end
% 
%     function adjust_data_visibility(~, ~)
%         new_lims = xlim(ax);
%         [~, start_idx] = min(abs(time - new_lims(1)));
%         [~, end_idx] = min(abs(time - new_lims(2)));
%         start_point = max(1, start_idx);
%         end_point = min(end_idx, total_points);
%         update_plot();
%     end
% 
%     function shift_data(~, ~, step)
%         start_point = max(1, min(total_points - segment_length, start_point + step));
%         end_point = start_point + segment_length - 1;
%         update_plot();
%     end
% 
%     function change_segment_length(~, ~, change)
%         segment_length = max(10, segment_length + change);
%         if start_point + segment_length - 1 > total_points
%             segment_length = total_points - start_point + 1;
%         end
%         end_point = start_point + segment_length - 1;
%         update_plot();
%     end
% 
%     function scale_y_axis(~, ~, factor)
%         current_limits = ylim;
%         new_range = (current_limits(2) - current_limits(1)) * factor;
%         new_center = mean(current_limits);
%         new_limits = [new_center - new_range / 2, new_center + new_range / 2];
%         ylim(new_limits);
%         title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
%     end
% 
%     function update_plot()
%         set(hPlot, 'XData', time(start_point:end_point), 'YData', data(start_point:end_point));
%         xlim([time(start_point), time(end_point)]);
%         ylim([min(data(start_point:end_point)), max(data(start_point:end_point))]);
%         title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
%     end
% end




% function data_browser(data, time)
%     %{
%     kindly created by chatGPT with modifications
% 
%     Browse through data Matrix in ft_databrowser style
% 
%     data is a matrix where each row is a dataset and each column is a data point
%     time is a row vector corresponding to the time stamps of each data point
% 
%     %}
% 
%     figure;
%     segment_length = 100;  % Initial number of data points per segment
%     total_points = size(data, 2);  % Number of data points
%     num_datasets = size(data, 1);  % Number of datasets (rows in data)
%     start_point = 1;
%     end_point = min(segment_length, total_points);
% 
%     % Initialize plot lines array for multiple datasets
%     hPlots = gobjects(num_datasets, 1);
%     hold on; % Keep all plots in the same axes
%     for i = 1:num_datasets
%         hPlots(i) = plot(time(start_point:end_point), data(i, start_point:end_point));
%     end
%     hold off;
%     xlim([time(start_point), time(end_point)]);
%     ylim([min(min(data(:, start_point:end_point))), max(max(data(:, start_point:end_point)))]);
%     title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
% 
%     % Add buttons for navigation and scaling
%     uicontrol('Style', 'pushbutton', 'String', '<<',...
%         'Position', [50 0 50 20],...
%         'Callback', {@shift_data, -segment_length});
% 
%     uicontrol('Style', 'pushbutton', 'String', '>>',...
%         'Position', [100 0 50 20],...
%         'Callback', {@shift_data, segment_length});
% 
%     uicontrol('Style', 'pushbutton', 'String', 'horiz +',...
%         'Position', [170 0 50 20],...
%         'Callback', {@change_segment_length, -50});
% 
%     uicontrol('Style', 'pushbutton', 'String', 'horiz -',...
%         'Position', [220 0 50 20],...
%         'Callback', {@change_segment_length, 50});
% 
%     uicontrol('Style', 'pushbutton', 'String', 'Y-scale +',...
%         'Position', [290 0 50 20],...
%         'Callback', {@scale_y_axis, 0.7});  % Scale down by 30%
% 
%     uicontrol('Style', 'pushbutton', 'String', 'Y-scale -',...
%         'Position', [340 0 50 20],...
%         'Callback', {@scale_y_axis, 1.3});  % Scale up by 30%
% 
%     function shift_data(~, ~, step)
%         start_point = start_point + step;
%         if start_point < 1
%             start_point = 1; % Prevent going below 1
%         elseif start_point > total_points - segment_length
%             start_point = total_points - segment_length; % Prevent going beyond the data
%         end
%         end_point = start_point + segment_length - 1;
%         update_plot();
%     end
% 
%     function change_segment_length(~, ~, change)
%         segment_length = max(10, segment_length + change);
%         if start_point + segment_length - 1 > total_points
%             segment_length = total_points - start_point + 1;
%         end
%         end_point = start_point + segment_length - 1;
%         update_plot();
%     end
% 
%     function scale_y_axis(~, ~, factor)
%         current_limits = ylim;
%         new_range = (current_limits(2) - current_limits(1)) * factor;
%         new_center = mean(current_limits);
%         new_limits = [new_center - new_range / 2, new_center + new_range / 2];
%         ylim(new_limits);
%         title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
%     end
% 
%     function update_plot()
%         for i = 1:num_datasets
%             set(hPlots(i), 'XData', time(start_point:end_point), 'YData', data(i, start_point:end_point));
%         end
%         xlim([time(start_point), time(end_point)]);
%         ylim([min(min(data(:, start_point:end_point))), max(max(data(:, start_point:end_point)))]);
%         title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
%     end
% end




% function data_browser(data, time)
% 
% %{
% kindly created by chatGPT
% 
% brows through data Matrix in ft_databrowser style
% 
% data is a column vector where each element is a data point
% time is a row vector corresponding to the time stamps of each data point
% 
% %}
% 
% figure;
% segment_length = 100;  % Initial number of data points per segment
% total_points = length(data);  % Use length since data is a 1D column vector
% start_point = 1;
% end_point = min(segment_length, total_points);
% 
% % Initial plot
% hPlot = plot(time(start_point:end_point), data(start_point:end_point));
% xlim([time(start_point), time(end_point)]);
% ylim([min(data(start_point:end_point)), max(data(start_point:end_point))]);
% title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
% 
% % Add buttons for navigation
% uicontrol('Style', 'pushbutton', 'String', '<<',...
%     'Position', [50 0 50 20],...
%     'Callback', {@shift_data, -segment_length});
% 
% uicontrol('Style', 'pushbutton', 'String', '>>',...
%     'Position', [100 0 50 20],...
%     'Callback', {@shift_data, segment_length});
% 
% % Buttons for changing segment length
% uicontrol('Style', 'pushbutton', 'String', 'horiz +',...
%     'Position', [170 0 50 20],...
%     'Callback', {@change_segment_length, -50});
% 
% uicontrol('Style', 'pushbutton', 'String', 'horiz -',...
%     'Position', [220 0 50 20],...
%     'Callback', {@change_segment_length, 50});
% 
% uicontrol('Style', 'pushbutton', 'String', 'Y-scale +',...
%     'Position', [290 0 50 20],...
%     'Callback', {@scale_y_axis, 0.7});  % Scale down by 10%
% 
% % Buttons for manual y-axis scaling
% uicontrol('Style', 'pushbutton', 'String', 'Y-scale -',...
%     'Position', [340 0 50 20],...
%     'Callback', {@scale_y_axis, 1.3});  % Scale up by 10%
% 
% 
%     function shift_data(~, ~, step)
%         start_point = start_point + step;
%         if start_point < 1
%             start_point = 1; % Prevent going below 1
%         elseif start_point > total_points - segment_length
%             start_point = total_points - segment_length; % Prevent going beyond the data
%         end
%         end_point = start_point + segment_length - 1;
%         update_plot();
%     end
% 
%     function change_segment_length(~, ~, change)
%         segment_length = max(10, segment_length + change); % Ensure segment length is at least 10
%         if start_point + segment_length - 1 > total_points
%             segment_length = total_points - start_point + 1; % Adjust to prevent overflow
%         end
%         end_point = start_point + segment_length - 1;
%         update_plot();
%     end
% 
%     function scale_y_axis(~, ~, factor)
%         current_limits = ylim;
%         new_range = (current_limits(2) - current_limits(1)) * factor;
%         new_center = mean(current_limits);
%         new_limits = [new_center - new_range / 2, new_center + new_range / 2];
%         ylim(new_limits);
%         title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
%     end
% 
%     function update_plot()
%         set(hPlot, 'XData', time(start_point:end_point), 'YData', data(start_point:end_point));
%         xlim([time(start_point), time(end_point)]);
%         ylim([min(data(start_point:end_point)), max(data(start_point:end_point))]);
%         title(sprintf('Showing time %f to %f', time(start_point), time(end_point)));
%     end
% end
