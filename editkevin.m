function editkevin(varargin)

%%
%       SYNTAX: editkevin;
%               editkevin(description);
%
%  DESCRIPTION: Open a new m-file in MATLAB editor.
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


%% List of folders to try.
% folders = {findroot('skunk'), tempdir};
% folders = {findroot('skunk')};
folders = {fileparts(mfilename('fullpath'))};


%% Go through the list of folders to create the new m-file.
done = 0;
for n = 1:length(folders)
    
    % Come up with the new tmp filename.
    newfilename = getkevinfilename(folders{n}, 'm', description);
    
    % Create the new file.
    fid = fopen(newfilename, 'a');
    if fid == -1
        % Does not have write permission to create new file.
        continue;
    else
        
        % Add code.
        fprintf(fid, '%%%% Start from scratch.\n');
        fprintf(fid, '%% clear classes  %%#ok<CLCLS>\n');
        fprintf(fid, 'clear all %%#ok<CLALL>\n');
        fprintf(fid, 'rng(123, ''twister'')\n');
        fprintf(fid, '\n');
        
        % Close file.
        s = fclose(fid);
        if s ~= 0
            error('Cannot close file: %s', newfilename);
        end
        fprintf('\nCreate new file: %s\n\n', newfilename);
        
        % Open file in MATLAB editor.
        edit(newfilename);
        
        % Done.
        done = 1;
        break
        
    end

end
if done == 0
    fprintf('Cannot create new tmp file.\n\n');
end


end


