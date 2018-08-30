function boundaries = guess_colonies(cells, boundaries, stitch_small)

    % get cell coordinates:
    cells_x = cells(:,1);
    cells_y = cells(:,2);

    % get number of cells:
    num_cells = numel(cells_x);
    
    % create binary image with cell positions:
    image = zeros(size(stitch_small));
    for i = 1:num_cells
        y = round(cells_y(i)) + 1;
        x = round(cells_x(i)) + 1;
       image(y, x) = image(y, x) + 1; 
    end
    image = logical(image);
    
    % get density image:
    image_density = colonycounting_v2.segment_all_scans.guess_colonies.create_density_image(image, 15);

    % thresold density image:
    image_density_centroids = image_density;
    image_density_centroids(image_density_centroids < 50) = 0;
    image_density_cells =  image_density;   
    image_density_cells(image_density_cells < 25) = 0;
    
    % remove objects on the border:
    image_density_centroids = imclearborder(image_density_centroids);
    image_density_cells = imclearborder(image_density_cells);
    
    % remove objets with very large area:
    area_threshold = 0.2;
    image_density_centroids_2 = bwareaopen(image_density_centroids, round(area_threshold*numel(stitch_small))) - image_density_centroids;
    imshow([image_density_centroids, image_density_centroids_2]);
    
    temp_boundaries = bwboundaries(image_density_cells);
    
    for i = 1:numel(temp_boundaries)
       
            temp.status = 'keep';
            
            temp.coordinates_boundary = fliplr(temp_boundaries{i});
            
            temp_mask = poly2mask(temp.coordinates_boundary(:,1), temp.coordinates_boundary(:,2), size(stitch_small, 1), size(stitch_small, 2));
            [temp_colony_mask_x, temp_colony_mask_y] = find(temp_mask == 1);
            temp.coordinates_mask = [temp_colony_mask_x, temp_colony_mask_y];
            
            boundaries = colonycounting_v2.utilities.add_entry_to_structure(temp, boundaries);
        
    end
    
%     % get the centroids of the colonies:
%     [colony_centroids_x, colony_centroids_y] = colonycounting_v2.segment_all_scans.guess_colonies.get_colony_centroids(image_density_centroids);
% 
%     % assign cells to colonies:
%     colony_assignment = colonycounting_v2.segment_all_scans.guess_colonies.assign_cells_to_centroids(cells_x, cells_y, image_density_cells, colony_centroids_x, colony_centroids_y);
%     
%     % use the cell assignments to get colony boundaries:
%     boundaries = colonycounting_v2.segment_all_scans.guess_colonies.get_colony_boundaries(boundaries, cells_x, cells_y, colony_assignment, stitch_small);

end