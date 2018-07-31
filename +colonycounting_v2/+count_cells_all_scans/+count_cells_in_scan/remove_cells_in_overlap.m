function cells_filtered = remove_cells_in_overlap(cells, overlap)

    % format the coordinates of the overlap:
    overlap_x = [overlap.corner_ul_column, ...
        overlap.corner_ur_column, ...
        overlap.corner_lr_column, ...
        overlap.corner_ll_column];
    overlap_y = [overlap.corner_ul_row, ...
        overlap.corner_ur_row, ...
        overlap.corner_lr_row, ...
        overlap.corner_ll_row];

    % get indices of cells within the overlap:
    indices = inpolygon(cells(:,1), cells(:,2), overlap_x, overlap_y);

    % remove cells that are within the overlap:
    cells_filtered = cells;
    cells_filtered(indices, :) = [];

end