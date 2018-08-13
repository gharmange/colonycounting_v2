function centroids_formatted = count_cells_in_image(image)

    % get the ATrous Wavelet Transform of the image:
    [transform, ~] = aTrousWaveletTransform(image, 'numLevels', 3, 'sigma', 3);
    
    % use the last level of the transform and scale it to 0 and max intensity:
    transform = scale(transform(:,:,3));
    
    % binarize the transform to 0s and 1s:
    transform_binary = imbinarize(transform,graythresh(transform));

    % get the connected components (objects):
    objects = bwconncomp(transform_binary);
    
    % get the centroids of the objects::
    centroids = regionprops(objects,'Centroid');
    
    % get number of centroids:
    num_centroids = numel(centroids);
    
    % create empty array to store formatted centroids:
    centroids_formatted = zeros(num_centroids, 2);
    
    % for every centroid:
    for i = 1:num_centroids
        
        % get coordinates and round to whole number:
        col = round(centroids(i).Centroid(1)); 
        row = round(centroids(i).Centroid(2));
        
        % make sure coordinates fit within image size:
        col = min(max(col, 1), size(image, 2));
        row = min(max(row, 1), size(image, 1));
        
        % add to centroids array:
        centroids_formatted(i,:) = [col, row];
        
    end

end