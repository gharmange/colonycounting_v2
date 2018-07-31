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
            boundaries = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, sprintf('Segmentation_%s.mat', stitch_info.name_scan)));
            
            % get the list of DAPI images (for counting cells):
            list_images = colonycounting_v2.utilities.get_structure_results_matching_string(stitch_info(i).images, 'channel', 'dapi');
            list_images = list_images.list_images;
            
            % count the cells:
            [cells.all.position, cells.all.stitch, cells.all.stitch_small] = colonycounting_v2.count_cells_all_scans.count_cells_in_scan(list_images, stitch_info(i).stitch_coords, stitch_info.scale_rows, stitch_info.scale_columns);

            % determine cells in the well/colonies:
            cells.well = colonycounting_v2.count_cells_all_scans.get_cells_within_boundaries(cells, boundaries.well);
            cells.colonies = colonycounting_v2.count_cells_all_scans.get_cells_within_boundaries(cells, boundaries.colonies);
            
            % create image with the cells and boundaries plotted:
            stitch_annotated = colonycounting_v2.count_cells_all_scans.add_all_boundaries_and_cells_to_stitch(stitch, cells);
            
            % create downsized version of annotated image:
            stitch_small_annotated = imresize(stitch_annotated, [size(stitch_annotated, 1)/stitch_info.scale_rows, size(stitch_annotated, 2)/stitch_info.scale_columns]);
            
            % save cells:
            save(fullfile(path_scan, sprintf('Segmentation_and_Cells_%s.mat', stitch_info.name_scan)), 'cells');
            
            % save annotated stitched image:
            save(fullfile(path_scan, sprintf('%s_segmentation_cells.mat', name_stitch)), 'stitch_annotated');
            imwrite(stitch_small_annotated, fullfile(path_scan, sprintf('%s_small_segmentation_cells.tif', name_stitch)));
            
        end
        
    end

end