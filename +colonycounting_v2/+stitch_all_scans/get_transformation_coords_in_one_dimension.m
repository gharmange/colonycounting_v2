function distance_to_transform = get_transformation_coords_in_one_dimension(list_images, position_num_1, position_num_2)

    % convert position numbers to strings:
    position_num_1_string = ['s' num2str(position_num_1, '%.0f')];
    position_num_2_string = ['s' num2str(position_num_2, '%.0f')];

    % get name and path of images:
    image_info_left = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', position_num_1_string);
    image_info_right = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', position_num_2_string);
    
    % load the images:
    image_left = readmm(fullfile(image_info_left(1).folder, image_info_left(1).name));
    image_left = image_left.imagedata;
    image_right = readmm(fullfile(image_info_right(1).folder, image_info_right(1).name));
    image_right = image_right.imagedata;
    
    % scale images and convert to double:
    image_left = double(scale(image_left));
    image_right = double(scale(image_right));

    % register the image using cp select:
    [moving, fixed] = cpselect(image_left, image_right, 'Wait', true);

    % get the distance between the moving and fixed coords:
    distance_to_transform = moving - fixed;
    
    % get the median distance (for when the user set multiple points):
    distance_to_transform = median(distance_to_transform, 1);
    
    % round the distance to a whole number (since you cannot have half a pixel):
    distance_to_transform = round(distance_to_transform);

end