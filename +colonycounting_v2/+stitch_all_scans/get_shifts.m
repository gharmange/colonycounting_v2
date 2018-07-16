function stitch_info = get_shifts(stitch_info)

    % ask user if any scans have the same alignments:
    question = 'Do any scans have the same alignments?';
    title = 'Scan Alignment';
    answer = questdlg(question, title, 'Yes, all do.', 'Yes, all in a folder do.', 'No, none do.', 'Yes, all do.');

    % if all scans have the same alignments:
    if strcmp(answer, 'Yes, all do.')
       
        % get alignment:
        [shift_row, shift_column] = ...
            colonycounting_v2.stitch_all_scans.get_shifts.get_shift(...
            stitch_info(1).scans(1).images, ...
            stitch_info(1).scans(1).num_tiles_row, ...
            stitch_info(1).scans(1).num_tiles_column, ...
            'ALL FOLDERS', ...
            'ALL SCANS');
        
    end
    
    % for each folder:
    for i = 1:numel(stitch_info)
        
        % if all scans in the folder have the same alignment:
        if strcmp(answer, 'Yes, all in a folder do.')

            % get alignment:
            [shift_row, shift_column] = ...
                colonycounting_v2.stitch_all_scans.get_shifts.get_shift(...
                stitch_info(i).scans(1).images, ...
                stitch_info(i).scans(1).num_tiles_row, ...
                stitch_info(i).scans(1).num_tiles_column, ...
                stitch_info(i).path_folder, ...
                'ALL SCANS');

        end
       
        % for each scan:
        for j = 1:numel(stitch_info(i).scans)
            
            % if no scans have the same sizes:
            if strcmp(answer, 'No, none do.')
            
                % get alignment:
                [shift_column, shift_row] = ...
                    colonycounting_v2.stitch_all_scans.get_shifts.get_shift(...
                    stitch_info(i).scans(j).images, ...
                    stitch_info(i).scans(j).num_tiles_row, ...
                    stitch_info(i).scans(j).num_tiles_column, ...
                    stitch_info(i).path_folder, ...
                    stitch_info(i).scans(j).name_scan);
            
            end
    
            % save:
           stitch_info(i).scans(j).shift_column = shift_column;
           stitch_info(i).scans(j).shift_row = shift_row;
            
        end
        
    end

end