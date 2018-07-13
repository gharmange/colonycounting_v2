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
            
            % create structure to store well boundaries:
            boundaries_well = struct;
            boundaries_well.number = [];
            boundaries_well.coordinates = [];

            % segment the well:
            instructions_well = 'Segment the well.';
            enable_multiple_well = 'off';
            boundaries_well = colonycounting_v2.segment_all_scans.gui_to_segment_a_stitch(stitch, boundaries_well, instructions_well, enable_multiple_well);
            
            
            
            % display the stitch:
            imshow(stitch);
            
            % ask user if they want to segment the well:
            option_segment_well = questdlg('Do you want to segment the well?', 'Well Segmentation', 'Yes', 'No', 'Yes');
            
            % if the user wants to segment the well:
            if strcmp(option_segment_well, 'Yes')
               
                % let the user segment the well:
                handle_well = imfreehand('Closed', true);
                
                % save well boundaries:
                stitch_info.boundaries = struct;
                stitch_info.boundaries.type = 'well';
                stitch_info.boundaries.coords = getPosition(handle_well);
                
                % plot boundaries on annotated stitch:
                stitch_annotated = colonycounting_v2.utilities.add_outlines_to_image(stitch_annotated, stitch_info.boundaries);
                
            end
            
            % set status to continue segmenting colonies:
            status = 'Yes';
            
            % while the user wants to add colonies:
            while strcmp(status, 'Yes')
                
                % display the annotated stitch:
                handle_display = imshow(stitch_annotated);
               
                % let the user segment the well:
                handle_colony = imfreehand('Closed', true);
                
                % save colony boundaries:
                stitch_info.boundaries(end+1).type = 'colony';
                stitch_info.boundaries(end).coords = getPosition(handle_colony);
                
                % plot boundaries on annotated stitch:
                stitch_annotated = colonycounting_v2.utilities.add_outlines_to_image(stitch_annotated, stitch_info.boundaries);
                
                % ask user if they want to add more colonies:
                status = questdlg('Do you want to add another colony?', 'Colony Segmentation', 'Yes', 'No', 'Yes');
                
            end
            
            % save the stitch info:
            save(fullfile(path_scan, list_stitch_info(j).name), 'stitch_info');
            
            % save the annotated image:
            imwrite(stitch_annotated, fullfile(path_scan, [name_stitch '_annotated.tif']));
            
        end
        
    end

end