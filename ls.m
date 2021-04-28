function s = ls(varargin)

if isunix == 1
    
    c = {'-alFh', varargin{:}};
    s = ls_matlab(c{:});
    
    % List directories before files.
    c = words(s, char(10));     % 10 = \n.
    c1 = cell(size(c));
    c1{1} = c{1};
    m = [];
    k = [];
    for n = 2:length(c)
        if ~isempty(c{n}) && strcmp(c{n}(end), '/')
            m = [m, n];
        else
            k = [k, n];
        end
    end
    c1(2:length(m)+1) = c(m);
    c1(length(m)+2 : end) = c(k);
    s = '';
    for n = 1:length(c1)
        if ~isempty(c1{n})
            s = [s, sprintf('%s\n', c1{n})];
        end
    end
    
else
    [status s] = dos(['dir /O:GN /A:-S', sprintf(' "%s"', varargin{:})]);
end

return;


function varargout=ls_matlab(varargin)
%LS List directory.
%   LS displays the results of the 'ls' command on UNIX.  You can
%   pass any flags to LS as well that your operating system supports.
%   On UNIX, ls returns a \n delimited string of file names.
%
%   On all other platforms, LS executes DIR and takes at most one input
%   argument. 
%
%   See also DIR, MKDIR, RMDIR, FILEATTRIB, COPYFILE, MOVEFILE, DELETE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 8285 $  $Date: 2015-04-12 16:13:15 -0400 (Sun, 12 Apr 2015) $
%=============================================================================
% validate input parameters
if iscellstr(varargin)
    args = strcat({' '},varargin);
else
    error('Inputs must be strings.');
end

% check output arguments
if nargout > 1
    error('MATLAB:LS:TooManyOutputArguments','Too many output arguments.')
end

% perform platform specific directory listing
if isunix
    if nargin == 0
        [s,listing] = unix('ls');
    else
        [s,listing] = unix(['ls ', args{:}]);
    end
    
    if s~=0
        error('MATLAB:ls:OSError',listing);
    end
else
    if nargin == 0
        %hack to display output of dir in wide format.  dir; prints out
        %info.  d=dir does not!
        if nargout == 0
            dir;
        else
            d = dir;
            listing = char(d.name);
        end
    elseif nargin == 1
        if nargout == 0
            dir(varargin{1});
        else
            d = dir(varargin{1});
            listing = char(d.name);
        end
    else
        error('Too many input arguments.')
    end
end

% determine output mode, depending on presence of output arguments
if nargout == 0 && isunix
    disp(listing)
elseif nargout > 0
    varargout{1} = listing;
end
%=============================================================================