%% Analyze multiple folders:

% collect the folders with images you want to analyze:
% paths = {...
%     '/Volumes/LAUREN_TEMP/example_data_Ben/E9_mNG2bulk_replicateA/', ...
%     '/Volumes/LAUREN_TEMP/example_data_Ben/E9_mNG2bulk_replicateB/', ...
%     };

paths = {...
    '/Volumes/LAUREN_TEMP/example_data_Eduardo/170914_WM989_DP/', ...
    '/Volumes/LAUREN_TEMP/example_data_Eduardo/170914_WM989_ungated/', ...
    };

% stitch the scans:
colonycounting_v2.stitch_all_scans(paths);

% % segment the colonies:
% colonycounting_v2.segment_all_scans(paths);

% % count the cells:
% colonycounting_v2.count_cells_all_scans(paths);