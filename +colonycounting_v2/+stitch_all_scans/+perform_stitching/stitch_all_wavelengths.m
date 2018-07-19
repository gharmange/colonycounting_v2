function stitch_all_wavelengths(scan)
    
    %%% First, we want to determine by how much to shift each pixel in x
    %%% and y (accounting for both the shift due to the row and the shift
    %%% due to the column).
    
    % get number of positions:
    num_positions = scan.num_tiles_row * scan.num_tiles_column;

    % create array with list of position numbers:
    array_of_positions = 1:num_positions;

    % arrange position numbers into matrix (same order that scope acquires images):
    matrix_of_positions = reshape(array_of_positions, scan.num_tiles_row, scan.num_tiles_column);

    % create arrays to store the shift amounts for each position:
    shift_in_x = zeros(num_positions, 1);
    shift_in_y = zeros(num_positions, 1);

    % for each position:
    for i = 1:num_positions

        % get the row and column number of the position:
        [position_row, position_column] = find(matrix_of_positions == i);
        
        % determine the shift (in x and y) due to the row:
        shift_in_x_row = position_column * scan.shift_row.column;
        shift_in_y_row = position_column * scan.shift_row.row;
        
        % determine the shift (in x and y) due to the column:
        shift_in_x_column = position_row * scan.shift_column.column;
        shift_in_y_column = position_row * scan.shift_column.row;
        
        % determine the total shift:
        shift_in_x(i) = shift_in_x_row + shift_in_x_column;
        shift_in_y(i) = shift_in_y_row + shift_in_y_column;
        
    end

    %%% Next, we want to convert the shift amounts into coordinates in the
    %%% reference frame of the stitched image. The easiest way to do this
    %%% is to offset the shifts so that they start at 1. 
    
    % offset the shift amounts to create the coordinates of the upperleft
    % corner of each image:
    coords_ul_corner_row = shift_in_y - min(shift_in_y) + 1;
    coords_ul_corner_column = shift_in_x - min(shift_in_x) + 1;
    
    % load an image to get the image size:
    temp_image = imread(fullfile(scan.path_folder, scan.images(1).list_images(1).name));
    image_size = size(temp_image, 1);
    
    % get coordinates for the lower right corner:
    coords_lr_corner_row = coords_ul_corner_row + image_size - 1;
    coords_lr_corner_column = coords_ul_corner_column + image_size - 1;

    %%% Next, we want to load all images and create the stitched
    %%% image. We will do this for every wavelength.
    
    % for each wavelength:
    for i = 1:numel(scan.images)
       
        %%% First, we need to load all of the images:

        % create empty array to store the positions as a z-stack:
        image_stack = zeros(image_size, image_size, num_positions, 'uint16');

        % for each position:
        for j = 1:num_positions

            % get the name of the image:
            temp_image_name = sprintf('%s_%s_s%s_t1.TIF', scan.name_scan, scan.images(i).wavelength, num2str(j));

            % load the image into the stack:
            image_stack(:,:,j) = im2uint16(imread(fullfile(scan.path_folder, temp_image_name)));

        end

        %%% Next, we need to add each position to the stitched image.

        % create an empty array to store stitched image:
        image_stitched = zeros(max(coords_ul_corner_row) + image_size - 1, max(coords_ul_corner_column) + image_size - 1, 'uint16');

        % for each position (starting at the end and counting down):
        for j = num_positions:-1:1

            % get the image slice and convert to double:
            temp_image_slice = image_stack(:,:,j);

            % set 
            image_stitched(...
                coords_ul_corner_row(j):coords_lr_corner_row(j),...
                coords_ul_corner_column(j):coords_lr_corner_column(j) ...
                ) = temp_image_slice;

        end
        
        % create a downsized version of the image:
        image_stitched_small = imresize(image_stitched, [image_size image_size]);
        
        % get the scale factor:
        scan.scale_rows = size(image_stitched, 1) / image_size;
        scan.scale_columns = size(image_stitched, 2) / image_size;

        % set file name:
        file_name = fullfile(scan.path_folder, sprintf('Stitch_%s_%s', scan.name_scan, scan.images(i).channel));
        file_name_small = fullfile(scan.path_folder, sprintf('Stitch_%s_%s_small', scan.name_scan, scan.images(i).channel));

        % set images to save:
        image_to_save = image_stitched;
        image_to_save_small = image_stitched_small;

        % save image as tif:
        imwrite(image_to_save, [file_name '.tif']);
        imwrite(image_to_save_small, [file_name_small '.tif']);

        % save image as mat:
        save([file_name '.mat'], 'image_to_save', '-v7.3');
        save([file_name_small '.mat'], 'image_to_save_small', '-v7.3');
            
    end

    % save stitch info for the entire scan:
    save(fullfile(scan.path_folder, sprintf('Stitch_Info_%s.mat', scan.name_scan)), 'scan');

end