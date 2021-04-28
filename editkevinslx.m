function editkevinslx(varargin)

%%
%       SYNTAX: editkevinslx;
%               editkevinslx(description);
%
%  DESCRIPTION: Open a new slx-file in Simulink.
%
%        INPUT: - description (char)
%                   Description to be appended to filename. Optional.
%
%       OUTPUT: none.


%% Assign input arguments.
description = '';
switch nargin
case 0
    % Do nothing.
case 1
    description = varargin{1};
otherwise
    error('Invalid number of input arguments.');
end


%% Come up with the new tmp filename.
newfilename = ...
    getkevinfilename(fileparts(mfilename('fullpath')), 'slx', description);
 

%% Create the new file.
[~, filenamenoext] = fileparts(newfilename);
open_system(new_system(filenamenoext))
save_system(newfilename)
fprintf('\nCreate new file: %s\n\n', newfilename);


end



