function forget(varargin)

%%
%       SYNTAX: forget var1 var2 ...
%               forget(var1, var2, ...);
%               forget(vars);
%
%               forget *
%
%  DESCRIPTION: "forget var1 var2" deletes saved variables.
%
%               "forget *" deletes all saved variables.
%
%        INPUT: - var1, var2 (char)
%                   Variable names.
%
%               - vars (N-D cell array of char)
%                   N-D cell array of character vectors. Each cell element
%                   contains one variable name.
%
%       OUTPUT: none.
%
%     SEE ALSO: HIDE, SEEK


%% Assign input arguments.
if (nargin == 1) && iscell(varargin{1})
    varnames = varargin{1};
else
    varnames = varargin;
end


%% Removed saved data in brain.
if (numel(varnames) == 1) && strcmp(varnames{1}, '*')
    brain('removeall');
else
    brain('remove', varnames);
end


end

