function boundaries = guess_colonies(cells, boundaries, stitch_small, boundary_well)

    % exclude cells outside the well:
    cells_inside = inpolygon(cells(:,1), cells(:,2), boundary_well.coordinates_boundary(:,1), boundary_well.coordinates_boundary(:,2));

    % get cell coordinates:
    cells_x = cells(cells_inside,1);
    cells_y = cells(cells_inside,2);
    
    % get cell coordinates rounded:
    cells_x_rounded = max(min(round(cells_x), size(stitch_small, 2)), 0);
    cells_y_rounded = max(min(round(cells_y), size(stitch_small, 1)), 0);

    % get number of cells:
    num_cells = numel(cells_x);
    
    % create binary image with cell positions:
    image = zeros(size(stitch_small));
    for i = 1:num_cells
        y = cells_y_rounded(i);
        x = cells_x_rounded(i);
        image(y, x) = image(y, x) + 1; 
    end

    % get density image:
    image_density = colonycounting_v2.segment_all_scans.guess_colonies.create_density_image(image, 5);

    % thresold density image:
    image_density_centroids = image_density;
    image_density_centroids(image_density_centroids < 20) = 0;
    
    % threshold the image using the density image (ignore cells in regions
    % of low density):
    image_threshold = image;
    image_threshold(~(image_density_centroids & image_threshold)) = 0;
    
%     % plot density image:
%     imshow([image, image_threshold]);
    
    % get the centroids of the colonies:
    [colony_centroids_x, colony_centroids_y] = colonycounting_v2.segment_all_scans.guess_colonies.get_colony_centroids(image_threshold);
    
    % get number of colonies:
    num_colonies = numel(colony_centroids_x);
    
%     % get color for each colony:
%     colors = distinguishable_colors(num_colonies, {'k', 'w'});
%     
%     % plot colony centroids:
%     figure;
%     
%     subplot(1,2,1)
%     imshow(imadjust(image));
%     hold on;
%     scatter(colony_centroids_x, colony_centroids_y, 80, colors, 'filled');
%     hold off;
%     
%     subplot(1,2,2);
%     imshow(imadjust(image_threshold));
%     hold on;
%     scatter(colony_centroids_x, colony_centroids_y, 80, colors, 'filled');
%     hold off;
    
    % assign cells to colonies:
    colony_assignment = colonycounting_v2.segment_all_scans.guess_colonies.assign_cells_to_centroids(cells_x_rounded, cells_y_rounded, image_threshold, colony_centroids_x, colony_centroids_y);
   
%     % add columns to store cell color:
%     colony_assignment_colors = colony_assignment;
%     colony_assignment_colors(1:end, 2:4) = deal(1);
%     for i = 1:size(colony_assignment_colors, 1)
%         if colony_assignment_colors(i,1) ~= 0
%             colony_assignment_colors(i, 2:4) = colors(colony_assignment_colors(i, 1), :); 
%         end
%     end
    
%     % plot cell assignment:
%     figure;
%     imshow(imadjust(image));
%     hold on;
%     scatter(cells_x_rounded, cells_y_rounded, 5, colony_assignment_colors(:, 2:4), 'filled');
%     hold off;
    
    % use the cell assignments to get colony boundaries:
    boundaries = colonycounting_v2.segment_all_scans.guess_colonies.get_colony_boundaries(boundaries, cells_x_rounded, cells_y_rounded, colony_assignment, stitch_small);

%     % plot boundaries:
%     figure;
%     imshow(imadjust(image));
%     hold on;
%     for i = 1:numel(boundaries)
%         plot(boundaries(i).coordinates_boundary(:,1), boundaries(i).coordinates_boundary(:,2), '-', 'Color', colors(i, :), 'LineWidth', 3);
%     end
%     hold off;
    
end