function fetch(text)

%
%     FUNCTION: fetch - Search Text Recursively Under Current Folder.
%
%       SYNTAX: fetch(text);
%
%  DESCRIPTION: Search text in files recursively under current folder.
%
%        INPUT: - text (char or 1-D row/col cell array of char)
%                   Include text pattern(s). Use regular expression. Note that 
%                   this pattern is applied to each line in the file.
%
%       OUTPUT: none.


%% Start tic.
TIC = tic;


%% Perform directory listing to find all files recursively under current folder.
s = dir('**');
x = [s.isdir];
s = s(x == 0);
fprintf('Top Level Folder:  %s\n', pwd);


%% Skip .svn and .git folders.
x = contains({s.folder}, [filesep, '.svn', filesep]);
s = s(~x);
x = contains({s.folder}, [filesep, '.git', filesep]);
s = s(~x);
fprintf('Skip Folders:      .svn, .git\n');


%% Skip binary files.
b = {'.mat', '.mlx',  '.slx',  '.fig',                              ...
     '.pdf', '.indd', '.indb', '.ai',                               ...
     '.jpg', '.png',  '.gif',  '.heic', '.mov', '.m4a', '.wav',     ...
     '.nef',                                                        ...
     '.xls', '.xlsx', '.ppt',  '.pptx', '.doc', '.docx',            ...
     '.exe', '.dll',  '.jar'                                        ...
     '.7z',  '.zip',                                                ...
     };
x = endsWith({s.name}, b, 'IgnoreCase', true);
s = s(~x);
fprintf('Skip Binary Files: %s\n',   char(join(b(1:11),   ', ')));
fprintf('                   %s\n',   char(join(b(12:22),  ', ')));
fprintf('                   %s\n\n', char(join(b(23:end), ', ')));


%% Skip large files.
x = [s.bytes] >= (100 * (1024^2));
y = find(x);
for n = 1:length(y)
    m = y(n);
    fprintf('Skip %s%s%s. File size = %.2f MB.\n',          ...
            s(m).folder,                                    ...
            filesep,                                        ...
            s(m).name,                                      ...
            s(m).bytes / (1024^2));
end
if ~isempty(y)
    fprintf('\n');
end
s = s(~x);


%% Search through each file.
if length(s) >= 1e4
    fprintf('Number of files to search = %d. ', length(s));
    fprintf('You may want to use parfor.\n\n');
end
allfiles        = fullfile({s.folder}, {s.name});
matched_linenum = [];
for n = 1:length(allfiles)
    tmp_linenum = searchtext_1_slow(allfiles{n}, {text}, '', 0);
    matched_linenum = [matched_linenum, tmp_linenum];   %#ok<AGROW>
    
end
fprintf('\nNumber of matches = %d.\n', length(matched_linenum));
toc(TIC)
fprintf('\n');


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       SYNTAX: output_linenum = searchtext_1_slow(filename,
%                                                  includetext, 
%                                                  excludetext, 
%                                                  casesensitive);
%
%  DESCRIPTION: Search text in one file.
%
%        INPUT: - filename (string)
%                   Filename.
%
%               - includetext (string or 1-D row/col cell array of string)
%                   Include text pattern(s). See above.
%
%               - excludetext (string or 1-D row/col cell array of string)
%                   Exclude text pattern(s). See above.
%
%               - casesensitive (real double)
%                   Case-sensitive flag. See above.
%
%       OUTPUT: - output_linenum (1-D row array of real double)
%                   Vector of line numbers for each matched line. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output_linenum = searchtext_1_slow(filename,       ...
                                            includetext,    ...
                                            excludetext,    ...
                                            casesensitive)


%% Initialize output arguments.
output_linenum = [];


%% Open file in text mode.
[fid, msg] = fopen(filename, 'rt');
if fid == -1
    % error('Cannot open file. %s', msg);
    fprintf('Cannot open file. %s. %s.\n', msg, filename);
    return;     % Early exit.
end


%% Read the entire file. Each line is returned in one cell element.
all_lines = textscan(fid, '%s', 'delimiter', '\r\n', 'whitespace', '');
all_lines = all_lines{1};


%% Close file.
tmp = fclose(fid);
if tmp == -1
    error('Cannot close file.');
end


%% Use regexp to search for includetext.
match_all_line_nums = [];
for n = 1:length(includetext)
    switch casesensitive
    case 1
        tmp = regexp(all_lines, includetext{n}, 'ONCE');
    case 0
        tmp = regexp(lower(all_lines), lower(includetext{n}), 'ONCE');
        % tmp = regexp(all_lines, includetext{n}, 'ignorecase', 'ONCE');
    otherwise
        error('Invalid value for casesensitive.');
    end
    match_all_line_nums = ...
        [match_all_line_nums, find(~cellfun('isempty', tmp))']; %#ok<AGROW>
end
match_all_line_nums = unique(match_all_line_nums);


%% Print out all matched lines.
PWD = pwd;
for n = 1:length(match_all_line_nums)

    % Set filename_to_display.
    k = strfind(filename, PWD);
    if isempty(k)
        filename_to_display = filename;
    elseif k == 1
        filename_to_display = ...
            filename((length(pwd)+1+1):end);  % Extra 1 to remove '\'.
    else
        error('Something went wrong.');
    end

    % Get current line number.
    linenum = match_all_line_nums(n);
    
    % Get the content of one matched line.
    line = all_lines{linenum};

    % Check against excludetext.
    if ~isempty(excludetext)
        switch casesensitive
        case 1
            tmp = regexp(line, excludetext, 'ONCE');
        case 0
            tmp = regexp(lower(line), lower(excludetext), 'ONCE');
            % tmp = regexp(line, excludetext, 'ignorecase', 'ONCE');
        otherwise
            error('Invalid value for casesensitive.');
        end
        tmp = [tmp{:}];
        if ~isempty(tmp)
            line = [];
        end
    end

    % Print one matched line with hyperlink.
    if ~isempty(line)
        fprintf('<a href="matlab:opentoline(''%s'', %d);">%s:%d</a> %s\n', ...
                filename, ...
                linenum, ...
                filename_to_display, ...
                linenum, ...
                line);
    end

end
output_linenum = match_all_line_nums;


%% Exit function.
end

