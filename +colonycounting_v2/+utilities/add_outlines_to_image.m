function image = add_outlines_to_image(image, boundaries)

    % for each boundary:
    for i = 1:numel(boundaries)
        
        % format coords:
        coords_formatted = format_coords_for_plotting(boundaries(i).coords);
        
        % set color:
        switch boundaries(i).type
            case 'well'
                color = [0 0 1];
            case 'colony'
                color = [1 0 0];
        end
        
        % scale color to the image class:
        if isa(image, 'uint8')
            color = color * (2^8);
        elseif isa(image, 'uint16')
            color = color * (2^16);
        elseif isa(image, 'uint32')
            color = color * (2^32);
        elseif isa(image, 'uint64')
            color = color * (2^64);
        end

        % add polygon to image:
        image = insertShape(image, 'Polygon', coords_formatted, 'Color', color, 'LineWidth', 4);
        
    end
    
end

function coords_formatted = format_coords_for_plotting(coords)

    % get number of coordinates:
    num_coords = size(coords, 1);
    
    % create array to store formatted coordinates:
    coords_formatted = zeros(1, 2 * num_coords);
    
    % format coordinates (for insertShape):
    for i = 1:num_coords
        
        % format x coord:
        coords_formatted(1, 2 * i - 1) = coords(i,1);
        
        % format y coord:
        coords_formatted(1, 2 * i) = coords(i,2);
        
    end
    
end