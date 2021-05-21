function w(filenames)

if nargin == 0
    filenames = '.';
end
if ischar(filenames)
    filenames = {filenames};
end
if iscategorical(filenames)
    filenames = cellstr(filenames);
end


for n = 1:numel(filenames)
    filename = filenames{n};
    if strcmp(filename, '.')
        winopen('.');
    elseif strcmp(filename(1:8), 'https://') || strcmp(filename(1:7), 'http://')
        web(filename);
    else    
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


end

