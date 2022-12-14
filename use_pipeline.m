data_file = '../cc_data/slice19 4.txt';
% load(filename)

% Data is tab-separated insight format
opts = detectImportOptions(data_file);
data = readtable(data_file, opts);

% Separate channels in this dataset
classes = table2array(data(:, 12));
data1 = data(classes == 1, :);
data2 = data(classes == 2, :);
clear 'classes';

%pixel_size = 0.160;  % um
units = 'nm';

% Scale data to real units
%coords1 = pixel_size * table2array(data1(:, {'PositionX_nm_', 'PositionY_nm_'}));
%coords2 = pixel_size * table2array(data2(:, {'PositionX_nm_', 'PositionY_nm_'}));

coords1 = table2array(data1(:, {'PositionX_nm_', 'PositionY_nm_'}));
coords2 = table2array(data2(:, {'PositionX_nm_', 'PositionY_nm_'}));

% Maximum distance in pair-correlation and cross-correlation calculations.
maxDistance = 500; % nm
% Area of the field of view. Needed for correct normalization of
% pair-correlation density but does not affect the profile of the plot.
fovArea = 500^2;  % um^2

% Run the pipeline to generate the pair- and cross-correlation plots. These
% plots will be used to determine cutoffs for molecule/cluster separation
% (cross-correlation) and for optional clustering (pair-correlation).
cc_graphic_pipeline(...
    coords1, coords2, maxDistance, fovArea, 'nm', '19','/Users/jacklovell/Desktop/cc_analysis/cc_data/results/');

% Distances used for optional clustering. Should be [0.0, 0.0] for no
% clustering.
countclusters_distances = [0, 0];  % um
% Minimum number of localizations needed to classify as a cluster. This is
% specified individually per channel. Should be [1, 1] if no clustering.
minimumNumbers = [1, 1];
% Distance used for molecule/cluster separation distance. This should be
% determined from the cross-correlation of the two datasets.
separation_distance = 27.75;  % um

% Run the pipeline to generate the separated coordinate lists and indices.
[coords_coloc, included, excluded, cluster_filters, coord_idx] = cc_separation_pipeline(...
    coords1, coords2, countclusters_distances, separation_distance, minimumNumbers);

% Example of how to use the indices to obtain the split the coordinate
% lists.
% Colocalized:
included_data = cell([1 2]);
included_data{1} = data1(coords_coloc{1}, :);
included_data{2} = data2(coords_coloc{2}, :);
% Not colocalized:
excluded_data = cell([1 2]);
excluded_data{1} = data1(~coords_coloc{1}, :);
excluded_data{2} = data2(~coords_coloc{2}, :);

% Export the split coordinate lists.
output_dir = '../cc_data/results/';
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end
output_pattern = '../cc_data/results/all_localizations';
writetable(vertcat(included_data{:}), [output_pattern '_included.txt'])
writetable(vertcat(excluded_data{:}), [output_pattern '_excluded.txt'])
