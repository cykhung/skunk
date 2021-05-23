function w(filenames)


%% Assign input arguments.
if nargin == 0
    filenames = '.';
end
if ischar(filenames)
    filenames = {filenames};
end
if iscategorical(filenames)
    filenames = cellstr(filenames);
end


%% Open file.
for n = 1:numel(filenames)

    % Get filename.
    filename = filenames{n};
    
    % Open current folder.
    if strcmp(filename, '.')
        winopen('.');
        continue;
    end
        
    % Open web page.
    if length(filename) >= 7
        if strcmp(filename(1:8), 'https://') || strcmp(filename(1:7), 'http://')
            web(filename);
            continue;
        end
    end
    
    % Open file or folder.
    filename = convert_filenames(filename);
    [~, ~, ext] = fileparts(filename);
    switch lower(ext)
    case '.fig'
        openfig(filenames{n});
        plotedit on
    case '.pdf'
        sumatrapdf(filenames{n});
    case {'.jpg', '.jpeg', '.png', '.svg', '.tif', '.nef'}
        irfanview(filenames{n});
    otherwise
        winopen(filenames{n});
    end

end


end

