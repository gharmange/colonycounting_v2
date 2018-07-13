%% Analyze multiple folders:

% collect the folders with images you want to analyze:
paths = {...
    '~/Desktop/example_data_Eduardo/170914_WM989_DP/'};

% stitch the scans:
colonycounting_v2.stitch_all_scans(paths);

% segment the colonies:
colonycounting_v2.segment_all_scans(paths);

% count the cells:
colonycounting_v2.count_all_cells(paths);

%% Analyze a single folder:

% collect the folders with images you want to analyze:
cd /Volumes/LAUREN_TEMP/example_data/E9_mNG2bulk_replicateA/

% stitch the scans:
colonycounting_v2.stitch_all_scans;

% segment the colonies:
colonycounting_v2.segment_all_colonies;

% count the cells:
colonycounting_v2.count_all_cells;