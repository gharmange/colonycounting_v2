function boundaries = gui_to_segment_a_stitch(stitch, boundaries, instructions)

    % create GUI:
    handles = create_GUI;
    
    % view image:
    view_image;

    % function to create GUI:
    function handles = create_GUI
        
        % create figure:
        handles.figure = figure('Units', 'pixels', ...
            'Position', [0 0 500 630]);
        
        % move gui to the center of the screen:
        movegui(handles.figure, 'center');
        
        % add image:
        handles.image = axes('Units', 'pixels', ...
            'Position', [10 10 480 480]);
        
        % add button to add a segmentation:
        handles.add = uicontrol('Style', 'pushbutton', ...
            'Units', 'pixels', ...
            'Position', [10 500 235 50], ...
            'String', 'Add Segmentation', ...
            'Callback', @callback_add);
        
        % add button to delete a segmentation:
        handles.delete = uicontrol('Style', 'pushbutton', ...
            'Units', 'pixels', ...
            'Position', [255 500 235 50], ...
            'String', 'Delete Segmentation', ...
            'Callback', @callback_delete);
        
        % add button to be done:
        handles.done = uicontrol('Style', 'pushbutton', ...
            'Units', 'pixels', ...
            'Position', [255 560 235 50], ...
            'String', 'Done', ...
            'Callback', @callback_done);
        
        % add instructions:
        uicontrol('Style', 'text', ...
            'Units', 'pixels', ...
            'Position', [10 560 235 50], ...
            'String', instructions);
        
    end

    % function to view the image:
    function view_image
        
        % display the image:
        imshow(stitch, 'Parent', handles.image);
        
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
            
            % if boundary coords are not empty:
            if ~isempty(boundaries(i).coordinates_boundary)
                
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

        % get coordinates of boundary:
        temp.number = 1;
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

        % create array to store rows to remove:
        rows_remove = [];

        % for each current boundary point:
        for i = 1:numel(boundaries)

            % if point falls within mask:
            if ismember(point, boundaries(i).coordinates_mask, 'rows')

                % add row to list of rows to remove:
                rows_remove = [rows_remove i];

            end

        end

        % remove boundaries:
        boundaries(rows_remove) = [];

        % view the image:
        view_image;
        
    end

    % callback to be done:
    function callback_done(~,~)
        
        % close the GUI:
        close(handles.figure);
        
    end

end