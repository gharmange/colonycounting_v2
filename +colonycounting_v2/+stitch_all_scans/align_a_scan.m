function [transform_coords_row, transform_coords_column] = align_a_scan(list_images, num_rows, num_columns)

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
    
    % get y transformation coordinates:
    transform_coords_column = ...
        colonycounting_v2.stitch_all_scans.get_transformation_coords_in_one_dimension(...
        list_images, ...
        position_num_middle, ...
        position_num_below);
    
    % get x transformation coordinates:
    transform_coords_row = ...
        colonycounting_v2.stitch_all_scans.get_transformation_coords_in_one_dimension(...
        list_images, ...
        position_num_middle, ...
        position_num_below);

end
