function p = searchdir(root, include, exclude)

%%
%       SYNTAX: p = searchdir(root, include, exclude);
%
%  DESCRIPTION: Search directories recursively under the root directory with
%               filtering capability.
%
%               To search directories recursively, use any one of the
%               followings:
%                   >> p = searchdir('.', '*', '');
%
%               To avoid recursive search, use any one of the followings:
%                   >> p = searchdir('.', '', '');      % Fastest.
%                   >> p = searchdir('.', '', '*');     % Fastest.
%                   >> p = searchdir('.', '*', '*');    % Slowest. Avoid this.
%
%        INPUT: - root (char)
%                   Root directory. Can be relative path or absolute path. Use
%                   '.' for current directory. Case-sensitive.
%
%               - include (char or 1-D row/col cell array of char)
%                   Include directory pattern(s). If include = '', then this
%                   function will exit and return the root directory. If include
%                   = cell array of char, then include is allowed to be {''} or
%                   {'', '', ...} but include is not allowed to be {'', '*'} or
%                   {'', 'dir1'}. User can use wildcards. Do not use regular
%                   expression. Examples: 'abc' and 'ab*de*'. File separator
%                   (i.e. '\' in Windows or '/' in Unix) is not allowed.
%                   Case-insensitive. Note that each pattern is applied to only
%                   the name of each sub-directory but not its full path name
%                   (i.e. root directory name is ignored).
%
%               - exclude (string or 1-D row/col cell array of char)
%                   Exclude directory pattern(s). User can use wildcards. Do not
%                   use regular expression. Examples: 'abc' and 'ab*de*'. Use ''
%                   or {} to skip this stage. File separator (i.e. '\' in 
%                   Windows or '/' in Unix) is not allowed. Case-insensitive.
%                   Note that each pattern is applied to only the name of each
%                   sub-directory but not its full path name (i.e. root
%                   directory name is ignored).
%
%       OUTPUT: - p (1-D row cell array of char)
%                   Cell array of all subdirectories under root directory.
%                   Always return absolute path. Sorted in alphabetical
%                   and ascending order.


%% Force root to be an absolute path.
if ~ischar(root)
    error('root is not a char.');
end
if exist(root, 'dir') == 0
    error('Root directory "%s" not found', root);
end
[~, p] = fileattrib(root);
root = p.Name;


%% Force include and exclude to be 1-D cell array.
if isempty(include)
    include = {};
else
    if ~iscell(include)
        include = {include};
    end
end
if isempty(exclude)
    exclude = {};
else
    if ~iscell(exclude)
        exclude = {exclude};
    end
end


%% Check include.
foundempty    = 0;
foundnonempty = 0;
for n = 1:numel(include)
    if isempty(include{n})
        foundempty = 1;
    else
        foundnonempty = 1;
    end
end
if (foundempty == 1) && (foundnonempty == 1) 
    error('Invalid combination in include.');
end


%% Special case: include = {}, {''} or {'', '', ...}.
if isempty(include)
    p = {root};
    return;
end
for n = 1:numel(include)
    if isempty(include{n})
        p = {root};
        return;
    end
end


%% Make sure that 'include' and 'exclude' do not contain file separator.
c = strfind(include, filesep);
c = [c{:}];
if ~isempty(c)
    error('One of the include patterns contains file separator.');
end
c = strfind(exclude, filesep);
c = [c{:}];
if ~isempty(c)
    error('One of the exclude patterns contains file separator.');
end


%% Find subdirectories under root (non-recursive).
files = dir(root);
if isempty(files)
    p = {};
    return;
end
isdir = logical(cat(1,files.isdir));
dirs = files(isdir); % select only directory entries from the current listing


%% Remove "." and ".." from dirs. 
dirs(strcmp('.', {dirs.name})) = [];
dirs(strcmp('..', {dirs.name})) = [];


%% Remove directories from 'dirs' according to 'exclude'.
if ~isempty(exclude)
    midx = [];
    for n = 1:length(dirs)
        c = regexpi(dirs(n).name, regexptranslate('wildcard', exclude), 'match');
        c = [c{:}];
        if any(strcmp(dirs(n).name, c))
            midx = [midx, n];
        end
    end
    dirs(midx) = [];
end


%% Recursively descend through all directories.
p = {root};
for i=1:length(dirs)
   dirname = dirs(i).name;
   % Take out include in all recursive calls.
   p = [p, searchdir(fullfile(root, dirname), '*', exclude)]; 
end


%% Check include.
if ~any(strcmp(include, '*'))
    
    % Modify 'include' by adding '\' at the beginning and at the end.
    for n = 1:length(include)
        include{n} = [filesep, include{n}, filesep];
    end
    
    % Create 'p_new' by adding '\' at the end.
    p_new = cell(1, length(p));
    for n = 1:length(p)
        p_new{n} = [p{n}, filesep];
    end

    % Only return the path whose subdirectory matches include.
    midx = [];
    for n = 1:length(p)
        c = regexpi(p_new{n}, regexptranslate('wildcard', include), 'match');
        c = [c{:}];
        if ~isempty(c)
            midx = [midx, n];
        end
    end
    p = p(midx);
    
end


%% Sort p.
p = sort(p);


%% Change first letter to lower case.
for n = 1:length(p)
    p{n}(1) = lower(p{n}(1));
end


end

