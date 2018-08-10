function boundaries = scale_coords_boundary_up(boundaries, scale_rows, scale_columns)
    
    % scale well boundaries:
    boundaries.original.well = scale_coords_boundary(boundaries.small.well, scale_rows, scale_columns);
    
    % scale colony boundaries:
    boundaries.original.colonies = scale_coords_boundary(boundaries.small.colonies, scale_rows, scale_columns);

end

function boundaries = scale_coords_boundary(boundaries, scale_rows, scale_columns)

    % get number of boundaries:
    num_boundaries = numel(boundaries);
    
    % add fields to store scaled coords:
    [boundaries(1:num_boundaries).coordinates_boundary_original] = deal([]);
    [boundaries(1:num_boundaries).coordinates_mask_original] = deal([]);

    % for each boundary:
    for i = 1:num_boundaries
       
        % get coords:
        coordinates_mask = boundaries(i).coordinates_mask_small;
        coordinates_boundary = boundaries(i).coordinates_boundary_small;
        
        % scale coords:
        coordinates_mask_original = colonycounting_v2.utilities.scale_coords(coordinates_mask, scale_rows, scale_columns);
        coordinates_boundary_original = colonycounting_v2.utilities.scale_coords(coordinates_boundary, scale_rows, scale_columns);
        
        % save:
        boundaries(i).coordinates_mask_original = coordinates_mask_original;
        boundaries(i).coordinates_boundary_original = coordinates_boundary_original;
        
    end
    
end