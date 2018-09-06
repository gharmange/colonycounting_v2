function [cells_position, cells_stitch, cells_stitch_small] = count_cells_in_scan(list_images, path_images, stitch_coords, scale_rows, scale_columns, stitch_small)

    % get number of images:
    num_images = numel(list_images);

    % create structure to store centroids:
    [cells_position(1:num_images).image_name] = deal('');
    [cells_position(1:num_images).coords] = deal([]);

    % create array to store centroids for the entire stitch:
    cells_stitch = [];
    
    % for each image:
    for i = 1:num_images
       
        % get the image name:
        image_name = list_images(i).name;
        
        % load the image:
        image = readmm(fullfile(path_images, image_name));
        image = image.imagedata;
        
        % count the cells in the image:
        coords = colonycounting_v2.count_cells_all_scans.count_cells_in_scan.count_cells_in_image(image);
        
        % get position number of the image:
        position_number = str2double(image_name(strfind(image_name, 's')+1:strfind(image_name, 't')-2));

        % get the stitch coords for the image:
        stitch_coords_image = colonycounting_v2.utilities.get_structure_results_matching_number(stitch_coords, 'position_num_linear', position_number);

        % if the image has an image that overlaps to the left:
        if ~strcmp(stitch_coords_image.overlap_left.stitch, 'none')

            coords = colonycounting_v2.count_cells_all_scans.count_cells_in_scan.remove_cells_in_overlap(coords, stitch_coords_image.overlap_left.position);

        end
        
        % if the image has an image that overlaps above:
        if ~strcmp(stitch_coords_image.overlap_above.stitch, 'none')

            coords = colonycounting_v2.count_cells_all_scans.count_cells_in_scan.remove_cells_in_overlap(coords, stitch_coords_image.overlap_above.position);

        end
        
        % convert coords to reference frame of the stitch:
        coords_stitch_position = zeros(size(coords));
        coords_stitch_position(:,2) = coords(:,2) + stitch_coords_image.corner_ul_row;
        coords_stitch_position(:,1) = coords(:,1) + stitch_coords_image.corner_ul_column;
        
        % save:
        cells_position(i).image_name = image_name;
        cells_position(i).coords = coords;
        cells_stitch = [cells_stitch; coords_stitch_position];
        
    end

    % convert the cell centroids to the reference frame of the small
    % stitch:
%     cells_stitch_small(:,2) = round(cells_stitch(:,2) / scale_rows);
%     cells_stitch_small(:,1) = round(cells_stitch(:,1) / scale_columns);
    cells_stitch_small(:,2) = cells_stitch(:,2) / scale_rows;
    cells_stitch_small(:,1) = cells_stitch(:,1) / scale_columns;

    % make sure the coords are within the bounds of the image:
    cells_stitch_small(:,2) = min(max(cells_stitch_small(:,2), 1), size(stitch_small, 2));
    cells_stitch_small(:,1) = min(max(cells_stitch_small(:,1), 1), size(stitch_small, 1));

end