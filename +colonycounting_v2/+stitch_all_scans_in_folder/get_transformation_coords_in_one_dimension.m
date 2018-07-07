function distance_to_transform = get_transformation_coords_in_one_dimension(image_stack, row_image_1, row_image_2, column_image_1, column_image_2, matrix_of_positions)

    % get the left image:
    im1 = image_stack(:, :, matrix_of_positions(row_image_1, column_image_1));
    
    % get the right image:
    im2 = image_stack(:, :, matrix_of_positions(row_image_2, column_image_2));
    
    % scale (?) images and convert to double:
    im1 = double(scale(im1));
    im2 = double(scale(im2));

    % register the image using cp select:
    [moving, fixed] = cpselect(im1, im2, 'Wait', true);

    % get the distance between the moving and fixed coords:
    distance_to_transform = moving - fixed;
    
    % get the median distance (for when the user set multiple points):
    distance_to_transform = median(distance_to_transform);
    
    % round the distance to a whole number:
    distance_to_transform = round(distance_to_transform);

end