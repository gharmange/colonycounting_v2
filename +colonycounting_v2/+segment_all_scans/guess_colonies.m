function boundaries = guess_colonies(cells, boundaries, stitch_small)

    % get cell coordinates:
    cells_x = cells(:,1);
    cells_y = cells(:,2);

    % get number of cells:
    num_cells = numel(cells_x);
    
    % create binary image with cell positions:
    image = zeros(size(stitch_small));
    for i = 1:num_cells
       image(cells_y(i)+1, cells_x(i)+1) = 1; 
    end
    image = logical(image);
    
    % get density image:
    image_density = colonycounting_v2.segment_all_scans.guess_colonies.create_density_image(image, 15);

    % thresold density image:
    image_density_centroids = image_density;
    image_density_centroids(image_density_centroids < 50) = 0;
    image_density_cells =  image_density;   
    image_density_cells(image_density_cells < 25) = 0;
    
    % get the centroids of the colonies:
    [colony_centroids_x, colony_centroids_y] = colonycounting_v2.segment_all_scans.guess_colonies.get_colony_centroids(image_density_centroids);

    % assign cells to colonies:
    colony_assignment = colonycounting_v2.segment_all_scans.guess_colonies.assign_cells_to_centroids(cells_x, cells_y, image_density_cells, colony_centroids_x, colony_centroids_y);
    
    % use the cell assignments to get colony boundaries:
    boundaries = colonycounting_v2.segment_all_scans.guess_colonies.get_colony_boundaries(boundaries, cells_x, cells_y, colony_assignment, stitch_small);

end