function stitch_info = create_structure_to_store_stitch_info(paths)

    % create structure to store stitch info:
    stitch_info = struct;
    stitch_info.path_folder = [];
    stitch_info.name_scan = [];
    stitch_info.list_images = cell(0);

    % for each folder:
    for i = 1:numel(paths)

        % get path to folder:
        path_folder = paths{i};

        % get a list of all images in the folder:
        list_image_names = dir(fullfile(path_folder, 'Scan*.tif'));

        % get a list of all the scans in the folder:
        list_scan_names = extractfield(list_image_names, 'name');
        list_scan_names = unique(cellfun(@(x) x(1:7), list_scan_names, 'UniformOutput', false));

        % get number of scans:
        num_scans = numel(list_scan_names);

        % for each scan:
        for j = 1:num_scans

            % get name of scan:
            name_scan = list_scan_names{j};

            % get list of images for the scan:
            list_image_names_scan = colonycounting_v2.utilities.get_structure_results_containing_string(list_image_names, 'name', name_scan);

            % save to stitch info structure:
            temp.path_folder = path_folder;
            temp.name_scan = name_scan;
            temp.list_images = list_image_names_scan;
            stitch_info = colonycounting_v2.utilities.add_entry_to_structure(temp, stitch_info);

        end

    end

end