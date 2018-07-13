function stitch_a_scan(stitch_info)

    % for each wavelength:
    for j = 1:numel(stitch_info.images)
        
        %%% First, we need to load all of the images:

        % load an image:
        temp_image = imread(fullfile(stitch_info.path_folder, stitch_info.images(j).list_images(1).name));

        % get the image size:
        image_size = size(temp_image, 1);

        % get number of positions:
        num_positions = stitch_info.num_tiles_row * stitch_info.num_tiles_column;

        % create empty array to store the positions as a z-stack:
        image_stack = zeros(image_size, image_size, num_positions, 'uint16');

        % for each position:
        for i = 1:num_positions

            % get the name of the image:
            temp_image_name = sprintf('%s_%s_s%s_t1.TIF', stitch_info.name_scan, stitch_info.images(j).wavelength, num2str(i));

            % load the image into the stack:
            image_stack(:,:,i) = uint16(imread(fullfile(stitch_info.path_folder, temp_image_name)));

        end

        %%% Next, we need to set up the coordinates for the stitch. 

        % create array with list of position numbers:
        array_of_positions = 1:num_positions;

        % arrange position numbers into matrix (same order that scope acquires images):
        matrix_of_positions = reshape(array_of_positions, stitch_info.num_tiles_row, stitch_info.num_tiles_column);

        % create arrays to store the coordinates for the upper left corner of
        % each position:
        coords_ul_corner_row = zeros(num_positions, 1);
        coords_ul_corner_column = zeros(num_positions, 1);

        % for each position:
        for i = 1:numel(array_of_positions)

            % get the row and column number of the position:
            [temp_row, temp_col] = find(matrix_of_positions == i);

            % convert the row and column number into coordinates:
            coords_ul_corner_row(i)  = temp_row * stitch_info.transform_coords_column(2) + temp_col * stitch_info.transform_coords_row(2);
            coords_ul_corner_column(i) = temp_row * stitch_info.transform_coords_column(1)+ temp_col * stitch_info.transform_coords_row(1);

        end

        % make it so that the coordinates start at 1:
        coords_ul_corner_row = coords_ul_corner_row - min(coords_ul_corner_row) + 1;
        coords_ul_corner_column = coords_ul_corner_column - min(coords_ul_corner_column) + 1;

        % get coordinates for the lower right corner:
        coords_lr_corner_row = coords_ul_corner_row + image_size - 1;
        coords_lr_corner_column = coords_ul_corner_column + image_size - 1;

        %%% Next, we need to add each position to the stitched image.

        % creating an empty array to store stitched image:
        image_stitched = zeros(max(coords_ul_corner_row) + image_size - 1, max(coords_ul_corner_column) + image_size - 1, 'uint16');

        % for each position (starting at the end and counting down):
        for i = num_positions:-1:1

            % get the image slice and convert to double:
            temp_image_slice = image_stack(:,:,i);

            % set 
            image_stitched(...
                coords_ul_corner_row(i):coords_lr_corner_row(i), ...
                coords_ul_corner_column(i):coords_lr_corner_column(i) ...
                ) = im2uint16(temp_image_slice);

        end

        % scale the stitched image:
        image_stitched = scale(image_stitched);
        
        % create a downsized version of the image:
        image_stitched_small = imresize(image_stitched, [image_size image_size]);

        % set file name:
        file_name = fullfile(stitch_info.path_folder, sprintf('Stitch_%s_%s', stitch_info.name_scan, stitch_info.images(j).wavelength));

        % set images to save:
        image_to_save = imadjust(im2uint8(image_stitched));
        image_to_save_small = imadjust(im2uint8(image_stitched_small));

        % save image as jpg:
        imwrite(image_to_save, [file_name '.jpg']);

        % save image as tif:
        imwrite(image_to_save, [file_name '.tif']);

        % save image as mat:
        save([file_name '.mat'], 'image_to_save', '-v7.3');
        save([file_name '_small.mat'], 'image_to_save_small', '-v7.3');
        
    end

    % save stitch info:
    save(fullfile(stitch_info.path_folder, sprintf('Stitch_Info_%s.mat', stitch_info.name_scan)), 'stitch_info');
    
end