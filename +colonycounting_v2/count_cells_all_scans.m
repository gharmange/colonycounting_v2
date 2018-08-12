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
            
            % get the name of the scan:
            name_scan = stitch_info.name_scan;
            
            % get the name of the dapi stitch:
            name_stitch = sprintf('Stitch_Original_%s_%s', name_scan, 'dapi');
            
            % get the list of DAPI images (for counting cells):
            list_images = colonycounting_v2.utilities.get_structure_results_matching_string(stitch_info(i).images, 'channel', 'dapi');
            list_images = list_images.list_images;
            
            % display status:
            colonycounting_v2.utilities.display_status('Counting cells in', name_stitch, path_scan);
            
            % count the cells:
            [cells.all.position, cells.all.stitch, cells.all.stitch_small] = colonycounting_v2.count_cells_all_scans.count_cells_in_scan(list_images, stitch_info(i).stitch_coords, stitch_info.scale_rows, stitch_info.scale_columns);
            
            % load the stitch:
            stitch = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, [name_stitch '.mat']));
            
            % overlay on stitch:
            stitch_annotated = colonycounting_v2.count_cells_all_scans.overlay_on_image(stitch, cells);
            
            % create downsized version of annotated stitch:
            stitch_small_annotated = imresize(stitch_annotated, [size(stitch_annotated, 1)/stitch_info.scale_rows, size(stitch_annotated, 2)/stitch_info.scale_columns]);
            
            % save cells:
            save(fullfile(path_scan, sprintf('Cell_Info_%s.mat', stitch_info.name_scan)), 'cells');
            
            % save annotated stitched image:
            save(fullfile(path_scan, sprintf('Cell_Original_%s.mat', name_scan)), 'stitch_annotated');
            imwrite(stitch_small_annotated, fullfile(path_scan, sprintf('Cell_Small_%s.tif', name_scan)));
            
        end
        
    end

end