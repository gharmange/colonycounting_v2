function image_annotated = add_all_boundaries_to_stitch(image, boundaries)

    % create rgb version of image:
    image_annotated = repmat(image, 1, 1, 3);
    
    % get list of boundaries:
    boundary_types = fieldnames(boundaries);
    
    % get number of boundary types:
    num_boundary_types = numel(boundary_types);
    
    % get colors for each type of boundary:
    colors = jet(num_boundary_types);
    
    % for each type of boundary:
    for i = 1:numel(boundary_types)
       
        % for each boundary:
        for j = 1:numel(boundaries.(boundary_types{i}))
            
            % add to image:
            image_annotated = colonycounting_v2.segment_all_scans.add_boundary_to_stitch(image_annotated, boundaries.(boundary_types{i})(j).coordinates_boundary, colors(i,:));
            
        end
        
    end

end