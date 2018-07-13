function boundaries_well = gui_to_segment_a_stitch(stitch, boundaries_well, instructions, enable_multiple)

    % create GUI:
    handles = create_GUI;
    
    % view image:
    view_image
    
    % have GUI wait:
    uiwait(handles.figure);
    
    boundaries_well = 4;

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
        
    end

    % function to plot the boundaries:
    function plot_boundaries
       
        
        
    end

    % callback to add a segmentation:
    function callback_add(~,~)
        
        % allow user to draw on the stitch:
        handle_boundary = imfreehand(handles.image, 'Closed', true);
        
        % get coordinates of boundary:
        coords = getPosition(handle_boundary);
        
        
        
    end

    % callback to delete a segmentation:
    function callback_delete(~,~)
        
    end

    % callback to be done:
    function callback_done(~,~)
        
        % close the GUI:
        close(handles.figure);
        
    end

end