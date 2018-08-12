function image_annotated = overlay_on_image(image, cells)

    % create rgb-version of image:
    image_annotated = repmat(image, 1, 1, 3);

    % set color:
    color.cells.all = [1 0 0];
    
    % add cells to image:
    image_annotated = colonycounting_v2.utilities.add_cells_to_image(image_annotated, cells.all.stitch, color.cells.all, 15);
    
end