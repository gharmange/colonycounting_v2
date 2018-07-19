function image_annotated = add_all_boundaries_and_cells_to_stitch(image, centroids, boundaries)

    % create rgb-version of image:
    image_annotated = repmat(image, 1, 1, 3);
    
    %%% NOTE: I add the various cells and boundaries in a particular order
    %%% so that things are most visible. 
    
    %%% Next, we want to plot ALL cells.
    
    % set color:
    color.cells.all = [0 0 1];
    
    % add cells to image:
    image_annotated = colonycounting_v2.utilities.add_cell_to_stitch(image_annotated, centroids.all.coordinates_original, color.cells.all, 15);
    
    %%% Next, we want to plot all cells within the well:
    
    % set color for well:
    color.cells.well = [0 1 0];
    
    % for each well:
    for i = 1:numel(boundaries.well)
        
        % add cells to image:
        image_annotated = colonycounting_v2.utilities.add_cell_to_stitch(image_annotated, boundaries.well(i).centroids.coordinates_original, color.cells.well, 15);
    
    end
    
    %%% Next, we wan to plot all cells assigned to colonies:
    
    % get number of colonies:
    num_colonies = numel(boundaries.colonies);
    
    % get colors for each colony:
    color.cells.colonies = distinguishable_colors(num_colonies, {'w', 'k', 'b', 'g'});
    
    % for each colony:
    for i = 1:numel(boundaries.colonies)
        
        % add cells to image:
        image_annotated = colonycounting_v2.utilities.add_cell_to_stitch(image_annotated, boundaries.colonies(i).centroids.coordinates_original, color.cells.colonies(i, :), 15);
   
    end
    
    % get colors for each type of boundary:
    color.well = [0 2^16 0];
    color.colonies = [1 0 0];

    % for each well boundary:
    for i = 1:numel(boundaries.well)
        
        % add boundary to image:
        image_annotated = colonycounting_v2.utilities.add_boundary_to_stitch(image_annotated, boundaries.well(i).coordinates_boundary_original, color.well, 20);
        
    end
     
    % for each colony boundary:
    for i = 1:numel(boundaries.colonies)
       
        % add boundary to image:
        image_annotated = colonycounting_v2.utilities.add_boundary_to_stitch(image_annotated, boundaries.colonies(i).coordinates_boundary_original, color.colonies, 20);
        
    end
    
end