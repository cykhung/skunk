function T = searchfile(rootdir, includedir, excludedir, includefile, excludefile)

%%
%       SYNTAX: T = searchfile(rootdir, includedir, excludedir, includefile, excludefile);
%
%  DESCRIPTION: Search files recursively under root directory.
%
%        INPUT: - rootdir (char)
%                   Root directory. Can be relative path or absolute path. Use
%                   '.' for current directory.
%
%               - includefile (char or 1-D row/col cell array of char)
%                   Include file pattern(s). Use wildcard (recognized by DIR).
%                   Do not use regular expression. Use '*' to include all files.
%                   Note that '*' and '*.*' give different behaviours. '*'
%                   returns all files and '*.*' return only files with
%                   extension. File separator (i.e. '\' in Windows or '/' in
%                   Unix) is not allowed. Case-insensitive.
%
%               - excludefile (char or 1-D row/col cell array of char)
%                   Exclude file pattern(s). User can use wildcards. Do not
%                   use regular expression. Use '' or {} to skip this check.
%                   File separator (i.e. '\' in Windows or '/' in Unix) is not
%                   allowed. Case-insensitive.
%
%               - includedir (char or 1-D row/col cell array of char)
%                   Include directory pattern(s). Refer to input argument
%                   'include' in searchdir.m for details.
%
%               - excludedir (char or 1-D row/col cell array of char)
%                   Exclude directory pattern(s). Refer to input argument
%                   'exclude' in searchdir.m for details.
%
%       OUTPUT: - T (table)
%                   Table. Table is sorted according to T.filename in ascending
%                   order. Table variable names are:
%
%                   - T.filename (1-D col categorical)
%                       Each table entry in this column is a filename.
%
%                   - T.date (1-D col array of categorical)
%                       Each table entry in this column is a file date.
%
%                   - T.sizeBytes (1-D col array of real double)
%                       Each table entry in this column is a file size in bytes.
%
%                   - T.ext (1-D col array of categorical)
%                       Each table entry in this column is a file extension.
%
%                   - T.attribute (1-D col cell array of strings)
%                       Each table entry in this column is a file attribute.


%% Check rootdir.
if ~ischar(rootdir)
    error('rootdir is not a string.');
end


%% Force includefile and excludefile to be a 1-D cell array of string.
if isempty(includefile)
    includefile = {};
else
    if ~iscell(includefile)
        includefile = {includefile};
    end
end
if isempty(excludefile)
    excludefile = {};
else
    if ~iscell(excludefile)
        excludefile = {excludefile};
    end
end


%% Make sure that 'includefile' and 'excludefile' do not contain file separator.
c = strfind(includefile, filesep);
c = [c{:}];
if ~isempty(c)
    error('One of the include file patterns contains file separator.');
end
c = strfind(excludefile, filesep);
c = [c{:}];
if ~isempty(c)
    error('One of the exclude file patterns contains file separator.');
end


%% Get all suddirectories under rootdir. Contain absolute paths.
alldirs = searchdir(rootdir, includedir, excludedir);


%% Get all files in each suddirectory in "alldirs".
s = [];
for m = 1:length(alldirs)
    tmp = dir(alldirs{m});
    if ~isfield(tmp, 'folder')
        % Starting in R2016a, DIR no longer returns the field "folder".
        [tmp.folder] = deal(alldirs{m});
    end
    s   = [s; tmp];             %#ok<AGROW>
end
if isempty(s)
    T = table;
else
    T       = struct2table(s);
    T       = T(~T.isdir, :);     % Files only.
    T.date  = [];
    T.isdir = [];
end


%% Keep files based on "includefile".
if ~isempty(T)
    mask = false(size(T.name));
    for n = 1:length(includefile)
        c = regexpi(T.name, regexptranslate('wildcard', includefile{n}), 'match');
        c = [c{:}]';
        mask = mask | ismember(T.name, c);
    end
    T = T(mask,:);
end


%% Remove files based on "excludefile".
if ~isempty(T) && ~isempty(excludefile)
    mask = false(size(T.name));
    for n = 1:length(excludefile)
        c = regexpi(T.name, regexptranslate('wildcard', excludefile{n}), 'match');
        c = [c{:}]';
        mask = mask | ismember(T.name, c);
    end
    T(mask,:) = [];
end


%% Get a nicer table.
if ~isempty(T)
    %T.idx       = (1 : length(T.name))';
    T.filename  = categorical(fullfile(T.folder, T.name));
    T.name      = [];
    T.folder    = [];
    T.date      = datetime(T.datenum,                   ...
                           'ConvertFrom', 'datenum',    ...
                           'Format', 'dd-MMM-uuuu eee hh:mm:ss a');
    T.datenum   = [];
    %T           = T(:, {'idx', 'filename', 'date', 'bytes'});
    T           = T(:, {'filename', 'date', 'bytes'});
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


%% Add new column T.n.
T.n = (1:size(T,1)).';
T   = T(:, [end, 1:(end-1)]);


end







