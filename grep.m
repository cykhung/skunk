function varargout = grep(varargin)

%
%     FUNCTION: grep - Grep Using Either REGEXP OR STRFIND.
%
%       SYNTAX: mask = grep(c, wanted);
%               mask = grep(c, wanted, unwanted);
%               mask = grep(c, wanted, casesensitive);
%               mask = grep(c, wanted, unwanted, casesensitive);
%
%               [linenum, line, N_total_lines] = grep(b, wanted);
%               [linenum, line, N_total_lines] = grep(b, wanted, casesensitive);
%
%               status = grep('selftest');
% 
%  DESCRIPTION: Grep using either REGEXP or STRFIND. Use REGEXP if the first
%               input argument is a cell array. Use STRFIND if the first input
%               argument is a string array.
%
%        INPUT: - c (1-D row/col cell array of strings or 
%                    1-D row/col categorical array of strings)
%                   String(s). Search is performed independently on each cell
%                   array element.
%
%               - wanted (string or 1-D row/col cell array of strings)
%                   Wanted pattern(s). Regular expression. All patterns are 
%                   ORed together. Cannot be ''. Cannot be {}. In case of cell
%                   array, none of the cell is allowed to be ''.
%
%               - unwanted (string or 1-D row/col cell array of strings)
%                   Unwanted pattern(s). Regular expression. All patterns are 
%                   ORed together. Optional. Default = {}. If unwanted = '' or
%                   {}, then this means that there is no unwanted pattern. 
%
%               - casesensitive (real double)
%                   Case-sensitive flag. Optional. Default = 1. Valid values 
%                   are:
%                       0 - Not case-sensitive search.
%                       1 - Case-sensitive search.
%
%               - b (1-D row/col array of char)
%                   Input vector of characters. This is usually created by
%                   reading a text file:
%                       >> fid = fopen(filename, 'rb');
%                       >> allchars = fread(fid, inf, '*char').';
%                       >> fclose(fid);
%
%       OUTPUT: - mask (1-D row/col array of logical)
%                   Mask indicating the matches. length(mask) = length(c) and 
%                   mask will have the same orientation as c. Valid values for
%                   each element are:
%                       1 - Match Regular expression pattern.
%                       0 - Do not match Regular expression pattern.
%
%               - linenum (1-D row/col array of logical)
%                   Vector of line numbers. Same orientation as b.
%
%               - line (1-D row/col cell array of strings)
%                   Cell array of line contents corresponding to the line
%                   numbers in linenum. Same orientation as b.
%
%               - N_total_lines (real double)
%                   Total number of lines in b.
%
%               - status (real double)
%                   Result of all selftests. Valid values are:
%                       0 - Fail.
%                       1 - Pass.
%
%    $Revision: 9348 $
%
%        $Date: 2016-02-11 14:36:12 -0500 (Thu, 11 Feb 2016) $
%
%      $Author: khung $


%% Assign input arguments.
run_selftests = 0;
if nargin == 1
    if ~strcmp(varargin{1}, 'selftest')
        error('Invalid input argument.');
    end
    run_selftests = 1;
else
    unwanted = {};
    casesensitive = 1;
    if iscell(varargin{1}) || iscategorical(varargin{1})
        switch nargin
        case 2
            c = varargin{1};
            wanted = varargin{2};
        case 3
            c = varargin{1};
            wanted = varargin{2};
            if ischar(varargin{3}) || iscell(varargin{3})
                unwanted = varargin{3};
            else
                casesensitive = varargin{3};
            end
        case 4
            c = varargin{1};
            wanted = varargin{2};
            unwanted = varargin{3};
            casesensitive = varargin{4};
        otherwise
            error('Invalid number of input arguments.');
        end
    else
        switch nargin
        case 2
            c = varargin{1};
            wanted = varargin{2};
        case 3
            c = varargin{1};
            wanted = varargin{2};
            if ischar(varargin{3}) || iscell(varargin{3})
                unwanted = varargin{3};
            else
                casesensitive = varargin{3};
            end
        otherwise
            error('Invalid number of input arguments.');
        end
    end
end


%% Run selftests.
if run_selftests == 1
    status = grep_selftest;
    varargout = {status};
    return;
end


%% Check wanted.
if isempty(wanted)
    error('wanted is empty.');
end
if ~iscell(wanted)
    wanted = {wanted};
end
if any(cellfun('isempty', wanted))
    error('Cell elements in wanted cannot be empty.');
end


%% Check unwanted.
if ~iscell(unwanted)
    if isempty(unwanted)
        unwanted = {};
    else    
        unwanted = {unwanted};
    end
end


%% Decide which method to use.
if iscell(c) || iscategorical(c)
    method = 'regexp';
else
    method = 'binary';
end


%% Do the search.
switch method
case 'regexp'
    if iscategorical(c)
        c = cellstr(c);
    end
    mask = grep_regexp(c, wanted, unwanted, casesensitive);
    varargout = {mask};
case 'binary'
    [linenum, line, N_total_lines] = grep_binary(c, wanted, casesensitive);
    varargout = {linenum, line, N_total_lines};
otherwise
    error('Invalid method.');
end


end



function mask = grep_regexp(c, wanted, unwanted, casesensitive)


%% Handle casesensitive.
switch casesensitive
case 1
    % Do nothing.
case 0
    c = lower(c);
    wanted = lower(wanted);
    unwanted = lower(unwanted);
otherwise
    error('Invalid value for casesensitive.');
end


%% Initialize mask.
mask = false(size(c));


%% Search based on wanted patterns.
for n = 1:length(wanted)
    x = regexp(c, wanted{n}, 'ONCE');
    x = ~cellfun('isempty', x);
    mask(x) = true;
end


%% Search based on unwanted patterns.
if ~isempty(unwanted)
    new_c = c(mask);
    new_idx = find(mask);
    new_mask = false(size(new_c));
    for n = 1:length(unwanted)
        if ~isempty(unwanted{n})
            x = regexp(new_c, unwanted{n}, 'ONCE');
            x = ~cellfun('isempty', x);
            new_mask(x) = true;
        end
    end
    new_idx = new_idx(new_mask);
    mask(new_idx) = false;
end


end


function [linenum, line, N_total_lines] = ...
    grep_binary(allchars, wanted, casesensitive)


%% Handle casesensitive.
switch casesensitive
case 1
    % Do nothing.
case 0
    allchars = lower(allchars);
    wanted = lower(wanted);
otherwise
    error('Invalid value for casesensitive.');
end


%% Define constants.
CR = sprintf('\r');
LF = sprintf('\n');


%% Save the orientation of allchars.
if size(allchars, 1) == 1
    allchars_is_row = 1;
else
    allchars_is_row = 0;
end


%% Replace CR-LF with LF.
allchars = strrep(allchars(:)', [CR, LF], LF);


%% Replace char(0) with '^'.
allchars = strrep(allchars(:)', char(0), '^');


%% Find EOL.
eol = find(abs(allchars) == abs(LF));


%% Search based on wanted patterns.
bin_edges = [0, eol, length(allchars)+1];
midx = [];
for n = 1:length(wanted)
    midx = [midx, strfind(allchars(:)', wanted{n})];
end
if ~isempty(midx)
    [N, linenum] = histc(midx, bin_edges);
    linenum = unique(linenum);
else
    linenum = [];
end
if allchars_is_row == 1
    linenum = linenum(:).';
else
    linenum = linenum(:);
end


%% Set N_total_lines.
N_total_lines = length(bin_edges) - 1;
if bin_edges(end) == (bin_edges(end-1) + 1)
    N_total_lines = N_total_lines - 1;
end


%% Set line.
line = cell(1, length(linenum));
for n = 1:length(line)
    m1 = bin_edges(linenum(n)) + 1;
    m2 = bin_edges(linenum(n) + 1) - 1;
    line{n} = allchars(m1:m2);
end
if allchars_is_row == 1
    line = line(:).';
else
    line = line(:);
end


end


function status = grep_selftest


%% Initialize status.
status = 1;


%% Define constants.
CR = sprintf('\r');
LF = sprintf('\n');


%% Test syntax: mask = grep(c, wanted).
c = {'ABC', 'abcdef', 'adsfadf'};
wanted = 'abd';
mask = grep(c, wanted);
ideal = logical([0, 0, 0]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'adsfadf'};
wanted = 'abc';
mask = grep(c, wanted);
ideal = logical([0, 1, 0]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'adsfadf'}';
wanted = 'abc';
mask = grep(c, wanted);
ideal = logical([0, 1, 0])';
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'abfadf', 'abasdfadfef'};
wanted = 'ab(.*)ef';
mask = grep(c, wanted);
ideal = logical([0, 1, 0, 1]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'zzz', 'xxx'};
wanted = {'ab', 'xxx'};
mask = grep(c, wanted);
ideal = logical([0, 1, 0, 1]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdefxxx', 'zzz', 'xxx'};
wanted = {'ab', 'xxx'};
mask = grep(c, wanted);
ideal = logical([0, 1, 0, 1]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdefxxx', 'zzz', 'xxx'};
wanted = '';
try                     %#ok<TRYNC>
    grep(c, wanted);
    status = 0;
end

c = {'ABC', 'abcdefxxx', 'zzz', 'xxx'};
wanted = {};
try                     %#ok<TRYNC>
    grep(c, wanted);
    status = 0;
end

c = {'ABC', 'abcdefxxx', 'zzz', 'xxx'};
wanted = {''};
try                     %#ok<TRYNC>
    grep(c, wanted);
    status = 0;
end

c = {'ABC', 'abcdefxxx', 'zzz', 'xxx'};
wanted = {'adsf', ''};
try                     %#ok<TRYNC>
    grep(c, wanted);
    status = 0;
end


%% Test syntax: mask = grep(c, wanted, unwanted).
c = {'ABC', 'abcdef', 'adsfadf'};
wanted = 'abc';
unwanted = '';
mask = grep(c, wanted, unwanted);
ideal = logical([0, 1, 0]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'adsfadf'};
wanted = 'abc';
unwanted = {''};
mask = grep(c, wanted, unwanted);
ideal = logical([0, 1, 0]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'absfadf'};
wanted = 'ab';
unwanted = 'def';
mask = grep(c, wanted, unwanted);
ideal = logical([0, 0, 1]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'absfadf', 'cder'};
wanted = {'ab', 'cd'};
unwanted = {'def', 'er'};
mask = grep(c, wanted, unwanted);
ideal = logical([0, 0, 1, 0]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'absfadf', 'cder'};
wanted = {'ab', 'cd'};
unwanted = {'def', 'er', 'fad'};
mask = grep(c, wanted, unwanted);
ideal = logical([0, 0, 0, 0]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'adsfadf', 'cder'};
wanted = {'ab', 'cd'};
unwanted = {'deff', 'ere'};
mask = grep(c, wanted, unwanted);
ideal = logical([0, 1, 0, 1]);
if any(mask ~= ideal)
    status = 0;
end


%% Test syntax: mask = grep(c, wanted, casesensitive).
c = {'ABC', 'abcdef', 'adsfadf'};
wanted = 'ab';
casesensitive = 0;
mask = grep(c, wanted, casesensitive);
ideal = logical([1, 1, 0]);
if any(mask ~= ideal)
    status = 0;
end

c = {'ABC', 'abcdef', 'adsfadf'};
wanted = 'ab';
casesensitive = 1;
mask = grep(c, wanted, casesensitive);
ideal = logical([0, 1, 0]);
if any(mask ~= ideal)
    status = 0;
end


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). No CR. No LF.
b = 'abcdefe';
wanted = 'abc';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= 1)
    status = 0;
end
if ~isequal(line, {'abcdefe'})
   status = 0;
end 
if N_total_lines ~= 1
   status = 0;
end 


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). No CR. No LF.
b = 'abcdefZ';
wanted = 'Z';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= 1)
    status = 0;
end
if ~isequal(line, {'abcdefZ'})
   status = 0;
end 
if N_total_lines ~= 1
   status = 0;
end 


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). No CR. No LF.
b = 'abcdefZ';
wanted = 'A';
[linenum, line, N_total_lines] = grep(b, wanted);
if ~isempty(linenum)
    status = 0;
end
if ~isempty(line)
   status = 0;
end 
if N_total_lines ~= 1
   status = 0;
end 


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 1 line with [CR LF].
b = ['abcdefZ', CR, LF];
wanted = 'ab';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= 1)
    status = 0;
end
if ~isequal(line, {'abcdefZ'})
   status = 0;
end 
if N_total_lines ~= 1
   status = 0;
end 


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 1 line with [LF].
b = ['abcdefZ', LF];
wanted = 'ab';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= 1)
    status = 0;
end
if ~isequal(line, {'abcdefZ'})
   status = 0;
end 
if N_total_lines ~= 1
   status = 0;
end 


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 1 line with [CR LF].
b = ['abcdefZ', CR, LF];
wanted = 'Z';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= 1)
    status = 0;
end
if ~isequal(line, {'abcdefZ'})
   status = 0;
end 
if N_total_lines ~= 1
   status = 0;
end 


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 2 lines with [CR LF].
b = ['abcdefZ', CR, LF, 'adsadf'];
wanted = 'Z';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= 1)
    status = 0;
end
if ~isequal(line, {'abcdefZ'})
   status = 0;
end 
if N_total_lines ~= 2
   status = 0;
end 


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 2 lines with [CR LF].
b = ['abcdefZ', CR, LF, CR, LF];
wanted = 'Z';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= 1)
    status = 0;
end
if ~isequal(line, {'abcdefZ'})
   status = 0;
end 
if N_total_lines ~= 2
   status = 0;
end 


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 2 lines with [LF].
b = ['abcdefZ', LF, LF];
wanted = 'Z';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= 1)
    status = 0;
end
if ~isequal(line, {'abcdefZ'})
   status = 0;
end 
if N_total_lines ~= 2
   status = 0;
end 


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 2 lines with [LF].
b = ['abcdefZ', LF, LF];
wanted = 'x';
[linenum, line, N_total_lines] = grep(b, wanted);
if ~isempty(linenum)
    status = 0;
end
if ~isempty(line)
   status = 0;
end 
if N_total_lines ~= 2
   status = 0;
end


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 4 lines with [LF].
b = ['abcdefZ', LF, LF, 'xa', LF, 'x'];
wanted = 'x';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= [3 4])
    status = 0;
end
if ~isequal(line, {'xa', 'x'})
   status = 0;
end 
if N_total_lines ~= 4
   status = 0;
end


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 4 lines with [LF].
b = ['abcdefZ', LF, LF, 'xa', LF, 'x']';
wanted = 'x';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= [3 4]')
    status = 0;
end
if ~isequal(line, {'xa', 'x'}')
   status = 0;
end 
if N_total_lines ~= 4
   status = 0;
end


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted). 
%% 4 lines with [LF].
b = ['abcdefZ', LF, LF, 'xa', LF, 'x', LF]';
wanted = 'x';
[linenum, line, N_total_lines] = grep(b, wanted);
if any(linenum ~= [3 4]')
    status = 0;
end
if ~isequal(line, {'xa', 'x'}')
   status = 0;
end 
if N_total_lines ~= 4
   status = 0;
end


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted, casesensitive). 
%% 4 lines with [LF].
b = ['abcdefZ', LF, LF, 'xa', LF, 'x', LF]';
wanted = 'x';
[linenum, line, N_total_lines] = grep(b, wanted, 1);
if any(linenum ~= [3 4]')
    status = 0;
end
if ~isequal(line, {'xa', 'x'}')
   status = 0;
end 
if N_total_lines ~= 4
   status = 0;
end


%% Test syntax: [linenum, line, N_total_lines] = grep(b, wanted, casesensitive). 
%% 4 lines with [LF].
b = ['abcdefZ', LF, LF, 'xa', LF, 'X', LF]';
wanted = 'x';
[linenum, line, N_total_lines] = grep(b, wanted, 0);
if any(linenum ~= [3 4]')
    status = 0;
end
if ~isequal(line, {'xa', 'x'}')
   status = 0;
end 
if N_total_lines ~= 4
   status = 0;
end


%% Test syntax:  mask = grep(c, wanted, unwanted).
c = categorical({'ABC', 'abcdef', 'adsfadf'});
wanted = 'abc';
unwanted = '';
mask = grep(c, wanted, unwanted);
ideal = logical([0, 1, 0]);
if any(mask ~= ideal)
    status = 0;
end


end







