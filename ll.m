function T = ll(x)


%% Use MATALB DIR to find files.
s         = dir(x);
T         = table;
T.name    = {s.name}';
T.folder  = {s.folder}';
T.date    = {s.date}';
T.bytes   = [s.bytes]';
T.isdir   = [s.isdir]';
T.datenum = [s.datenum]';


%% If no file is found, then we are done.
if isempty(T)
    return;     % Early exit.
end


%% Remove folders in the listing.
T = T(T.isdir == false, :);


%% Set T.filename.
x          = [T.folder, repmat({filesep}, size(T,1), 1), T.name];
x          = join(x, '');
T.filename = categorical(x);


%% Set T.date.
T.date = datetime(T.datenum,                   ...
                  'ConvertFrom', 'datenum',    ...
                  'Format', 'dd-MMM-uuuu eee hh:mm:ss a');


%% Only keep these columns.
T = T(:, {'filename', 'date', 'bytes'});
    
    
%% Set T.ext.
if size(T,1) >= 10000
    T.ext = repmat(categorical({''}), size(T,1), 1);
else
    E = cell(size(T.filename));
    for n = 1:length(E)
        [~, ~, ext] = fileparts(char(T.filename(n)));
        if ~isempty(ext)
            if strcmp(ext(1), '.')
                ext(1) = '';
            end
        end
        E{n} = ext;
    end
    T.ext = categorical(E);
end


%% Set T.attribute
if size(T,1) >= 10000
    T.attribute = repmat(categorical({''}), size(T,1), 1);
else
    A = repmat({''}, size(T.filename));
    for n = 1:length(A)
        [~, s] = fileattrib(char(T.filename(n)));
        if s.archive == 1
            if (s.UserWrite == 1) && (s.hidden == 0)
                A{n} = 'A';
            elseif (s.UserWrite == 0) && (s.hidden == 0)
                A{n} = 'RA';
            elseif (s.UserWrite == 1) && (s.hidden == 1)
                A{n} = 'HA';
            elseif (s.UserWrite == 0) && (s.hidden == 1)
                A{n} = 'RHA';
            else
                A{n} = '';
            end
        else
            if (s.UserWrite == 0) && (s.hidden == 0)
                A{n} = 'R';
            elseif (s.UserWrite == 1) && (s.hidden == 1)
                A{n} = 'H';
            elseif (s.UserWrite == 0) && (s.hidden == 1)
                A{n} = 'RH';
            end
        end
    end
    T.attribute = categorical(A, {'A', 'RA', 'HA', 'RHA', 'R', 'H', 'RH'}, ...
        'Protected', 1);
end


end

