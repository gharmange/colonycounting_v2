function image_annotated = add_all_boundaries_to_stitch(image, boundaries)

    % create rgb version of image:
    image_annotated = repmat(image, 1, 1, 3);
    
    % get colors for each type of boundary:
    color.well = [0 1 0];
    color.colonies = [1 0 0];
    
    % for each well boundary:
    for j = 1:numel(boundaries.well)

        % add to image:
        image_annotated = colonycounting_v2.utilities.add_boundary_to_stitch(image_annotated, boundaries.well(j).coordinates_boundary_small, color.well);

    end

    % for each colony boundary:
    for j = 1:numel(boundaries.colonies)

        % add to image:
        image_annotated = colonycounting_v2.utilities.add_boundary_to_stitch(image_annotated, boundaries.colonies(j).coordinates_boundary_small, color.colonies);

    end

end