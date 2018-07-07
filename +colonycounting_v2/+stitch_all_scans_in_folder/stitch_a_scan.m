function stitch_a_scan(scan_name, image_set, num_rows, num_columns)

    % get total number of positions:
    numPositions = num_rows * num_columns;
    
    % arrange position numbers into matrix (same order that scope acquires images):
    arrayOfPositions = 1:numPositions;
    matrixOfPositions = reshape(arrayOfPositions, num_rows, num_columns);
    
    % get image size:
    temp = readmm(image_set(1).name);
    imagesize = temp.width;
    
    % creating stack to hold all positions:
    ims = zeros(imagesize, imagesize, numPositions, 'uint16');
    
    % for each position:
    for i = 1:numPositions
        
        % get the position image name:
        name = [scan_name '_w1_s' num2str(i) '_t1.TIF'];
        
        % load the image:
        ims(:,:,i) = imread(name);
        
    end
    
    % Now, we need to determine by how much to shift each image. 
    
    % if the transform coords file already exists:
    if exist('transform_coords.mat','file')
        
        % load it:
        load transform_coords.mat
        
    % otherwise:
    else
        
        % use the middle image to register:
        registerPosition.row = round(num_rows/2);
        registerPosition.col = round(num_columns/2);

        % get coordinates to transform the column:
        column_transform_coords = ...
            colonycounting_v2.stitch_all_scans_in_folder.get_transformation_coords_in_one_dimension(ims, ...
            registerPosition.row, registerPosition.row+1, ...
            registerPosition.col, registerPosition.col, ...
            matrixOfPositions);
    
        % get coordinates to transform the row:
        row_transform_coords = ...
            colonycounting_v2.stitch_all_scans_in_folder.get_transformation_coords_in_one_dimension(ims, ...
            registerPosition.row, registerPosition.row, ...
            registerPosition.col, registerPosition.col+1, ...
            matrixOfPositions);
        
        % save the transformation coordinates:
        save transform_coords.mat column_transform_coords row_transform_coords num_rows num_columns
        
    end
    
    % Now we have the transforms.  Let's now set up the coordinates for the
    % megapicture.
    
    % for each position:
    for i = 1:numPositions
        
        % get the row and column number of the position:
        [row,col] = find(matrixOfPositions == i);
        
        
        topCoords(i)  = row*columnTransformCoords(2) + col*rowTransformCoords(2);
        leftCoords(i) = col*rowTransformCoords(1) + row*columnTransformCoords(1);
        
    end
    
    topCoords = topCoords - min(topCoords) + 1;
    leftCoords = leftCoords - min(leftCoords) + 1;
    
    % creating an empty array to store stitched image:
    compositeIm = zeros(max(topCoords)+imagesize-1,max(leftCoords)+imagesize-1,'uint16');
    
    for i = numPositions:-1:1
        
        doubleIm = im2double(ims(:,:,i));
        %imageToAdd = (doubleIm - imfilter(doubleIm,h,'replicate'));
        imageToAdd = doubleIm ;
        
        compositeIm(topCoords(i):topCoords(i)+imagesize-1, ...
            leftCoords(i):leftCoords(i)+imagesize-1) = ...
            im2uint16(imageToAdd);
        
    end
    
    compositeIm = im2uint16(scale(compositeIm));
    
    % set file name:
    file_name = ['Stitch_' scan_name];
    
    % set image to save:
    image_to_save = imadjust(im2uint8(compositeIm));
    
    % save image as jpg:
    imwrite(image_to_save, [file_name '.jpg']);
    
    % save image as tif:
    imwrite(image_to_save, [file_name '.tif']);
    
    % save image as mat:
    save([file_name '.mat'], 'image_to_save', '-v7.3');

end