function rm(varargin)

%%
%       SYNTAX: rm(filenames);
%               rm(filenames, recycle_flag);
%               rm filename1, filename2, ...
%               rm filename1, filename2, ... recycle_flag
%
%  DESCRIPTION: Remove file(s).
%
%        INPUT: - filenames (char or N-D cell array of char or 
%                                    N-D array of categorical)
%                   Filename(s).
%
%               - recycle_flag (real double or string)
%                   Recycling flag. Optional. Default = 2. Valid values are:
%                       0 - Permanently delete the file(s).
%                       1 - Move the file(s) to recycle bin.
%                       2 - Follow the Matlab Preference for Deleting Files.
%
%       OUTPUT: none.


%% Assign input arguments.
recycle_flag = 2;
switch nargin
case 1
    filenames = varargin{1};
otherwise
    if (nargin == 2) && isnumeric(varargin{2})
        filenames    = varargin{1};
        recycle_flag = varargin{2};
    else
        x = str2double(varargin{end});
        if ismember(x, 0:2)
            filenames    = varargin(1:(end-1));
            recycle_flag = x;
        else
            filenames = varargin;
        end
    end
end


%% Force recycle_flag into double.
if ischar(recycle_flag)
    recycle_flag = str2num(recycle_flag);   %#ok<ST2NM>
end


%% Force filenames into cell array.
filenames = convert_filenames(filenames);


% %% Check if all files exist.
% flags = fexist(filenames);
% if any(flags == 0)
%     m = find(flags == 0, 1);
%     error('File "%s" not found. No file is deleted.', filenames{m});
% end


%% Delete file(s).
state = recycle;
switch recycle_flag
case 0
    % Permanently delete the file(s).
    recycle('off');
case 1
    % Move the file(s) to recycle bin.
    recycle('on');
case 2
    % Follow the Matlab Preference for Deleting Files. Do nothing.
otherwise
    error('Invalid recycle_flag.');
end 
delete(filenames{:});
recycle(state);


end


% %% Assign input arguments.
% recycle_flag = 2;
% switch nargin
% case 1
%     filenames = varargin{1};
% case 2
%     filenames    = varargin{1};
%     recycle_flag = varargin{2};
% otherwise
%     error('Invalid number of input arguments.');
% end



