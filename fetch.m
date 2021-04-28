function fetch(varargin)

%
%     FUNCTION: fetch - Search Text Recursively Under Current Folder.
%
%       SYNTAX: fetch(includetext);
%               fetch(includefile, includetext);
%               fetch(filename, includetext);
%               fetch(rootdir, includedir, excludedir, includefile, excludefile, includetext, excludetext, casesensitive);
%
%  DESCRIPTION: Search text in files recursively under current folder.
%
%        INPUT: - includetext (char or 1-D row/col cell array of char)
%                   Include text pattern(s). Use regular expression. Note that 
%                   this pattern is applied to each line in the file.
%
%               - includefile (char or 1-D row/col cell array of char)
%                   Include file pattern(s). Refer to input argument
%                   'includefile' in searchfile.m for details.
%
%               - filename (char)
%                   Single filename.
%
%               TBD.
%
%       OUTPUT: TBD.


%% Assign input arguments.
switch nargin
case 1
    includetext = varargin{1};
    includefile = '*';
case 2
    if grep(varargin(1), {'*', '?'}) == 1
        includefile = varargin{1};
        includetext = varargin{2};
    else
        filename    = varargin{1};
        includetext = varargin{2};        
    end
case 8
    rootdir       = varargin{1};
    includedir    = varargin{2};
    excludedir    = varargin{3};
    includefile   = varargin{4};
    excludefile   = varargin{5};
    includetext   = varargin{6};
    excludetext   = varargin{7};
    casesensitive = varargin{8};
otherwise
    error('Invalid number of input arguments.');
end


%% Do search.
if exist('filename', 'var')
    excludetext   = '';
    casesensitive = 0;
    searchtext(filename, includetext, excludetext, casesensitive);
else
    if nargin ~= 8 
        rootdir     = pwd;
        rootdir(1)  = lower(rootdir(1));
        includedir  = '*';
        excludedir  = '';
        excludefile = {                                                 ...
            '*.mat', '*.mlx', '*.slx', '*.fig',                         ...
            '*.pdf', '*.indd', '*.indb', '*.ai'                         ...
            '*.jpg', '*.png', '*.gif', '*.heic', '*.mov', '*.m4a'       ...
            '*.xls',  '*.xlsx', '*.ppt', '*.pptx', '*.doc', '*.docx',   ...
            '*.exe', '*.dll', '*.jar'                                   ...
            '*.7z',  '*.zip',                                           ...
            };
        excludetext   = '';
        casesensitive = 0;
        fprintf('Top Level Folder:  %s\n', rootdir);
        %fprintf('\n');
        fprintf('Skip Binary Files: %s\n',   char(join(excludefile(1:11),   ', ')));
        fprintf('                   %s\n',   char(join(excludefile(12:22),  ', ')));
        fprintf('                   %s\n\n', char(join(excludefile(23:end), ', ')));
    end
    rootdir(1) = lower(rootdir(1));
    searchtext(rootdir,         ...
               includedir,      ...
               excludedir,      ...
               includefile,     ...
               excludefile,     ...
               includetext,     ...
               excludetext,     ...
               casesensitive);
end


end
