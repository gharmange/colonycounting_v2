function stitch_a_scan(scan_name, image_set, num_rows, num_columns)


    
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