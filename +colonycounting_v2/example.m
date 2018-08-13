%% Analyze multiple folders:

% collect the folders with images you want to analyze:
paths = {...
    '~/Dropbox (RajLab)/LEB_General/example_data_Eduardo/170914_WM989_DP/', ...
    '~/Dropbox (RajLab)/LEB_General/example_data_Eduardo/170914_WM989_ungated/', ...
    };

% % downsize the scans (optional):
% colonycounting_v2.downsize_all_scans(paths);
% 
% % update the paths to point to the downsized images:
% paths = {...
%     '~/Dropbox (RajLab)/LEB_General/example_data_Eduardo/170914_WM989_DP/downsized_images', ...
%     '~/Dropbox (RajLab)/LEB_General/example_data_Eduardo/170914_WM989_ungated/downsized_images', ...
%     };

% stitch the scans:
colonycounting_v2.stitch_all_scans(paths);

% count the cells:
colonycounting_v2.count_cells_all_scans(paths);

% segment the colonies:
colonycounting_v2.segment_all_scans(paths);