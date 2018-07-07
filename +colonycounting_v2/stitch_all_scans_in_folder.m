function stitch_all_scans_in_folder
    
    % ask user if all scans have the same dimensions:
    all_same = questdlg('Do all scans in this folder have the same dimensions?', 'Scan Sizes', 'Yes', 'No', 'Yes');

    % depending on whether all scans are same size:
    switch all_same
        
        case 'Yes'
            
            % ask user for scan dimensions:
            answer = inputdlg({'Number of Columns', 'Number of Rows'}, 'Set Scan Size');
            num_rows = str2double(answer{1});
            num_columns = str2double(answer{2});
            
        case 'No'
            
            error('The code cannot CURRENTLY handle scans with different dimensions.');
            
    end
    
    % get list of images in a folder:
    list_images = dir('Scan*.tif');
    
    % remove Metamorph scan images:
    [~, rows_to_remove] = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', num2str((num_rows*num_columns) + 1));
    list_images(rows_to_remove) = [];
    
    % get list of scans:
    list_scans = extractfield(list_images, 'name');
    list_scans = unique(cellfun(@(x) x(1:7), list_scans, 'UniformOutput', false));
    
    % get number of scans:
    num_scans = numel(list_scans);
    
    % for each scan:
    for i = 1:num_scans
       
        % get list of images for a particular scan:
        list_images_one_scan = colonycounting_v2.utilities.get_structure_results_containing_string(list_images, 'name', list_scans{i});
        
        % stitch the image:
        colonycounting_v2.stitch_all_scans_in_folder.stitch_a_scan(list_scans{i}, list_images_one_scan, num_rows, num_columns);
        
    end

end