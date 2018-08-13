function boundaries = gui_to_segment_a_stitch(stitch, boundaries, instructions)

    % create GUI:
    handles = create_GUI;
    
    % set default thresholds to use:
    threshold_min = 0.0;
    threshold_max = 1.0;
    
    % view image:
    view_image;

    % function to create GUI:
    function handles = create_GUI
        
        % create figure:
        handles.figure = figure('Units', 'pixels', ...
            'Position', [0 0 500 600]);
        
        % move gui to the center of the screen:
        movegui(handles.figure, 'center');
        
        % add image:
        handles.image = axes('Units', 'pixels', ...
            'Position', [30 10 440 440]);
        
        % add text to label lower contrast slider:
        handles.contrast_lower_text = uicontrol('Style', 'text', ...
            'Units', 'pixels', ...
            'Position', [10 460 480 15], ...
            'String', 'lower threshold');
        
        % add text to label upper contrast slider:
        handles.contrast_upper_text = uicontrol('Style', 'text', ...
            'Units', 'pixels', ...
            'Position', [10 495 480 15], ...
            'String', 'upper threshold');
        
        % add button to adjust lower end of contrast:
        handles.contrast_lower = uicontrol('Style', 'slider', ...
            'Units', 'pixels', ...
            'Position', [10 460 480 25], ...
            'Callback', @callback_contrast_lower, ...
            'min', 0, 'max', 1, 'Value', 0);
        
        % add button to adjust upper end of contrast:
        handles.contrast_upper = uicontrol('Style', 'slider', ...
            'Units', 'pixels', ...
            'Position', [10 495 480 25], ...
            'Callback', @callback_contrast_upper, ...
            'min', 0, 'max', 1, 'Value', 1);
        
        % add button to add a segmentation:
        handles.add = uicontrol('Style', 'pushbutton', ...
            'Units', 'pixels', ...
            'Position', [10 530 235 25], ...
            'String', 'Add Segmentation', ...
            'Callback', @callback_add);
        
        % add button to delete a segmentation:
        handles.delete = uicontrol('Style', 'pushbutton', ...
            'Units', 'pixels', ...
            'Position', [255 530 235 25], ...
            'String', 'Delete Segmentation', ...
            'Callback', @callback_delete);
        
        % add button to be done:
        handles.done = uicontrol('Style', 'pushbutton', ...
            'Units', 'pixels', ...
            'Position', [255 565 235 25], ...
            'String', 'Done', ...
            'Callback', @callback_done);
        
        % add instructions:
        uicontrol('Style', 'text', ...
            'Units', 'pixels', ...
            'Position', [10 565 235 25], ...
            'String', instructions);
        
    end

    % function to view the image:
    function view_image
        
        % display the image:
        imshow(imadjust(stitch, [threshold_min, threshold_max]), 'Parent', handles.image);
        
        % plot boundaries:
        plot_boundaries;
        
        % have program wait:
        uiwait(handles.figure);
        
    end

    % function to plot the boundaries:
    function plot_boundaries
       
        % turn on the hold:
        hold(handles.image, 'on'); 
        
        % for each boundary:
        for i = 1:numel(boundaries)
            
            % if boundary should be displayed:
            if strcmp(boundaries(i).status, 'keep')
                
                % get coordinates:
                temp_coords = boundaries(i).coordinates_boundary;
                
                % add first coordinate to end of coordinates (so boundary
                % plots closed):
                temp_coords(end+1, :) = temp_coords(1,:);
           
            	% plot coordinates on image:
                plot(temp_coords(:,1), temp_coords(:,2), 'red');
            
            end
            
        end
        
        % turn off the hold:
        hold(handles.image, 'off'); 
        
    end

    % function to adjust lower bound of contrast:
    function callback_contrast_lower(~,~)
        
        % get the slider value:
        threshold_min = get(handles.contrast_lower, 'Value');
        
        % show the image:
        view_image
        
    end

    % function to adjust upper bound of contrast:
    function callback_contrast_upper(~,~)
        
        % get the slider value:
        threshold_max = get(handles.contrast_upper, 'Value');
        
        % show the image:
        view_image;
        
    end

    % callback to add a segmentation:
    function callback_add(~, ~)
            
        % allow user to draw on the stitch:
        handle_boundary = imfreehand(handles.image, 'Closed', 'true');

        % create function that will constrain the user from drawing
        % boundaries outside the image:
        constrain_function = makeConstrainToRectFcn('imfreehand', [1 size(stitch,1)], [1 size(stitch, 2)]); 
        setPositionConstraintFcn(handle_boundary, constrain_function);

        % wait for user to double-click:
        wait(handle_boundary);

        % get status of boundary:
        temp.status = 'keep';
        
        % get coordinates of boundary:
        temp.coordinates_boundary = getPosition(handle_boundary);

        % round boundary coordinates:
        temp.coordinates_boundary = round(temp.coordinates_boundary);

        % convert boundary coordinates to mask coordinates:
        mask = poly2mask(temp.coordinates_boundary(:,1), temp.coordinates_boundary(:,2), size(stitch, 1), size(stitch, 2));
        [temp.coordinates_mask(:,1), temp.coordinates_mask(:,2)] = find(mask == 1);

        % save coords:
        boundaries = colonycounting_v2.utilities.add_entry_to_structure(temp, boundaries);

        % view image:
        view_image;

    end

    % callback to delete a segmentation:
    function callback_delete(~, ~)
        
        % wait until the user has clicked on the image:
        temp = waitforbuttonpress;

        % ask user to click on image:
        [point] = get(gca, 'CurrentPoint');

        % round point:
        point = fliplr(round(point(1, 1:2)));

        % for each current boundary point:
        for i = 1:numel(boundaries)

            % if point falls within mask:
            if ismember(point, boundaries(i).coordinates_mask, 'rows')

                % set that boundaries status to remove:
                boundaries(i).status = 'remove';

            end

        end

        % view the image:
        view_image;
        
    end

    % callback to be done:
    function callback_done(~,~)
        
        % remove any boundaries the user wanted to delete:
        boundaries = colonycounting_v2.utilities.get_structure_results_matching_string(boundaries, 'status', 'keep');
        
        % close the GUI:
        close(handles.figure);
        
    end

end