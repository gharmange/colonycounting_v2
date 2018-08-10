function segment_all_scans(varargin)

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
    
    %%% Next, we need to segment the wells.
    
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
            
            % get the name of the small DAPI stitch:
            name_stitch = sprintf('Stitch_%s_%s_small', stitch_info.name_scan, 'dapi');
            
            % load the stitch:
            stitch = readmm(fullfile(path_scan, [name_stitch '.tif']));
            stitch = stitch.imagedata;
            
            % get name and path for file to store boundaries:
            file_name_boundaries = sprintf('Segmentation_%s.mat', stitch_info.name_scan);
            
            % check for existence of boundaries file:
            if exist(fullfile(path_scan, file_name_boundaries), 'file') == 2
                
                % load the boundaries:
                boundaries = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, file_name_boundaries));
                boundaries_small_well = boundaries.small.well;
                boundaries_small_colonies = boundaries.small.colonies;
                
            % if the boundaries file does not already exist:
            else
                
                % create structure to store boundaries:
                boundaries_small_well = struct;
                boundaries_small_well.coordinates_boundary_small = [];
                boundaries_small_well.coordinates_mask_small = [];
                boundaries_small_well.status = '';
                boundaries_small_colonies = struct;
                boundaries_small_colonies.coordinates_boundary_small = [];
                boundaries_small_colonies.coordinates_mask_small = [];
                boundaries_small_colonies.status = '';
                
            end
            
            % segment the well:
            instructions_well = 'Segment the well.';
            boundaries_small_well = colonycounting_v2.segment_all_scans.gui_to_segment_a_stitch(stitch, boundaries_small_well, instructions_well);
            
            % segment the colonies:
            instructions_colonies = 'Segment the colonies.';
            boundaries_small_colonies = colonycounting_v2.segment_all_scans.gui_to_segment_a_stitch(stitch, boundaries_small_colonies, instructions_colonies);

            % get boundary coords in reference frame of original stitch:
            boundaries.small.well = boundaries_small_well;
            boundaries.small.colonies = boundaries_small_colonies;
            boundaries = colonycounting_v2.segment_all_scans.scale_coords_boundary_up(boundaries, stitch_info.scale_rows, stitch_info.scale_columns);
            
            % make annotated stitch:
            stitch_annotated = colonycounting_v2.segment_all_scans.add_all_boundaries_to_stitch(stitch, boundaries);
            
            % save boundaries:
            save(fullfile(path_scan, file_name_boundaries), 'boundaries');

            % save the stitch info:
            save(fullfile(path_scan, list_stitch_info(j).name), 'stitch_info');
            
            % save the annotated image:
            imwrite(stitch_annotated, fullfile(path_scan, [name_stitch '_segmentation.tif']));
            
        end
        
    end

end