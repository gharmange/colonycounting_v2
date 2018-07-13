function stitch_info = create_structure_to_store_stitch_info(paths)

    % create structure to store stitch info:
    stitch_info.path_folder = [];
    stitch_info.name_scan = [];
    stitch_info.images = struct;

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

            % get list of wavelengths for the scan:
            list_wavelengths = extractfield(list_image_names_scan, 'name');
            list_wavelengths = unique(cellfun(@(x) x(9:10), list_wavelengths, 'UniformOutput', false));
            
            % get number of wavelengths:
            num_wavelengths = numel(list_wavelengths);
            
            % ask user to assign a channel to each wavelength:
            prompt = [{path_folder}, list_wavelengths];
            default = cell(num_wavelengths + 1, 1);
            default{1} = name_scan;
            default{2:end} = '';
            answer = inputdlg(prompt, 'Enter Channel for Each Wavelength', [1 200], default);

            % create structure to store images:
            [images(1:num_wavelengths).wavelength] = deal('');
            [images(1:num_wavelengths).channel] = deal('');  
            [images(1:num_wavelengths).list_images] = deal('');
            
            % for each wavelength:
            for k = 1:num_wavelengths
                
                % get list of images for the wavelength:
                list_image_names_scan_wavelength = ...
                    colonycounting_v2.utilities.get_structure_results_containing_string(...
                    list_image_names_scan, 'name', list_wavelengths{k});
               
                % save:
                images(k).wavelength = list_wavelengths{k};
                images(k).channel = answer{k+1};
                images(k).list_images = list_image_names_scan_wavelength;
                
            end
      
            % save to stitch info structure:
            temp_stitch_info.path_folder = path_folder;
            temp_stitch_info.name_scan = name_scan;
            temp_stitch_info.images = images;
            stitch_info = colonycounting_v2.utilities.add_entry_to_structure(temp_stitch_info, stitch_info);

        end

    end

end