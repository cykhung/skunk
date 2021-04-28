function varargout = searchtext(varargin)

%
%     FUNCTION: searchtext - Search Text In Files And Directories Recursively.
%
%       SYNTAX: searchtext(rootdir, includedir, excludedir, includefile, excludefile, includetext, excludetext, casesensitive);
%               searchtext(filename, includetext, excludetext, casesensitive);
%               [matched_filename, matched_filename_to_display, matched_line, matched_linenum] = searchtext(...);
%
%  DESCRIPTION: Search text in files and directories recursively.
%
%               searchtext(...) performs the search and prints matched results
%               on screen.
%
%               [matched_filename, matched_filename_to_display, matched_line,
%               matched_linenum] = searchtext(...) performs the search and
%               return matched results in output arguments. No printing on
%               screen.
%
%        INPUT: - rootdir (char)
%                   Root directory. Can be relative path or absolute path. Use
%                   '.' for current directory.
%
%               - includedir (char or 1-D row/col cell array of char)
%                   Include directory pattern(s). Refer to input argument
%                   'include' in searchdir.m for details.
%
%               - excludedir (char or 1-D row/col cell array of char)
%                   Exclude directory pattern(s). Refer to input argument
%                   'exclude' in searchdir.m for details.
%
%               - includefile (char or 1-D row/col cell array of char)
%                   Include file pattern(s). Refer to input argument
%                   'includefile' in searchfile.m for details.
%
%               - excludefile (char or 1-D row/col cell array of char)
%                   Exclude file pattern(s). Refer to input argument
%                   'excludefile' in searchfile.m for details.
%
%               - includetext (char or 1-D row/col cell array of char)
%                   Include text pattern(s). Use regular expression. Note that 
%                   this pattern is applied to each line in the file.
%
%               - excludetext (char or 1-D row/col cell array of char)
%                   Exclude text pattern(s). Use regular expression. Note that
%                   the exclude text pattern is applied to the lines that have
%                   the include text pattern(s).
%
%               - casesensitive (real double)
%                   Case-sensitive flag. Valid values are:
%                       0 - Not case-sensitive search. Before the searches, all 
%                           characters in the file and in 'includetext' and in
%                           'excludetext' are changed into lowercase.
%                       1 - Case-sensitive search.
%
%               - filename (char)
%                   Single filename.
%
%       OUTPUT: TBD.


%% Assign input arguments.
switch nargin
case 4
    [filename, includetext, excludetext, casesensitive] = deal(varargin{:});
    isdir = 0;
    tmp = dir(filename);
    if isempty(tmp)
        error('Either rootdir or filename not found.');
    end
case 8
    [rootdir, includedir,  excludedir,  includefile, excludefile, ...
        includetext, excludetext, casesensitive] = deal(varargin{:});
    isdir = 1;
otherwise
    error('Invalid number of input arguments.');
end


%% Force includetext to be a 1-D cell array of char.
if isempty(includetext)
    includetext = {};
else
    if ~iscell(includetext)
        includetext = {includetext};
    end
end


%% Force excludetext to be a 1-D cell array of char.
if isempty(excludetext)
    excludetext = {};
else
    if ~iscell(excludetext)
        excludetext = {excludetext};
    end
end


%% Make sure that rootdir exists.
if isdir == 1
    if exist(rootdir, 'dir') ~= 7
        error('rootdir "%s" not found.', rootdir);
    end
end


%% Search for all files recursively.
if isdir == 1
    T = searchfile(rootdir, includedir, excludedir, includefile, excludefile);
    if ~isempty(T)
        allfiles = cellstr(T.filename)';
    end
else
    allfiles = {filename};
end


%% Search through each file.
matched_filename            = {};
matched_filename_to_display = {};
matched_line                = {};
matched_linenum             = [];
for n = 1:length(allfiles)
    s = dir(allfiles{n});
    if s.bytes > (100 * (1024^2))
        k = strfind(allfiles{n}, pwd);
        if isempty(k)
            filename_to_display = allfiles{n};
        elseif k == 1
            filename_to_display = allfiles{n}((length(pwd)+1+1):end);  % Extra 1 to remove '\'.
        else
            error('Something went wrong.');
        end
        fprintf('Skip %s. File size = %.2f MB.\n', filename_to_display, s.bytes / (1024^2));
        % fprintf('Filename = %s. Elapsed = %.3f seconds.\n', ...
        %     allfiles{n}, ...
        %     t);
        continue
    end
    [tmp_filename, tmp_filename_to_display, tmp_line, tmp_linenum] = ...
        searchtext_1_slow(allfiles{n}, includetext, excludetext, casesensitive);
    matched_filename            = [matched_filename, tmp_filename]; %#ok<AGROW>
    matched_filename_to_display = [matched_filename_to_display, tmp_filename_to_display]; %#ok<AGROW>
    matched_line                = [matched_line, tmp_line];         %#ok<AGROW>
    matched_linenum             = [matched_linenum, tmp_linenum];   %#ok<AGROW>
end


%% Print matched results on screen or return matched results in output arguments.
if nargout == 0
    for n = 1:length(matched_filename)
        if isdir == 0
            fprintf('<a href="matlab:opentoline(''%s'', %d);">%d</a> %s\n', ...
                matched_filename{n}, ...
                matched_linenum(n), ...
                matched_linenum(n), ...
                matched_line{n});
        else
            fprintf('<a href="matlab:opentoline(''%s'', %d);">%s:%d</a> %s\n', ...
                matched_filename{n}, ...
                matched_linenum(n), ...
                matched_filename_to_display{n}, ...
                matched_linenum(n), ...
                matched_line{n});
        end
    end
    fprintf('\nNumber of matches = %d.\n\n', length(matched_filename));
else
   varargout = {matched_filename, matched_filename_to_display, matched_line, matched_linenum};
end


%% Exit function.
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FUNCTION: searchtext_1_slow - Search Text In One File.
%
%       SYNTAX: [output_filename, 
%                output_filename_to_display, 
%                output_line, 
%                output_linenum] = searchtext_1_slow(filename, 
%                                                    includetext, 
%                                                    excludetext, 
%                                                    casesensitive);
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
%       OUTPUT: - output_filename (1-D row cell array of string)
%                   Cell array of matched filenames. length(output_filename) =
%                   length(output_linenum).
%
%               - output_filename_to_display (1-D row cell array of string)
%                   Cell array of matched filenames to display. 
%                   length(output_filename_to_display) = length(output_linenum).
%
%               - output_line (1-D row cell array of string)
%                   Cell array of contents of each matched line. 
%                   length(output_line) = length(output_linenum).
%
%               - output_linenum (1-D row array of real double)
%                   Vector of line numbers for each matched line. 
%                   length(output_linenum) = length(output_linenum).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output_filename, output_filename_to_display, output_line, output_linenum] ...
                = searchtext_1_slow(filename, ...
                                    includetext, ...
                                    excludetext, ...
                                    casesensitive)

                                       
%% Open file in text mode.
[fid, msg] = fopen(filename, 'rt');
if fid == -1
    error('Cannot close file. %s', msg);
end


%% Read the entire file. Each line is returned in one cell element.
try
    % all_lines = textscan(fid, '%s', ...
    %                      'delimiter', '\r\n', ...
    %                      'bufSize', 10e6, ...
    %                      'whitespace', '');
    all_lines = textscan(fid, '%s', ...
                         'delimiter', '\r\n', ...
                         'whitespace', '');
    all_lines = all_lines{1};
catch err
    if strcmp(err.identifier, 'MATLAB:textscan:UnableToReadFile')
        k = strfind(filename, pwd);
        if isempty(k)
            filename_to_display = filename;
        elseif k == 1
            filename_to_display = filename((length(pwd)+1+1):end);  % Extra 1 to remove '\'.
        else
            error('Something went wrong.');
        end
        fprintf('Skip %s (binary file)\n', filename_to_display);
    else
        rethrow(err);
    end
    all_lines = {};
end


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
    match_all_line_nums = [match_all_line_nums, ...
        find(~cellfun('isempty', tmp))'];                           %#ok<AGROW>
end
match_all_line_nums = unique(match_all_line_nums);


%% Print out all matched lines.
output_filename = {};
output_filename_to_display = {};
output_line = {};
output_linenum = [];
PWD = pwd;
PWD(1) = lower(PWD(1));
for n = 1:length(match_all_line_nums)

    % Set filename_to_display.
    k = strfind(filename, PWD);
    if isempty(k)
        filename_to_display = filename;
    elseif k == 1
        filename_to_display = filename((length(pwd)+1+1):end);  % Extra 1 to remove '\'.
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
        output_filename{end+1} = filename;                          %#ok<AGROW>
        output_filename_to_display{end+1} = filename_to_display;    %#ok<AGROW>
        output_line{end+1} = line;                                  %#ok<AGROW>
        output_linenum(end+1) = linenum;                            %#ok<AGROW>
    end

end

        
%% Exit function.
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %     FUNCTION: searchtext_1_fast - Search Text In One File.
% %
% %       SYNTAX: N_print_lines = searchtext_1_fast(filename, 
% %                                                 includetext, 
% %                                                 excludetext, 
% %                                                 casesensitive);
% %
% %  DESCRIPTION: Search text in one file.
% %
% %        INPUT: - filename (string)
% %                   Filename.
% %
% %               TBD ..........
% %
% %       OUTPUT: none.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function N_print_lines = searchtext_1_fast(filename, ...
%                                            includetext, ...
%                                            excludetext, ...
%                                            casesensitive)
% 
% 
% %
% % Define constants.
% %
% CR = sprintf('\r');
% LF = sprintf('\n');
% 
% 
% %
% % Open file (in readonly binary mode).
% %
% [fid, msg] = fopen(filename, 'rb');
% if fid == -1
%     error('Cannot close file. %s', msg);
% end
% 
% 
% %
% % Read all characters in the entire file.
% %
% allchars = fread(fid, inf, '*char').';
% 
% 
% %
% % Close file.
% %
% tmp = fclose(fid);
% if tmp == -1
%     error('Cannot close file.');
% end
% 
% 
% %
% % Replace CR-LF with LF.
% %
% if ispc
%     allchars = strrep(allchars, [CR, LF], LF);
% end
% 
% 
% %
% % Replace char(0) with '^'.
% %
% allchars = strrep(allchars, char(0), '^');
% 
% 
% %
% % Find EOL.
% %
% eol = find(abs(allchars) == abs(LF));
% 
% 
% %
% % Use regexp to search for includetext.
% %
% switch casesensitive
% case 1
%     midx = regexp(allchars, includetext);
% case 0
%     midx = regexp(lower(allchars), lower(includetext));
% otherwise
%     error('Invalid value for casesensitive.');
% end
% midx = [midx{:}];
% match_all_line_nums = [];
% if ~isempty(midx)
%     [N, match_all_line_nums] = histc(midx, [0, eol, length(allchars)+1]);
%     if isempty(N)
%         error('Something went wrong.');     % Make mlint happy.
%     end
%     match_all_line_nums = unique(match_all_line_nums);
% end
% 
% 
% %
% % Print out all matched lines.
% %
% N_print_lines = 0;
% if ~isempty(match_all_line_nums)
%     
%     [pathstr, name, ext] = fileparts(filename);
%     if isempty(pathstr)
%         error('Something went wrong again.');   % Make mlint happy.
%     end
%     filename_without_path = [name, ext];
%     for linenum = match_all_line_nums
%         
%         % Get the content of one matched line.
%         if linenum == 1
%             start_midx = 1;
%         else
%             start_midx = eol(linenum - 1) + 1;
%         end
%         if linenum == (length(eol) + 1)
%             end_midx = length(allchars);
%         else
%             end_midx = eol(linenum) - 1;
%         end
%         line = allchars(start_midx : end_midx);
%         
%         % Check against excludetext.
%         if ~isempty(excludetext)
%             switch casesensitive
%             case 1
%                 tmp = regexp(line, excludetext);
%             case 0
%                 tmp = regexp(lower(line), lower(excludetext));
%             otherwise
%                 error('Invalid value for casesensitive.');
%             end            
%             tmp = [tmp{:}];
%             if ~isempty(tmp)
%                 line = [];
%             end
%         end 
%         
%         % Print one matched line with hyperlink.
%         if ~isempty(line)
%             N_print_lines = N_print_lines + 1;
%             fprintf('<a href="matlab:opentoline(''%s'', %d);">%s:%d</a> %s\n', ...
%                 filename, linenum, filename_without_path, ...
%                 linenum, line);
%         end
%         
%     end
%         
% end
%         
%         
% %
% % Exit function.
% %
% return;




