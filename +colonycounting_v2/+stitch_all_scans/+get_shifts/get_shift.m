function [shift_column, shift_row] = get_shift(images, num_rows, num_columns, folder, name_scan)

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
    
    % get the tile number of the middle image of the scan:
    tile_row_middle = round(num_rows/2);
    tile_column_middle = round(num_columns/2);
    
    % get the position number of the middle image of the scan:
    position_num_middle = matrix_of_positions(tile_row_middle, tile_column_middle);
    
    % get the position number of the image below the middle of the scan:
    position_num_below = matrix_of_positions(tile_row_middle + 1, tile_column_middle);
    
    % get the position number of the image right the middle of the scan:
    position_num_right = matrix_of_positions(tile_row_middle, tile_column_middle + 1);
    
    % convert position numbers to strings:
    position_num_middle_string = ['s' num2string(position_num_middle, '%.0f')];
    position_num_below_string = ['s' num2string(position_num_below, '%.0f')];
    position_num_right_string = ['s' num2string(position_num_right, '%.0f')];
    
    % get name and path of images:
    image_info_middle = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', position_num_middle_string);
    image_info_below = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', position_num_below_string);
    image_info_right = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', position_num_right_string);
    
    % load the images:
    image_middle = readmm(fullfile(image_info_middle(1).folder, image_info_middle(1).name));
    image_middle = image_middle.imagedata;
    image_below = readmm(fullfile(image_info_below(1).folder, image_info_below(1).name));
    image_below = image_below.imagedata;
    image_right = readmm(fullfile(image_info_right(1).folder, image_info_right(1).name));
    image_right = image_right.imagedata;
    
    % scale images and convert to double:
    image_middle = double(scale(image_middle));
    image_below = double(scale(image_below));
    image_right = double(scale(image_right));
    
    % display images:
    handle_display = figure;
    imshow([image_middle, image_below, image_right]);
    
    % ask user how they want to align them
    type_alignment = questdlg('Do you want to align the images visually or enter an overlap?', 'Alignment', 'Visually', 'Enter an Overlap', 'Visually');
    
    % close the image:
    close(handle_display);
    
    % depending on the answer:
    switch type_alignment
        
        case 'Visually'
            
            % get column shift distances:
            shift_column = colonycounting_v2.stitch_all_scans.get_shifts.get_shift_visually(image_middle, image_below);
            
            % get row shift distances:
            shift_row = colonycounting_v2.stitch_all_scans.get_shifts.get_shift_visually(image_middle, image_right);
            
        case 'Enter an Overlap'
            
            % get coordinates:
            [shift_column, shift_row] = colonycounting_v2.stitch_all_scans.get_shifts.get_shift_overlap(folder, name_scan);
            
            % adjust shift distances so that they have the same axes as
            % those set visually:
            shift_column.column = size(image_middle, 1) - shift_column.column;
            shift_row.row = size(image_middle, 1) - shift_row.row;
            
    end

end