function centroids_keep = count_cells_in_scan_gaussian_filter(image)

    %%% First, we want to smooth the image and find regional max. These
    %%% will be the centroids of the cells. 

    % set the gaussian filter to use:
    function_gaussian = @(block_struct) ...
        imgaussfilt(block_struct.data, 7);
    
    % smooth image with a gaussian (using block processing):
    image_blurred = blockproc(image, [11000 11000], function_gaussian, 'BorderSize', [200 200]);

    % set the regional max to use:
    function_max = @(block_struct)...
        imregionalmax(block_struct.data);
    
    % sget regional max of the smoothed image (using block processing):
    image_max = blockproc(image_blurred, [11000 11000], function_max, 'BorderSize', [200 200]);

    % find connected components:
    CC = bwconncomp(image_max);
    
    % get centroids:
    centroids = regionprops(CC,'Centroid');
    centroids = [centroids.Centroid];
    centroids = reshape(centroids,2,[])'; 
    centroids = round(centroids); 
    
    %%% Next, we want to eliminate centroids where the image intensity is
    %%% below a threshold. This will get rid of any false positives. 

    % get the image intensity at every centroid:
    centroids_intensity = zeros(1, size(centroids, 1));
    for i = 1:size(centroids, 1)
        centroids_intensity(i) = image_blurred(centroids(i,2),centroids(i,1));
    end
    
    % create a histogram of the centroid intensities:
    figure('visible', 'off');
    histogram_handle = histogram(centroids_intensity);
    histogram_x = histogram_handle.BinEdges;
    histogram_y = histogram_handle.Values;

    % get the inflection point of the histogram:
    histogram_y_derivative = diff(histogram_y);
    inflection_y = find(histogram_y_derivative>0, 1) + 1;
    inflection_x = 1/2 * (histogram_x(inflection_y) + histogram_x(inflection_y + 1));

    % keep the centroids past the inflection point of the histogram:
    centroids_keep = centroids(centroids_intensity > inflection_x,:);

end