function newfilename = getkevinfilename(varargin)

%%
%       SYNTAX: filename = getkevinfilename(folder, ext);
%               filename = getkevinfilename(folder, ext, description);
%
%  DESCRIPTION: Get filename for new MATLAB m-file or new Simulink model.
%
%        INPUT: - folder (char)
%                   Folder name where the new file should be created.
%
%               - ext (char)
%                   Filename extension. Either 'm' or 'slx'.
%
%               - description (char)
%                   Description to be appended to filename. Optional.
%
%       OUTPUT: - filename (char)
%                   Full path of the new file.


%% Assign input arguments.
description = '';
switch nargin
case 2
    folder = varargin{1};
    ext    = varargin{2};
case 3
    folder      = varargin{1};
    ext         = varargin{2};
    description = varargin{3};
otherwise
    error('Invalid number of input arguments.');
end


%% Extract the last file number.
T = searchfile(folder, '', '*', {'kevin*.m', 'kevin*.slx', 'kevin*.mlx'}, '');
if isempty(T)
    number = -1;
else
    T         = sortrows(T, 'filename');
    [~, name] = fileparts(char(T.filename(end)));
    name      = strsplit(name, '_');
    name      = name{1};
    number    = str2double(strrep(name, 'kevin', ''));
    if isnan(number)
        error('Cannot extract the last file number.');
    end
end


%% Come up with the new filename.
if isempty(description)
    filename = sprintf(['kevin%04d.', ext], number+1);
else
    filename = sprintf(['kevin%04d_%s.' ext], number+1, description);
end
newfilename = fullfile(folder, filename);
    

end

