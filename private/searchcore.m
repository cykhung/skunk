function searchcore(filename, varargin)

%%
%       SYNTAX: searchcore History.xml
%               searchcore History.xml lte
%               searchcore History.xml lte mib


%% Assign input arguments.
if nargin == 1
    wanted = '.*';
else
    wanted = varargin;
end


%% Do search.
[matched_filename, ~, matched_line, matched_linenum] = ...
    searchtext(filename, wanted, '', 0);


%% Put search results (from searchtext) into a table.
T                  = table;
T.matched_filename = matched_filename(:);
T.matched_line     = matched_line(:);
T.matched_linenum  = matched_linenum(:);
clear matched_filename matched_line matched_linenum     % Avoid mistakes.


%% AND multiple wanted patterns.
if iscell(wanted) && (numel(wanted) > 1)
    mask = true(size(T.matched_line));
    for n = 1:numel(wanted)
        mask = mask & grep(T.matched_line, wanted{n}, '', 0);
    end
    T = T(mask, :);
end


%% In case of History.xml, get rid of <command execution_time="216">.
[~, name, ext] = fileparts(filename);
if (grep({name}, 'history', 0) == 1) && strcmp(ext, '.xml')
    
    % Get rid of something like: <command execution_time="138">
    T.matched_line = eraseBetween(T.matched_line, '<command ', '>', 'Boundaries', 'inclusive');

    % Get rid of something like: </command>
    T.matched_line = eraseBetween(T.matched_line, '</command', '>', 'Boundaries', 'inclusive');
    
end


%% In case of History.xml, filter out repeated lines.
[~, name, ext] = fileparts(filename);
if strcmpi([name, ext], 'history.xml')
    [~, idx] = unique(T.matched_line, 'stable');
    T        = T(idx, :);
end


%% Show search result.
fprintf('\n');
for n = 1:length(T.matched_filename)
    fprintf('<a href="matlab:opentoline(''%s'', %d);">%d:</a> %s\n', ...
        T.matched_filename{n}, ...
        T.matched_linenum(n), ...
        T.matched_linenum(n), ...
        T.matched_line{n});
end
fprintf('\nNumber of matches = %d.\n\n', length(T.matched_filename));


end

