function boundaries = get_cells_within_boundaries(centroids, boundaries)

    % get number of boundaries:
    num_boundaries = numel(boundaries);
    
    % add field to store centroids within each boundary:
    [boundaries(1:num_boundaries).centroids] = deal(struct);
    
    % for each boundary:
    for i = 1:num_boundaries

        % get row indices of centroids that overlap with the object mask:
        centroid_row = centroids.all.coordinates_original(:,1);
        centroid_col = centroids.all.coordinates_original(:,2);
        boundary_row = boundaries(i).coordinates_boundary_original(:,1);
        boundary_col = boundaries(i).coordinates_boundary_original(:,2);
        rows = inpolygon(centroid_col, centroid_row, boundary_col, boundary_row);

        % save centroids that overlap with object:
        boundaries(i).centroids.coordinates_original = centroids.all.coordinates_original(rows, :);
        boundaries(i).centroids.coordinates_small = centroids.all.coordinates_small(rows, :);
        
    end

end