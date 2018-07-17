function stitch_all_scans(varargin)

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
    
    %%% Next, we want to creat a structure to store all stitching
    %%% information. 
    
    % create structure:
    stitch_info = colonycounting_v2.stitch_all_scans.create_structure_to_store_stitch_info(paths);

    %%% Next, we need the user to input the scan tile dimensions for each
    %%% scan. Also, delete the stitched image made by Metamorph from the
    %%% list of images.
    
    % get number of scans:
    num_scans = numel(stitch_info);

    % for each scan:
    for i = 1:num_scans
           
        % ask user for the scan dimensions:
        prompts = {stitch_info(i).path_folder, 'Number of Rows', 'Number of Columns'};
        defaults = {stitch_info(i).name_scan, '', ''};
        answer = inputdlg(prompts, 'Enter Tile Dimensions', [1 200], defaults);
        num_tiles_row = str2double(answer{2});
        num_tiles_column = str2double(answer{3});
        
        % for each channel:
        for j = 1:numel(stitch_info(i).images)
           
            % remove the Metamorph stitched image from the list of images:
            list_images = stitch_info(i).images(j).list_images;
            [~, rows_to_remove] = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', num2str((num_tiles_row*num_tiles_column) + 1));
            list_images(rows_to_remove) = [];

            % save to stitch info structure:
            stitch_info(i).images(j).list_images = list_images;
            
        end
        
        % save to stitch info structure:
        stitch_info(i).num_tiles_row = num_tiles_row;
        stitch_info(i).num_tiles_column = num_tiles_column;
        
    end
    
    %%% Next, we need the user to align each scan using cpselect.
    
    % for each scan:
    for i = 1:num_scans
        
        % get the list of dapi images:
        [~, row] = colonycounting_v2.utilities.get_structure_results_matching_string(stitch_info(i).images, 'channel', 'dapi');
        list_images_dapi = stitch_info(i).images(row).list_images;
        
        % align each scan:
        [stitch_info(i).transform_coords_row, stitch_info(i).transform_coords_column] = ...
            colonycounting_v2.stitch_all_scans.align_a_scan(...
            list_images_dapi, ...
            stitch_info(i).num_tiles_row, ...
            stitch_info(i).num_tiles_column);
        
    end
    
    %%% Next, we need to create the stitched images. 
    
    % for each scan:
    for i = 1:num_scans
        
        % stitch the image:
        colonycounting_v2.stitch_all_scans.stitch_a_scan(stitch_info(i));
        
    end
    
end