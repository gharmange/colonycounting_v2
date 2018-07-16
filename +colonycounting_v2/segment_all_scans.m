function segment_all_scans(varargin)

    %%% First, we need to get all the path(s) to the raw images. 

    % if no paths are input:
    if nargin == 0
        
        % set the current working directory as the path to the data:
        paths = pwd;
        
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

            % get the wavelength for DAPI:
            wavelength = colonycounting_v2.utilities.get_structure_results_matching_string(stitch_info.images, 'channel', 'dapi');
            wavelength = wavelength.wavelength;
            
            % get the name of the DAPI stitch:
            name_stitch = sprintf('Stitch_%s_%s_small', stitch_info.name_scan, wavelength);
            
            % load the stitch:
            stitch = colonycounting_v2.utilities.load_structure_from_file(fullfile(path_scan, [name_stitch '.mat']));
            
%             % create rgb-version of stitch to add outlines to:
%             stitch_annotated = repmat(stitch, 1, 1, 3);
            
            % create structure to store boundaries:
            boundaries_well = struct;
            boundaries_well.number = [];
            boundaries_well.coordinates_boundary = [];
            boundaries_well.coordinates_mask = [];
            boundaries_colonies = struct;
            boundaries_colonies.number = [];
            boundaries_colonies.coordinates_boundary = [];
            boundaries_colonies.coordinates_mask = [];

            % segment the well:
            instructions_well = 'Segment the well.';
            boundaries_well = colonycounting_v2.segment_all_scans.gui_to_segment_a_stitch(stitch, boundaries_well, instructions_well);
            
            % segment the colonies:
            instructions_colonies = 'Segment the colonies.';
            boundaries_colonies = colonycounting_v2.segment_all_scans.gui_to_segment_a_stitch(stitch, boundaries_colonies, instructions_colonies);

            % save boundaries:

            % save the stitch info:
            save(fullfile(path_scan, list_stitch_info(j).name), 'stitch_info');
            
            % save the annotated image:
            imwrite(stitch_annotated, fullfile(path_scan, [name_stitch '_annotated.tif']));
            
        end
        
    end

end