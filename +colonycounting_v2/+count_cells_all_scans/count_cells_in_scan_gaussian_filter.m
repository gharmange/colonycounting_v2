function [cells_position, cells_stitch, cells_stitch_small] = count_cells_in_scan_gaussian_filter(list_images, path_images, stitch_coords, scale_rows, scale_columns, stitch_full)

% Block process Gaussian filter
fun = @(block_struct) ...
    imgaussfilt(block_struct.data,10);

imOut = blockproc(image_to_save,[11000 11000],fun,'BorderSize',[200 200]);

% Block process imregionalmax
fun2 = @(block_struct)...
    imregionalmax(block_struct.data);

imRegMx = blockproc(imOut,[11000 11000],fun2,'BorderSize',[200 200]);

% Find connected components
CC = bwconncomp(imRegMx);
S = regionprops(CC);
cens = regionprops(CC,'Centroid');

A = [cens.Centroid];
B = reshape(A,2,[])'; % Centroids in a more reasonable form
C = round(B); % These are all the centroids

for i = 1:size(C,1)
    val(i) = imOut(C(i,2),C(i,1));
end

% This generates the histogram. It then finds the inflection point by
% finding the place where the derivative changes from negative to positive.
% That's where it sets the threshold
h = histogram(val);
theBars = h.Values;
dd = diff(theBars);
minPt = min(find(dd>0))+1;
thresh = 1/2*(h.BinEdges(minPt)+h.BinEdges(minPt+1));

idx = val > thresh;
C2 = C(idx,:);


% convert the cell centroids to the reference frame of the small
% stitch:
cells_stitch_small(:,2) = C2(:,2) / scale_rows;
cells_stitch_small(:,1) = C2(:,1) / scale_columns;

% make sure the coords are within the bounds of the image:
% cells_stitch_small(:,2) = min(max(cells_stitch_small(:,2), 1), size(stitch_small, 2));
% cells_stitch_small(:,1) = min(max(cells_stitch_small(:,1), 1), size(stitch_small, 1));

end