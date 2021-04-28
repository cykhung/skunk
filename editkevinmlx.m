function editkevinmlx(varargin)

%%
%       SYNTAX: editkevinmlx;
%               editkevinmlx(description);
%
%  DESCRIPTION: Open a new mlx-file in MATLAB editor.
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
    getkevinfilename(fileparts(mfilename('fullpath')), 'mlx', description);
 

%% Create the new file.
edit(newfilename)
fprintf('\nCreate new file: %s\n\n', newfilename);


end



% %% List of folders to try.
% % folders = {findroot('skunk'), tempdir};
% folders = {findroot('skunk')};
% 
% 
% %% Go through the list of folders to create the new m-file.
% done = 0;
% for n = 1:length(folders)
%     
%     % Come up with the new tmp filename.
%     newfilename = getkevinfilename(folders{n}, 'mlx', description);
%     
%     % Create the new file.
%     fid = fopen(newfilename, 'a');
%     if fid == -1
%         % Does not have write permission to create new file.
%         continue;
%     else
%         s = fclose(fid);
%         if s ~= 0
%             error('Cannot close file: %s', newfilename);
%         end
%         fprintf('\nCreate new file: %s\n\n', newfilename);
%         edit(newfilename);
%         done = 1;
%         break
%     end
% 
% end
% if done == 0
%     fprintf('Cannot create new tmp file.\n\n');
% end

