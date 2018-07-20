function count_cells_all_scans(varargin)

    %%% First, we need to get all the path(s) to the raw images. 

    % if no paths are input:
    if nargin == 0
        
        % set the current working directory as the path to the data:
        paths = {pwd};
        
    % otherwise:
    else
        
        % use the supplied cell as the path(s) to the data:
        paths = varargin{1};
        
    end
    
    %%% Next, we need to count the number of cells.
    
    % for each path:
    for i = 1:numel(paths)
       
        % get path to scan:
        path_scan = paths{i};
        
        % get list of stitch infos (scans) in the folder:
        list_stitch_info = dir(fullfile(path_scan, 'Stitch_Info_*.mat'));
        
        % for each stitch info (scan) in the folder:
        for j = 1:numel(list_stitch_info)
           
            % load the stitch info:
            stitch_info = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, list_stitch_info(j).name));
            
            % get the name of the dapi stitch:
            name_stitch = sprintf('Stitch_%s_%s', stitch_info.name_scan, 'dapi');
            
            % display status:
            colonycounting_v2.utilities.display_status('Counting cells in', name_stitch, path_scan);
            
            % load the stitch:
            stitch = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, [name_stitch '.mat']));
            
            % load the boundaries:
            boundaries = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, sprintf('boundaries_%s.mat', stitch_info.name_scan)));
            
            % get boundary coords in reference frame of original stitch:
            boundaries = colonycounting_v2.count_cells_all_scans.scale_coords_boundary_up(boundaries, stitch_info.scale_rows, stitch_info.scale_columns);
            
            % count the cells:
            centroids.all.coordinates_original = colonycounting_v2.count_cells_all_scans.count_cells_in_scan(stitch);
            
            % get centroid coords in reference frame of small stitch:
            centroids.all.coordinates_small = colonycounting_v2.utilities.scale_coords(centroids.all.coordinates_original, (1/stitch_info.scale_rows), (1/stitch_info.scale_columns));    

            % determine centroids in the well/colonies:
            boundaries.well = colonycounting_v2.count_cells_all_scans.get_cells_within_boundaries(centroids, boundaries.well);
            boundaries.colonies = colonycounting_v2.count_cells_all_scans.get_cells_within_boundaries(centroids, boundaries.colonies);
            
            % create image with the cells and boundaries plotted:
            stitch_annotated = colonycounting_v2.count_cells_all_scans.add_all_boundaries_and_cells_to_stitch(stitch, centroids, boundaries);
            
            % create downsized version of annotated image:
            stitch_annotated_small = imresize(stitch_annotated, [size(stitch_annotated, 1)/stitch_info.scale_rows, size(stitch_annotated, 2)/stitch_info.scale_columns]);
            
            % save centroids and boundaries:
            save(fullfile(path_scan, sprintf('cell_centroids_%s.mat', stitch_info.name_scan)), 'centroids');
            save(fullfile(path_scan, sprintf('boundaries_cell_centroids_%s.mat', stitch_info.name_scan)), 'boundaries');
            
            % save annotated stitched image:
            save(fullfile(path_scan, sprintf('%s_segmentation_cells.mat', name_stitch)), 'stitch_annotated');
            
            % save small annotated stitched image:
            imwrite(stitch_annotated_small, fullfile(path_scan, sprintf('%s_small_segmentation_cells.tif', name_stitch)));
            
        end
        
    end

end