function centroids_keep = count_cells_in_scan_waterShed(image, sensitivity, minNucleusSize, minimaThresh)

    % binarize image to find centroids:
    function_binarize = @(block_struct)...
        imbinarize(scale(block_struct.data), adaptthresh(scale(block_struct.data), sensitivity, 'ForegroundPolarity','bright')); 
    
    % find centroids (using block processing):
    image_binarize = blockproc(image, [11000 11000], function_binarize, 'BorderSize', [200 200]);
    
    %Calculate the Euclidean distance transform (distance to nearest
    %nonzero pixel)
    function_bwdist = @(block_struct)...
        bwdist(block_struct.data); 
    
    image_bwdist = blockproc(image_binarize, [11000 11000], function_bwdist, 'BorderSize', [200 200]);
    image_bwdist = -image_bwdist;
    
    %Remove shallow minima that may cause over-segmentation
    function_imhim = @(block_struct)...
        imhmin(block_struct.data, minimaThresh); 
    
    image_bwdist2 = blockproc(image_bwdist, [11000 11000], function_imhim, 'BorderSize', [200 200]);
    
    %Segment image using watershed function and re-binarize
    function_watershed = @(block_struct)...
        watershed(block_struct.data); 
    
    image_watershed = blockproc(image_bwdist2, [11000 11000], function_watershed, 'BorderSize', [200 200]);

    %Re-binarize segented grayscale image without scaling
    function_binarize2 = @(block_struct)...
        imbinarize(block_struct.data, adaptthresh(block_struct.data, sensitivity, 'ForegroundPolarity','bright')); 
    
    image_binarize2 = blockproc(image_watershed, [11000 11000], function_binarize2, 'BorderSize', [200 200]);
    
    % find connected components and remove centroid smaller than threshold:
    CC = bwconncomp(image_binarize2, 4);
        
    rp = regionprops(CC);
    area = [rp.Area];
    centroids = [rp.Centroid];
    centroids = reshape(centroids,2,[])'; 
    centroids = round(centroids); 

    idx = area > minNucleusSize; % Get rid of small stuff

    centroids_keep = centroids(idx, 1:end);
 
end