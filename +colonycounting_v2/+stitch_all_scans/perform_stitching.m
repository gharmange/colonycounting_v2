function perform_stitching(stitch_info)

    % for each folder:
    for i = 1:numel(stitch_info)
       
        % for each scan:
        for j = 1:numel(stitch_info(i).scans)
                
            % stitch all wavelengths:
            colonycounting_v2.stitch_all_scans.perform_stitching.stitch_all_wavelengths(stitch_info(i).scans(j));
            
        end
        
    end
    
end