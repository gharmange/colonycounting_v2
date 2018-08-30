function [shift_column, shift_row, image_size] = get_shift(images, num_rows, num_columns, path_images, name_folder, name_scan)

    % if there is only one wavelength:
    if numel(images) == 1

        % use that wavelength to align:
        list_images = images.list_images;

    % otherwise:
    else

        % use dapi:
        list_images = colonycounting_v2.utilities.get_structure_results_matching_string(images, 'channel', 'dapi');
        list_images = list_images.list_images;

    end

    % create array with list of position numbers:
    array_of_positions = 1:(num_rows * num_columns);
    
    % arrange position numbers into matrix (same order that scope acquires images):
    matrix_of_positions = reshape(array_of_positions, num_rows, num_columns);
    
    % get the row and column of the middle position to use for the alignment:
    tile_row_middle = round(num_rows/2);
    tile_column_middle = round(num_columns/2);
    
    % ask user if they would like to input position to use for alignment.
    question = 'Would you like to specify an image to use for visual alignment?';
    title = 'Scan Alignment';
    answer = questdlg(question, title, 'Yes.', 'No. Just use the default.', 'No. I will enter an overlap manually', 'No. Just use the default.');

    % depending on the answer:
    switch answer
        
        % if the user wants to enter a position:
        case 'Yes.'
            
            % get the users desired image position:
            prompt = [{sprintf('Entor row (1-%d)', num_rows)}, {sprintf('Entor column (1-%d)', num_columns)}];
            title = 'Which image would you like to use for alignment?';
            position = inputdlg(prompt, title, [1 50]);
            position = str2double(position);
            
            % if the position is in range of the scan: 
            if all(position > 1 & position(1) <= num_rows & position(2) <= num_columns) 
                
                % update the position to use for the alignment:
                tile_row_middle = position(1);
                tile_column_middle = position(2); 
                
            end
            
        % if the user wants to use the default:
        case 'No. Just use the default.'
            
            % do nothing
        
        % if the user wants to enter an overlap:
        case 'No. I will enter an overlap manually'
            
            % do nothing
            
    end
   
    % get the position of the images used to calculate overlap
    position_num_middle = matrix_of_positions(tile_row_middle, tile_column_middle);
    
    % get the position of the image below:
    position_num_below = matrix_of_positions(tile_row_middle + 1, tile_column_middle);
    
    % get the position of the image right:
    position_num_right = matrix_of_positions(tile_row_middle, tile_column_middle + 1);
    
    % convert position numbers to strings:
    position_num_middle_string = ['s' num2str(position_num_middle, '%.0f')];
    position_num_below_string = ['s' num2str(position_num_below, '%.0f')];
    position_num_right_string = ['s' num2str(position_num_right, '%.0f')];
    
    % get name and path of images:
    image_info_middle = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', position_num_middle_string);
    image_info_below = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', position_num_below_string);
    image_info_right = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', position_num_right_string);
    
    % load the images:
    image_middle = readmm(fullfile(path_images, image_info_middle(1).name));
    image_middle = image_middle.imagedata;
    image_below = readmm(fullfile(path_images, image_info_below(1).name));
    image_below = image_below.imagedata;
    image_right = readmm(fullfile(path_images, image_info_right(1).name));
    image_right = image_right.imagedata;

    % get image size:
    image_size = size(image_middle, 1);
    
    % scale images and convert to double:
    image_middle = double(scale(image_middle));
    image_below = double(scale(image_below));
    image_right = double(scale(image_right));
    
    % display images:
    image_display = [image_middle, image_right; image_below zeros(size(image_middle), 'like', image_middle)];
    handle_display = figure;
    imshow(image_display);
    
    % ask user how they want to align them
    type_alignment = questdlg('Do you want to align the images visually or enter an overlap?', 'Alignment', 'Visually', 'Enter an Overlap', 'Visually');
    
    % close the image:
    close(handle_display);
    
    % depending on the answer:
    switch type_alignment
        
        case 'Visually'
            
            % get column shift distances:
            shift_column = colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_shift_visually(image_middle, image_below);
            
            % get row shift distances:
            shift_row = colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_shift_visually(image_middle, image_right);
            
        case 'Enter an Overlap'
            
            % get coordinates:
            [shift_column, shift_row] = colonycounting_v2.stitch_all_scans.get_shifts_to_align.get_shift_overlap(name_folder, name_scan);
            
            % adjust shift distances so that they have the same axes as
            % those set visually:
            shift_column.column = size(image_middle, 1) - shift_column.column;
            shift_row.row = size(image_middle, 1) - shift_row.row;
            
    end

end