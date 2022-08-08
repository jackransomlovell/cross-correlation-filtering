% Define output patterns
output_dir = '/Users/haowang/Documents/MATLAB/cc_analysis/cc_data/results/';
if ~exist(output_dir, 'dir')
    mkdir(output_dir)
end

data_pdir = '/Users/haowang/Dropbox (MIT)/MIT/STORM data/';

files = dir(data_pdir);

for k = 1:numel(files)

    file = files(k).name;

    if contains(file,'.txt') == 1
        data_file = strcat(data_pdir,file);
        % load(filename)
        
        % Data is tab-separated insight format
        opts = detectImportOptions(data_file);
        data = readtable(data_file, opts);
        
        % Separate channels in this dataset
        classes = table2array(data(:, 12));
        data1 = data(classes == 1, :);
        data2 = data(classes == 2, :);
        clear 'classes';
     
        units = 'nm';
        
        coords1 = table2array(data1(:, {'PositionX_nm_', 'PositionY_nm_'}));
        coords2 = table2array(data2(:, {'PositionX_nm_', 'PositionY_nm_'}));
        
        % Maximum distance in pair-correlation and cross-correlation calculations.
        maxDistance = 500; % nm
        % Area of the field of view. Needed for correct normalization of
        % pair-correlation density but does not affect the profile of the plot.
        fovArea = 500^2;  % nm^2
        
        % Run the pipeline to generate the pair- and cross-correlation plots. These
        % plots will be used to determine cutoffs for molecule/cluster separation
        % (cross-correlation) and for optional clustering (pair-correlation).
        cc_graphic_pipeline(coords1, coords2, maxDistance, fovArea, 'nm', ...
            file, output_dir);
    end
end